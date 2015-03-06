define (require, exports, module) ->

  aa    = require('aa')
  bbbbb = require('bbbbb')

  class BaseModel extends Backbone.Model
    idAttribute: '_id'
    listened: false
