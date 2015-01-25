# format requires

util = require('../util')

requireReg = /\=[\s\S]*require/
requireNameReg = /(^\s*\S*\s*)(=[\s\S]*)/
group = [
  /\w+model\s+/i,
  /\w+collection\s+/i,
  /\w+view\s+/i,
  /\w+template\s+/i,
  /^\s*G_/
]

class Formator
  constructor: (fileList, options) ->
    @fileList = fileList
    @[i] = item for i, item of options

  fileList: []
  start: -1
  end: -1
  headers: []
  requires: []
  tails: []
  groupNumber: 6
  maxNameLength: 0

  initStartAndEnd: ->
    list = @fileList
    preSpace = -1
    for line, i in list
      continue if util.isSpaceLine(line) or util.isAnnotation(line)

      @start = i if @start < 0 and requireReg.test(line)
      if @start > 0
        match = line.match(requireNameReg)
        nameStr = ''
        nameStr = match[1] || '' if match
        @maxNameLength = nameStr.length if nameStr.length > this.maxNameLength

      @end = i + 1
      break if @start >= 0 and not requireReg.test(line)
    return this

  initRequires: ->
    list = @fileList
    @headers = list.slice(0, @start)
    @requires = list.slice(@start, @end)
    @tails = list.slice(@end)
    return this

  space: ->
    lastHeader = @headers[this.headers.length - 1]
    firstTail = @tails[0]

    @headers.push('') if not util.isSpaceLine(lastHeader) and not util.isAnnotation(lastHeader)
    @tails.unshift('') if not util.isSpaceLine(firstTail) and not util.isAnnotation(firstTail)
    return this

  align: ->
    list = @requires
    alignList = []
    for line in list
      match = line.match(requireNameReg)
      if match
        nameStr = match[1] or ''
        tailStr = match[2] or ''
        i = nameStr.length
        while(i++ < @maxNameLength)
          nameStr += ' '
        alignList.push(nameStr + tailStr)
    return this;

  compare: (a, b) ->
    aBig = 1
    abEqual = 0
    bBig = -1

    if(not a and not b)
      return abEqual
    else if(a and not b)
      return aBig
    else if(not a and b)
      return bBig

    parseChar = (c) ->
      if(/[^a-zA-Z]/.test(c))
        return "1#{c}"
      else if(/[a-z]/.test(c))
        return "2#{c}"
      else if(/[A-Z]/.test(c))
        return "3#{c}"
      return c

    a = "#{a}"
    b = "#{b}"
    i = 0
    while(i++ < a.length)
      return aBig if i >= b.length
      a_char = parseChar(a[i])
      b_char = parseChar(b[i])
      if(a_char > b_char)
        return aBig
      else if(a_char < b_char)
        return bBig
    return bBig if(i < b.length)
    return abEqual

  sort: ->
    requires = @requires.sort(@compare)
    if requires.length > this.groupNumber
      map = {other: []}
      map["#{reg}"] = [] for reg in group
      for line in requires
        continue if util.isSpaceLine(line) or util.isAnnotation(line)

        isNotOther = false
        for reg in group
          continue unless reg.test(line)
          isNotOther = true
          map["#{reg}"].push(line)
          break
        map.other.push(line) unless isNotOther

      requires = map.other
      for reg in group
        list = map["#{reg}"]
        requires.push('') if list.length > 0
        requires = requires.concat(list)

    @requires = requires
    return this

  format: ->
    @initStartAndEnd()
    return @fileList if @start < 0

    @initRequires().space().align().sort()
    return @headers.concat(@requires).concat(@tails);

module.exports = (fileList, options) ->
  formator = new Formator(fileList, options)
  return formator.format()


