var replaceDefine = require('define-replace');
var formatRequires = require('format-requires');

var splitStr = '\n';
function Bettle(fileStr){
  this.translateFileStringToList(fileStr);
};
Bettle.prototype = {
  fileList: [],
  translateFileStringToList: function(fileStr){
    if(fileStr){
      fileStr = fileStr + "";
      this.fileList = fileStr.split(splitStr);
    }
    return this;
  },
  replaceDefine: function(options){
    this.fileList = replaceDefine(this.fileList, options);
    return this;
  },
  formatRequires: function(options){
    this.fileList = formatRequires(this.fileList, options);
    return this;
  },
  getFileLIst: function(){
    return this.fileList;
  }
  getFileString: function(){
    return this.fileList.join(splitStr);
  }
};
exports = Bettle;
