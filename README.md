beetle
====
一个把coffee代码从 AMD 规范转换成 CommonJS 规范的工具。

[![NPM version][npm-image]][npm-url]

## 安装
```js
npm install beetle -g
```

## 使用
命令行中直接使用 beetle 进行批量 coffee 文件的格式化。

```js
beetle -p path -d deep
```

path 参数可以是一个文件或者是一个文件夹。
deep 当path为文件夹时起效，为查询子文件夹的深度；参数默认为1，当 deep 指定非正数时，认为是无限制。

## 用例
转换之后的require代码会进行格式化和排序。

```js
例子：
define [
  'bbbbb'
  'aa'
], (
  bbbbb
  aa
) ->

  class BaseModel extends Backbone.Model
    idAttribute: '_id'
    listened: false

结果：
define (require, exports, module) ->

  aa    = require('aa')
  bbbbb = require('bbbbb')

  class BaseModel extends Backbone.Model
    idAttribute: '_id'
    listened: false
```


