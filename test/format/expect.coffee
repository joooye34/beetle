define (require, exports, module) ->

  teambition         = require('teambition')
  Hotkey             = require('hotkey')
  Notification       = require('lib/notification/index')

  MembersCollection  = require('collections/members')
  MessagesCollection = require('collections/messages')
  ProjectsCollection = require('collections/projects')
  TagsCollection     = require('collections/tags')

  AppSwitcherView    = require('views/core/app-switcher/index')
  BoardView          = require('views/board/board/index')
  BookkeepingView    = require('views/bookkeeping/bookkeeping/index')
  WorkBgUploaderView = require('views/work/works-background-uploader/index')

  G_essage           = require('essage')

  class BaseModel extends Backbone.Model
    idAttribute: '_id'
    listened: false
