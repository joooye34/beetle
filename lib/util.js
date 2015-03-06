var annotationLineReg, annotationReg, spaceLineReg, util;

spaceLineReg = /^\s*$/;

annotationLineReg = /^\s*#/;

annotationReg = /#[\s\S]*/;

util = {
  isSpaceLine: function(str) {
    if (str == null) {
      str = '';
    }
    return spaceLineReg.test(str);
  },
  isAnnotation: function(str) {
    if (str == null) {
      str = '';
    }
    return annotationLineReg.test(str);
  },
  trimAnnotation: function(str) {
    if (str == null) {
      str = '';
    }
    return str.replace(annotationReg, '');
  },
  getAnnotation: function(str) {
    var match;
    if (str == null) {
      str = '';
    }
    match = str.match(annotationReg, '');
    if (match) {
      return match[0];
    }
    return '';
  },
  getRegExp: function(str) {
    var list, regStr, regTail;
    if (str == null) {
      str = '';
    }
    list = str.split(' :: ');
    regStr = list[0] || '';
    regTail = list[1] || '';
    return new RexExp(regStr, regTail);
  }
};

module.exports = util;
