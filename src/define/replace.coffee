# replace function that to transform CMD to CommonJS

util = require('../util')

startNoWrapperReg = /define [\s\S]*\[/
startWithWrapperReg = /define\([\s\S]*\[/
endReg = /->/
globalFLag = 'G_'

namesReg = /,[\s\S]*\(([\s\S]*)\)/
pathsReg = /\[([\s\S]*)\]/
markReg = /[\'\"]/g
requireSplit = /\n|,/
specialCharReg = /\W/g
specialCharStr = '_'

noWrapperStr = 'define (require, exports, module) ->'
withWrapperStr = 'define((require, exports, module) ->'

class Formator
  constructor: (fileList, options) ->
    @fileList = fileList
    @[i] = item for i, item of options

  fileList: []
  requires: []
  start: -1
  end: -1
  hasWrapper: false
  initStartAndEnd: ->
    list = @fileList;
    for line, i in list
      continue if util.isSpaceLine(line) or util.isAnnotation(line)
      if @start < 0
        if startNoWrapperReg.test(line)
          @hasWrapper = false
          @start = i
        else if startWithWrapperReg.test(line)
          @hasWrapper = true
          @start = i

      @end = i + 1;
      break if endReg.test(line)
    return this

  parseRequireStr: (str, isKeepAnnotation) ->
    return [] unless str
    list = str.split(requireSplit)
    re = []
    for tmp in list
      tmp = tmp.trim().replace(markReg, '')
      tmp = util.trimAnnotation(tmp) unless isKeepAnnotation
      re.push(tmp) if not util.isSpaceLine(tmp) and not util.isAnnotation(tmp)
    return re

  initRequires: ->
    defineStr = this.fileList.slice(@start, @end).join('\n')

    nameList = []
    pathList = []
    isKeepAnnotation = true

    nameList = @parseRequireStr(nameMatch[1]) if nameMatch = defineStr.match(namesReg)
    pathList = @parseRequireStr(pathMatch[1], isKeepAnnotation) if pathMatch = defineStr.match(pathsReg)
    return this unless pathList.length

    requires = []
    for pathStr, i in pathList
      if i < nameList.length
        nameStr = nameList[i]
      else
        nameStr = ''
      nameStr = globalFLag + pathStr.replace(specialCharReg, specialCharStr) unless nameStr
      requires.push("  #{nameStr} = require('#{pathStr}')")

    @requires = requires
    return this

  format: ->
    @initStartAndEnd().initRequires()
    return @fileList if @start < 0

    list = @fileList
    headers = list.slice(0, @start)
    requires = @requires
    tails = list.slice(@end)
    if @hasWrapper
      headers.push(withWrapperStr)
    else
      headers.push(noWrapperStr)
    return headers.concat(requires).concat(tails)

module.exports = (fileList, options) ->
  formator = new Formator(fileList, options)
  return formator.format()
