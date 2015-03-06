# 工具函数对象

spaceLineReg = /^\s*$/
annotationLineReg = /^\s*#/
annotationReg = /#[\s\S]*/

util =
  isSpaceLine: (str = '') ->
    return spaceLineReg.test(str)
  isAnnotation: (str = '') ->
    return annotationLineReg.test(str)
  trimAnnotation: (str = '') ->
    return str.replace(annotationReg,'')
  getAnnotation: (str = '') ->
    match = str.match(annotationReg,'')
    if match
      return match[0]
    return ''
  getRegExp: (str = '') ->
    list = str.split(' :: ')
    regStr = list[0] or ''
    regTail = list[1] or ''
    return new RexExp(regStr, regTail)

module.exports = util
