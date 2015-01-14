
// # from:
// # define(['a', 'b', 'c'], (A, B, C) ->
// #   # more code
// # )
// #
// # to:
// # define((require, exports, module) ->
// #   A = require('a')
// #   B = require('b')
// #   C = require('c')
// #   # more code
// # )

var ps = require('path');
var fs = require('fs');

var config = {
  folders: ['../../web/src/components','../../web/src/apps','../../web/src/lib'],
  // folders: ['./lib'],
  formatList: '##.coffee##',
  spaceReg: /\s*\'*\"*/g,
  defineReg: /define[\s\S]*?->\n/,
  definePathReg: /\[([\s\S]*)\]/,
  defineNameReg: /[\s\S]*,[\s\S]*\(([\s\S]*)\)/,
  defineSplitReg: /\n|,/,

  requireTest: /=[\s\S]*require/,
  requireMatch: /require\(([\s\S]*)\)/,
  defineTest: /define/,
  annotationTest: /^\s*#/,

  viewReg: /\w+view/i,
  modelReg: /\w+Model/i,
  collectionReg: /\w+collection/i,
  templateReg: /\w+template/i,
  tailReg: /__GLOBAL__/,

  defineBracketReg: /define\([\s\S]*\[[\s\S]*\][\s\S]*/,
  defineNoBracketReg: /define [\s\S]*\[[\s\S]*\][\s\S]*/,
  defineStr: 'define((require, exports, module) ->',
  defineStrNoBracket: 'define (require, exports, module) ->',
  defaultNameStr: '__GLOBAL__',
  groupNumber: 8
}
var options = {
  encoding: 'utf8'
}

function getPaths(defineStr){
  match = defineStr.match(config.definePathReg)
  pathsStr = '';
  if(match && match[1]){
    pathsStr = match[1];
  }
  list = pathsStr.split(config.defineSplitReg);
  re = [];
  for(var i=0;i<list.length;i++){
    var path = list[i];
    path = path.replace(config.spaceReg, '');
    if(path)
      re.push(path);
  }
  return re;
}
function getNames (defineStr) {
  match = defineStr.match(config.defineNameReg)
  namesStr = '';
  if(match && match[1]){
    namesStr = match[1];
  }
  list = namesStr.split(config.defineSplitReg);
  re = [];
  for(var i=0;i<list.length;i++){
    var name = list[i];
    name = name.replace(config.spaceReg, '');
    if(name)
      re.push(name);
  }
  return re;
}
function getMaxLength(names){
  var length = 0;
  for(var i=0;i<names.length;i++){
    var name = names[i];
    if(name.length > length) length = name.length;
  }
  return length;
}
function setStringLength(str, length){
  if(!str) str = '';
  var spaces = '';
  for(var i = str.length;i<length;i++){
    spaces += ' ';
  }
  return str + spaces;
}
function assembleRequire(name, path, nameLength){
  var list = [];

  list.push(setStringLength('', 2));
  if(!name){
    name = config.defaultNameStr + path;
    name = name.replace(/\W/g,'_');
  }
  list.push(setStringLength(name, nameLength));
  list.push(' = ');
  list.push('require(\''+path+'\')');
  return list.join('');
}

function parseChar(c){
  if(/[^a-zA-Z]/.test(c)) return '1' + c;
  else if(/[a-z]/.test(c)) return '2' + c;
  else if(/[A-Z]/.test(c)) return '3' + c;
  return c;
}
function compare(a, b){
  var aBig = 1;
  var abEqual = 0;
  var bBig = -1;

  if(!a && !b){
    return abEqual;
  }else if(a && !b){
    return aBig;
  }else if(!a && b){
    return bBig;
  }
  a = a + "";
  b = b + "";
  var i = 0;
  for(;i<a.length;i++){
    if(i >= b.length) return aBig;
    var a_char = parseChar(a[i]);
    var b_char = parseChar(b[i]);
    if(a_char > b_char) return aBig;
    else if(a_char < b_char) return bBig;
  }
  if(i<b.length) {
    return bBig;
  }
  return abEqual;
}
function sortRequire(list){
  list.sort(compare);
  if(list.length > config.groupNumber){
    var result = [];
    var utils = [];
    var models = [];
    var collections = [];
    var views = [];
    var templates = [];
    var tails = [];
    for(var i=0;i<list.length;i++){
      var item = list[i];
      if(config.modelReg.test(item)){
        models.push(item);
      }else if(config.collectionReg.test(item)){
        collections.push(item);
      }else if(config.viewReg.test(item)){
        views.push(item);
      }else if(config.templateReg.test(item)){
        templates.push(item);
      }else if(config.tailReg.test(item)){
        tails.push(item);
      }else{
        utils.push(item);
      }
    }
    if(utils.length){
      result.push('');
      result = result.concat(utils);
    }
    if(models.length){
      result.push('');
      result = result.concat(models);
    }
    if(collections.length){
      result.push('');
      result = result.concat(collections);
    }
    if(views.length){
      result.push('');
      result = result.concat(views);
    }
    if(templates.length){
      result.push('');
      result = result.concat(templates);
    }
    if(tails.length){
      result.push('');
      result = result.concat(tails);
    }
    return result;
  }else{
    return list;
  }
}
function replaceRequire(str){
  var list = [];
  list.push(str.replace(config.defineReg, ''));
  var defineStr = '';
  if(str.match(config.defineReg)){
    defineStr = str.match(config.defineReg)[0] || '';
  }
  if(config.defineBracketReg.test(defineStr)){
    var headers = [];
    paths = getPaths(defineStr);
    names = getNames(defineStr);
    nameLength = getMaxLength(names);
    for(var i=0; i<paths.length; i++){
      var path = paths[i];
      var name = '';
      if(i<names.length) name = names[i];
      var requireStr = assembleRequire(name, path, nameLength);
      headers.push(requireStr);
    }
    list = headers.concat(list);
    list.unshift(config.defineStr);
    return list.join('\n');
  }else if(config.defineNoBracketReg.test(defineStr)){
    var headers = [];
    paths = getPaths(defineStr);
    names = getNames(defineStr);
    nameLength = getMaxLength(names);
    for(var i=0; i<paths.length; i++){
      var path = paths[i];
      var name = '';
      if(i<names.length) name = names[i];
      var requireStr = assembleRequire(name, path, nameLength);
      headers.push(requireStr);
    }
    list = headers.concat(list);
    list.unshift(config.defineStrNoBracket);
    return list.join('\n');
  }else{
    return str;
  }
}
function getRequireStart(list){
  var start = -1;
  for(var i=0;i<list.length;i++){
    var line = list[i];
    if(config.requireTest.test(line)){
      start = i;
      break;
    }
  }
  if(start != -1){
    for(var i = start - 1;i>0;i--){
      line = list[i];
      if(!line) start = i;
      else break;
    }
  }
  return start;
}
function getRequireEnd(list){
  var end = -1;
  for(var i=0;i<list.length;i++){
    var line = list[i];
    if(config.requireTest.test(line) && i > end){
      end = i;
    }
  }
  if(end != -1){
    for(var i = end+1;i<list.length;i++){
      line = list[i];
      if(!line) end = i;
      else break;
    }
  }
  return end;
}
function splitRequire(list){
  var start = getRequireStart(list);
  var end = getRequireEnd(list);
  var re = {
    headers: [],
    requires: [],
    tails: []
  };
  for(var i=0;i<list.length;i++){
    var line = list[i];
    if(i < start){
      re.headers.push(line);
    }else if(i>end){
      re.tails.push(line);
    }else if(config.requireTest.test(line) && !config.annotationTest.test(line)){
      re.requires.push(line);
    }
  }
  return re;
}
function formatRequire(str){
  var list = str.split(/\n/);
  var splitResult = splitRequire(list);
  var headers = splitResult.headers;
  var requires = splitResult.requires;
  var tails = splitResult.tails;
  if(requires.length){
    var names = [];
    var paths = [];
    for(var i=0;i<requires.length;i++){
      var line = requires[i];
      var name = line.split("=")[0]+"";
      name = name.replace(config.spaceReg, '');
      names.push(name);
      var path = line.split("=")[1]+"";
      path = path.replace(config.spaceReg, '');
      path = path.match(config.requireMatch)[1] || '';
      paths.push(path);
    }
    nameLength = getMaxLength(names);
    requires = [];
    for(var i=0; i<paths.length; i++){
      var path = paths[i];
      var name = '';
      if(i<names.length) name = names[i];
      var requireStr = assembleRequire(name, path, nameLength);
      requires.push(requireStr);
    }
    requires = sortRequire(requires);
    if(requires[0]) requires.unshift('');
    if(requires[requires.length - 1]) requires.push('');
  }
  var result = [];
  result = result.concat(headers).concat(requires).concat(tails);
  return result.join('\n');
}
function formatFile(path){
  console.log('start format file:' + path);
  var result = fs.readFileSync(path, options);
  result = replaceRequire(result);
  result = formatRequire(result);
  fs.writeFileSync(path, result, options);
  console.log('end format file:' + path);
}
function formatFolder(path){
  console.log('start format folder:' + path);
  var files = fs.readdirSync(path);
  for(var i=0; i<files.length;i++){
    var childPath = path + '/' + files[i];
    var stat = fs.lstatSync(childPath);
    if(stat.isDirectory()){
      formatFolder(childPath);
    }else if(config.formatList.indexOf('##'+ps.extname(childPath).toLowerCase()+'##')>=0){
      formatFile(childPath);
    }
  }
  console.log('end format folder:' + path);
}

function main(){
  for(var i=0;i<config.folders.length;i++){
    var folder = config.folders[i];
    formatFolder(folder);
  }
}
main();

