# beetle对象 负责调度各个对象函数

replaceDefine = require('./define/replace')
formatRequires = require('./define/format')

splitStr = '\n'
class Bettle
  constructor: (fileStr) ->
    if fileStr
      fileStr = fileStr + "";
      @fileList = fileStr.split(splitStr)
    return this

  fileList: []
  translateFileStringToList: (fileStr) ->
    if fileStr
      fileStr = fileStr + "";
      @fileList = fileStr.split(splitStr)
    return this

  replaceDefine: (options) ->
    @fileList = replaceDefine(@fileList, options)
    return this

  formatRequires: (options) ->
    @fileList = formatRequires(@fileList, options)
    return this

  getFileString: ->
    return @fileList.join(splitStr)

module.exports = Bettle;
