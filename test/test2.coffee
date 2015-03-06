define (require, exports, module) ->

  teambition         = require('teambition')
  Hotkey             = require('hotkey')
  Notification       = require('lib/notification/index')
  Socket             = require('lib/socket')
  View               = require('view')
  Thenjs             = require('thenjs')



  AppSwitcherView    = require('views/core/app-switcher/index')
  BoardView          = require('views/board/board/index')
  BookkeepingView    = require('views/bookkeeping/bookkeeping/index')
  EventsView         = require('views/events/events/index')
  FloatView          = require('views/core/float/index')
  HomeView           = require('views/home/home/index')
  InboxView          = require('views/inbox/inbox/index')
  LibraryView        = require('views/library/library/index')
  MarkdownHelperView = require('views/core/markdown-helper/index')
  MemberBarView      = require('views/member/member-bar/index')
  NavigationView     = require('views/core/navigation/index')
  OrganizationView   = require('views/organization/organization/index')
  PortalView         = require('views/portal/index')
  ReviewView             = require('views/review/review/index')
  TagView            = require('views/tag/tags/index')
  WallView           = require('views/wall/wall/index')

  WorkBgUploaderView = require('views/work/works-background-uploader/index')

  G_essage           = require('essage')
  WindowView         = require('lib/window/index')

  MembersCollection  = require('collections/members')
  MessagesCollection = require('collections/messages')
  ProjectsCollection = require('collections/projects')
  TagsCollection     = require('collections/tags')

  class BaseModel extends Backbone.Model
    idAttribute: '_id'
    listened: false

    constructor: (attrs, options = {}) ->
      options.parse =  true
      super(attrs, options)

    initialize: (attrs, options) ->
      @listen()
      Warehouse.bindByMatrix(@) unless @idAttribute isnt '_id' or options?.bindByMatrix is false
      return this

