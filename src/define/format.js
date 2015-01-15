var util = require('../util');

var requireReg = /=[\s\S]*require/;
var requireNameReg = /(^\s*\S*\s*)(=[\s\S]*)/;
var group = [
  /\w+model\s+/i,
  /\w+collection\s+/i,
  /\w+view\s+/i,
  /\w+template\s+/i,
  /^\s*G_/
]

function Formator(fileList, options){
  this.fileList = fileList;
  for(var i in options){
    this[i] = options[i];
  }
}
Formator.prototype = {
  fileList: [],
  start: -1,
  end: -1,
  headers: [],
  requires: [],
  tails: [],
  groupNumber: 6,
  maxNameLength: 0,
  initStartAndEnd: function(){
    var list = this.fileList;
    var preSpace = -1;
    for(var i = 0;i<list.length;i++){
      var line = list[i];

      if(this.start < 0 && requireReg.test(line))
        this.start = i;
      if(this.start > 0){
        var match = line.match(requireNameReg);
        var nameStr = '';
        if(match) nameStr = match[1] || '';
        if(nameStr.length > this.maxNameLength)
          this.maxNameLength = nameStr.length;
      }
      this.end = i + 1;
      if(this.start >= 0 && !requireReg.test(line)) break;
    }
    return this;
  },
  initRequires: function(){
    var list = this.fileList;
    this.headers = list.slice(0, this.start);
    this.requires = list.slice(this.start, this.end);
    this.tails = list.slice(this.end);
    return this;
  },
  space: function(){
    var lastHeader = this.headers[this.headers.length - 1];
    if(!util.isSpaceLine(lastHeader) && !util.isAnnotation(lastHeader))
      this.headers.push('');
    var firstTail = this.tails[0];
    if(!util.isSpaceLine(firstTail) && !util.isAnnotation(firstTail))
      this.tails.unshift('');
    return this;
  },
  align: function(){
    var list = this.requires;
    var alignList = [];
    for(var i=0;i<list.length;i++){
      var line = list[i];
      var match = line.match(requireNameReg);
      if(match){
        var nameStr = match[1] || '';
        var tailStr = match[2] || '';
        for(var j=nameStr.length;j<this.maxNameLength;j++){
          nameStr += ' ';
        }
        alignList.push(nameStr + tailStr);
      }
    }
    this.requires = alignList;
    return this;
  },
  compare: function(a, b){
    var aBig = 1;
    var abEqual = 0;
    var bBig = -1;

    if(!a && !b) return abEqual;
    else if(a && !b) return aBig;
    else if(!a && b) return bBig;

    var parseChar = function(c){
      if(/[^a-zA-Z]/.test(c)) return '1' + c;
      else if(/[a-z]/.test(c)) return '2' + c;
      else if(/[A-Z]/.test(c)) return '3' + c;
      return c;
    }

    a = a + "";
    b = b + "";
    var i = 0;
    for(;i<a.length;i++){
      if(i >= b.length) return aBig;
      var a_char = parseChar(a[i]);
      var b_char = parseChar(b[i]);
      if(a_char > b_char) return aBig;
      else if(a_char < b_char) return bBig;
    }

    if(i < b.length) return bBig;
    return abEqual;
  },
  sort: function(){
    var requires = this.requires.sort(this.compare);
    if(requires.length > this.groupNumber){
      var map = {
        other: []
      };
      for(var i = 0;i<group.length;i++){
        var key = group[i];
        map[key.toString()] = [];
      }
      for(var i =0;i<requires.length;i++){
        var line = requires[i];
        if(util.isSpaceLine(line) || util.isAnnotation(line))
          continue;

        var isOther = true;
        for(var j = 0;j < group.length;j++){
          var reg = group[j];
          var key = reg.toString();
          if(reg.test(line)){
            isOther = false;
            map[key].push(line);
            break;
          }
        }
        if(isOther) map.other.push(line);
      }
      requires = map.other;
      for(var i = 0;i<group.length;i++){
        var key = group[i];
        var list = map[key.toString()];
        if(list.length > 0){
          requires.push('');
          requires = requires.concat(list);
        }
      }
    }
    this.requires = requires;
    return this;
  },
  format: function(){
    this.initStartAndEnd();
    if(this.start < 0 || this.start > this.end) return this.fileList;

    this.initRequires().space().align().sort();
    var headers = this.headers;
    var requires = this.requires;
    var tails = this.tails;
    return headers.concat(requires).concat(tails);
  }
}
function doFormat(fileList, options){
  var formator = new Formator(fileList, options);
  return formator.format();
};
module.exports = doFormat;
