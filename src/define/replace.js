var util = require('../util');

var startNoWrapperReg = /define [\s\S]*\[/ ;
var startWithWrapperReg = /define\([\s\S]*\[/;
var endReg = /->/;
var globalFLag = 'G_';

var namesReg = /,[\s\S]*\(([\s\S]*)\)/;
var pathsReg = /\[([\s\S]*)\]/;
var markReg = /[\'\"]/g;
var requireSplit = /\n|,/;
var specialCharReg = /\W/g;
var specialCharStr = '_';

var noWrapperStr = 'define (require, exports, module) ->';
var withWrapperStr = 'define((require, exports, module) ->';

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
  requires: [],
  hasWrapper: false,
  initStartAndEnd: function(){
    var list = this.fileList;
    for(var i = 0;i<list.length;i++){
      var line = list[i];
      if(util.isSpaceLine(line)||util.isAnnotation(line))
        continue;

      if(this.start < 0){
        if(startNoWrapperReg.test(line)){
          this.hasWrapper = false;
          this.start = i;
        }else if(startWithWrapperReg.test(line)){
          this.hasWrapper = true;
          this.start = i;
        }
      }

      this.end = i + 1;
      if(endReg.test(line)) break;
    }
    return this;
  },
  parseRequireStr: function(str, isKeepAnnotation){
    if(!str) return [];
    var list = str.split(requireSplit);
    var re = [];
    for(var i = 0 ;i<list.length;i++){
      var tmp = list[i];
      tmp = tmp.trim().replace(markReg,'');
      if(!isKeepAnnotation) tmp = util.trimAnnotation(tmp);
      if(!util.isSpaceLine(tmp) && !util.isAnnotation(tmp)) re.push(tmp);
    }
    return re;
  },
  initRequires: function(){
    var defineStr = this.fileList.slice(this.start, this.end).join('\n');

    var nameList = [];
    var nameMatch = null;
    if(nameMatch = defineStr.match(namesReg))
      nameList = this.parseRequireStr(nameMatch[1]);

    var pathList = [];
    var pathMatch = null;
    if(pathMatch = defineStr.match(pathsReg)){
      var isKeepAnnotation = true;
      pathList = this.parseRequireStr(pathMatch[1], true);
    }
    if(!pathList.length) return this;

    var requires = [];
    for(var i = 0;i<pathList.length;i++){
      var pathStr = pathList[i];
      var nameStr = '';
      if(i<nameList.length) nameStr = nameList[i];
      if(!nameStr) nameStr = globalFLag + pathStr.replace(specialCharReg, specialCharStr);
      var str = '  ' + nameStr + ' = require(\'' + pathStr + '\')';
      requires.push(str)
    }
    this.requires = requires;

    return this;
  },
  format: function(){
    this.initStartAndEnd().initRequires();
    if(this.start < 0) return this.fileList;

    var list = this.fileList;
    var headers = list.slice(0, this.start);
    var requires = this.requires;
    var tails = list.slice(this.end);
    if(this.hasWrapper) headers.push(withWrapperStr);
    else headers.push(noWrapperStr);
    return headers.concat(requires).concat(tails);
  }
}
function doFormat(fileList, options){
  var formator = new Formator(fileList, options);
  return formator.format();
};
module.exports = doFormat;
