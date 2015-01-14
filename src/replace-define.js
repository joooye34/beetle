// replace the fileList of
// from1:
// define(['a', 'b', 'c'], (A, B, C) ->
//   # more code
// )
// from2:
// define([
//   'a'
//   'b'
//   'c'
// ], (
//   A
//   B
//   C
// ) ->
//   # more code
// )
// from3:
// define [
//   'a'
//   'b'
//   'c'
// ], (
//   A
//   B
//   C
// ) ->
//   # more code
//
// to:
// define (require, exports, module) ->
//   A = require('a')
//   B = require('b')
//   C = require('c')
//   # more code
// or:
// define((require, exports, module) ->
//   A = require('a')
//   B = require('b')
//   C = require('c')
//   # more code
// )
//

var util = require('./util');

var startNoWrapperReg = /define [\s\S]*[/;
var startWithWrapperReg = /define\([\s\S]*[/;
var endReg = /->/;
var globalFLag = 'G_';

var requireReg = /([\s\S]*),([\s\S]*)/;
var requireSplit = /\n|,/;

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
    var list = fileList();
    for(var i = 0;i<list.length;i++){
      var line = list[i];
      if(util.isSpaceLine(line)||util.isAnnotation(line))
        continue;

      if(this.start < 0){
        if(startNoWrapperReg.test(startNoWrapperReg)){
          this.hasWrapper = false;
          this.start = i;
        }else if(startWithWrapperReg.test(startNoWrapperReg)){
          this.hasWrapper = true;
          this.start = i;
        }
      }

      this.end = i;
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
      tmp = tmp.trim();
      if(!isKeepAnnotation) tmp = util.trimAnnotation(tmp);
      re.push(tmp);
    }
    return re;
  },
  initRequires: function(){
    var defineStr = this.fileList.slice(this.start, this.end + 1 ).join('');
    var match = defineStr.match(requireReg);
    if(!match) return this;

    var isKeepAnnotation = true;
    var pathList = this.parseRequireStr(match[1], isKeepAnnotation);
    var nameList = this.parseRequireStr(match[2]);

    if(requireReg.test.indexOf(','))
    var pathList = [];
    var nameList = [];

    return this;
  },
  format: function(){
    this.initStartAndEnd().initRequires();
    var list = [];
    var headers = [];
    var tails = [];
    return this;
  },
  getFileList: function(){
    return this.fileList;
  }
}
function doFormat(fileList, options){
  var formator = new Formator(fileList, options);
  return formator.format().getFileList();
};
module.exports = doFormat;
