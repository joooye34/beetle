'use strict';

var fs = require('fs');
var Beetle = require('../lib/beetle');
var assert = require("assert");

var options = {};

describe('Beetle', function(){
  // var files = fs.readdirSync(__dirname);
  // var folders = [];
  // for(var i=0; i<files.length;i++){
  //   var childName = files[i];
  //   var childPath = __dirname + '/' + childName;
  //   var stat = fs.lstatSync(childPath);
  //   if(stat.isDirectory()){
  //     it('test' + childName, function(){

  //       var test = fs.readFileSync(childPath + '/test.coffee', 'utf8');
  //       var expect = fs.readFileSync(childPath + '/expect.coffee', 'utf8');

  //       var beetle = new Beetle(test);
  //       var result = beetle.replaceDefine(options).formatRequires(options).getFileString();
  //       assert.equal(expect, result);
  //     });
  //   }
  // }

  it('test replace', function(){

    var test = fs.readFileSync(__dirname + '/replace/test.coffee', 'utf8');
    var expect = fs.readFileSync(__dirname + '/replace/expect.coffee', 'utf8');

    var beetle = new Beetle(test);
    var result = beetle.replaceDefine(options).formatRequires(options).getFileString();
    assert.equal(expect, result);
  });
  it('test format', function(){

    var test = fs.readFileSync(__dirname + '/format/test.coffee', 'utf8');
    var expect = fs.readFileSync(__dirname + '/format/expect.coffee', 'utf8');

    var beetle = new Beetle(test);
    var result = beetle.replaceDefine(options).formatRequires(options).getFileString();
    assert.equal(expect, result);
  });
  it('test format2', function(){

    var test = fs.readFileSync(__dirname + '/format2/test.coffee', 'utf8');
    var expect = fs.readFileSync(__dirname + '/format2/expect.coffee', 'utf8');

    var beetle = new Beetle(test);
    var result = beetle.replaceDefine(options).formatRequires(options).getFileString();
    assert.equal(expect, result);
  });
  it('test format3', function(){

    var test = fs.readFileSync(__dirname + '/format3/test.coffee', 'utf8');
    var expect = fs.readFileSync(__dirname + '/format3/expect.coffee', 'utf8');

    var beetle = new Beetle(test);
    var result = beetle.replaceDefine(options).formatRequires(options).getFileString();
    assert.equal(expect, result);
  });
})



