define (require, exports, module) ->

  teambition = require('teambition')

  class BaseModel extends Backbone.Model
    idAttribute: '_id'
    listened: false
