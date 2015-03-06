'use strict';

var gulp = require('gulp');
var mocha = require('gulp-mocha');
var coffee = require('gulp-coffee');

gulp.task('test', ['default'], function () {
  gulp.src(['test/test.js'], {read: false})
    .pipe(mocha());
});

gulp.task('default', function(){
  gulp.src('./src/*.coffee')
      .pipe(coffee({bare: true}).on('error', console.log))
      .pipe(gulp.dest('./lib/'));
});
