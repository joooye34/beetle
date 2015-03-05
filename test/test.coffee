define [
  'teambition'
  'view'
  'lib/socket'
  'lib/window/index'
  'lib/notification/index'
  'views/core/float/index'
  'views/portal/index'
  'views/organization/organization/index'
  'views/wall/wall/index'
  'views/board/board/index'
  'views/home/home/index'
  'views/library/library/index'
  'views/events/events/index'
  'views/review/review/index'
  'views/tag/tags/index'
  'views/bookkeeping/bookkeeping/index'
  'views/core/navigation/index'
  'views/member/member-bar/index'
  'views/core/app-switcher/index'
  'views/inbox/inbox/index'
  'views/core/markdown-helper/index'
  'views/work/works-background-uploader/index'
  # collection
  'collections/messages'
  'collections/members'
  'collections/projects'
  'collections/tags'
  'thenjs'
  'hotkey'
  'essage'
], (
  teambition
  View
  Socket
  WindowView
  Notification
  FloatView
  PortalView
  OrganizationView
  WallView
  BoardView
  HomeView
  LibraryView
  EventsView
  ReviewView
  TagView
  BookkeepingView
  NavigationView
  MemberBarView
  AppSwitcherView
  InboxView
  MarkdownHelperView
  WorkBgUploaderView
  # collection
  MessagesCollection
  MembersCollection
  ProjectsCollection
  TagsCollection
  Thenjs
  Hotkey
) ->
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


