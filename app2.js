var ps = require('path');
var fs = require('fs');
var Beetle = require('./src/Beetle')

var config = {
  folders: ['../../web/src/components','../../web/src/apps','../../web/src/lib'],
  formatList: '##.coffee##',
}
var options = {
  encoding: 'utf8'
}
function formatFile(path){
  console.log('start format file:' + path);
  var fileStr = fs.readFileSync(path, options);
  var beetle = new Beetle(fileStr, options);
  fileStr = beetle.replaceDefine().formatRequires().getFileString();
  fs.writeFileSync(path, fileStr, options);
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
    var stat = fs.lstatSync(folder);
    if(stat.isDirectory()){
      formatFolder(folder);
    }else if(config.formatList.indexOf('##'+ps.extname(folder).toLowerCase()+'##')>=0){
      formatFile(folder);
    }
  }
}
main();
