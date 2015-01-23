# beetle对象 负责调度各个对象函数

replaceDefine = require('./define/replace')
formatRequires = require('./define/format')

splitStr = '\n'
Bettle = (fileStr) ->
  this.translateFileStringToList(fileStr);

Bettle.prototype =
  fileList: []
  translateFileStringToList: (fileStr) ->
    if fileStr
      fileStr = fileStr + "";
      this.fileList = fileStr.split(splitStr)
    return this
  replaceDefine: (options) ->
    this.fileList = replaceDefine(this.fileList, options)
    return this
  formatRequires: (options) ->
    this.fileList = formatRequires(this.fileList, options)
    return this
  getFileString: ->
    return this.fileList.join(splitStr)

module.exports = Bettle;
