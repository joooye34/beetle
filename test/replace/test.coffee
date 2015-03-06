define [
  'teambition'
], (
  teambition
) ->

  class BaseModel extends Backbone.Model
    idAttribute: '_id'
    listened: false
