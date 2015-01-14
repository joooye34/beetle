
var spaceLineReg = /^\s*$/;
var annotationLineReg = /^\s*#/;
var annotationReg = /#[\s\S]*/;
util = {
  isSpaceLine: function(str){
    return spaceLineReg.test(str);
  },
  isAnnotation: function(str){
    return annotationLineReg.test(str);
  },
  trimAnnotation: function(str){
    return str.replace(annotationReg,'');
  },
  getAnnotation: function(str){
    var match = str.match(annotationReg,'');
    if(match) return match[0];
    return '';
  }
}
module.exports = util;
