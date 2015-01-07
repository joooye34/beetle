define((require, exports, module) ->

  Scrollable                = require('lib/scrollable')
  Thenjs                    = require('thenjs')
  Util                      = require('util')
  View                      = require('view')
  teambition                = require('teambition')

  BookkeepingModel          = require('models/bookkeeping')
  ProjectModel              = require('models/project')

  BookkeepingsCollection    = require('collections/bookkeepings')
  EntriesCollection         = require('collections/entries')
  EntryCategoriesCollection = require('collections/entry-categories')

  BookkeepingPanelView      = require('views/bookkeeping/bookkeeping-panel/index')
  EntryCreatorView          = require('views/bookkeeping/entry-creator/index')
  EntryDetailPanelView      = require('views/bookkeeping/entry-detail-panel/index')
  EntryView                 = require('views/bookkeeping/entry/index')
  SettingsApproverView      = require('views/bookkeeping/bookkeeping-settings/approver/index')
  SettingsDisplayFieldsView = require('views/bookkeeping/bookkeeping-settings/displayFields/index')
  WindowView                = require('lib/window/index')

  BasicTemplate             = require('./templates/basic')
  ContentTemplate           = require('./templates/content')

  orderMap = {
    category: '_entryategoryId'
    creator: '_creatorId'
  }

  class BookkeepingView extends View
    viewName: 'BookkeepingView'
    tagName: 'div'
    className: 'bookkeeping-view fade body-wrap'
    order: 'asc'
    orderBy: 'update'

    routes: {
      '': 'enterHome'
      'entry/:_entryId': 'enterHome'
      '*paramString': 'onRouteError'
    }

    events: {
      'click .bookkeeping-creator': 'openCreator'
      'click .open-detail': 'openDetail'
      'click .bookkeeping-sort': 'sortHandler'
      'click .bookkeping-setting-approver': 'openSettingsApprover'
      'click .bookkeping-setting-displayFields': 'openSettingsDisplayFields'
      'click .bookkeeping-header-tips-close': 'closeHeaderTips'
      'click .bookkeeping-panel-toggler': 'togglePanel'
    }

    initialize: (options) ->
      return unless options
      @options = options
      @_projectId = options._projectId
      @renderBasic()
      @load({
        success: =>
          @listen().renderContent().renderItems().initPanel()
          .calculateAmount().checkPlaceholder().checkApproveTips()
      })

      @registerAsResponsive()
      @setupScroll()
      _.delay( =>
        @$el.addClass('in')
        @layout()
      , 100)

    enterHome: (_entryId) ->
      @openDetail(_entryId, {isRouter: true})

    onRouteError: ->
      teambition.router.home()
      return this

    layout: ->
      height = $(window).height() - @$content.offset().top
      @$content.css('min-height', "#{height}px")
      @bookkeepingPanel?.layout()
      return this

    load: (options) ->
      @showLoadingIndicator(@$content, {isPrepend: true})
      Thenjs((cont) =>
        BookkeepingsCollection.fetch(@_projectId, {
          success: (collection) =>
            @bookkeepingModel = collection.at(0)
            cont()
          error: (collection, err) =>
            cont(err, null)
        })
      ).then((cont) =>
        EntriesCollection.fetch(@_projectId, {
          success: (collection) =>
            @entriesCollection = collection
            cont()
          error: (collection, err) =>
            cont(err, null)
        })
      ).then((cont) =>
        EntryCategoriesCollection.fetch(@_projectId, {
          success: (collection) =>
            @entryCategoriesCollection = collection
            cont()
          error: (collection, err) =>
            cont(err, null)
        })
      ).then((cont) =>
        @hideLoadingIndicator()
        options?.success?()
      ).fail((cont, err) =>
        console.error err
      )
      return this

    loadMore: (callback) ->
      @entriesCollection.loadMore({
        silent: true
        beforeSend: =>
          @showLoadingIndicator(@$itemList)
        success: (collection, resp, options) =>
          @hideLoadingIndicator({animated: true})
          @renderItems(resp)
          @bookkeepingPanel.refilter()
          @calculateAmount()
          if @entriesCollection.hasMore
            callback?()
          # else
          #   @showEndPoint(@$itemList)
      })
      return this

    listen: ->
      @stopListening()
      @listenTo(@bookkeepingModel, 'change:displayFields', (model) =>
        @renderContent()
        @renderItems()
        @bookkeepingPanel.filterEntries()
        @calculateAmount()
      )
      @listenTo(@bookkeepingModel, 'change:tipsClosed change:_approverIds', @checkApproveTips)
      @listenTo(@entriesCollection, 'add', (model) =>
        @renderItems(model, true)
      )
      @listenTo(@entriesCollection, 'add remove', =>
        @checkPlaceholder()
        @checkApproveTips()
      )
      @listenTo(@entriesCollection, 'add change:amount remove', =>
        @calculateAmount()
      )
      @listenTo(@entriesCollection, 'remove', @removeItem)
      return this

    renderBasic: ->
      @$el.html(BasicTemplate())
      @$content = @$(".bookkeeping-content")
      return this

    renderContent: ->
      displayFields = @bookkeepingModel.getDisplayFields()
      @$content.html(ContentTemplate(displayFields))
      @$itemList = @$content.find('.bookkeeping-list')
      @$placeholder = @$('.bookkeeping-placeholder')
      return this

    renderItems: (models, isPrepend) ->
      @renderSort()
      if models and _.isArray(models)
        list = models
      else if models
        list = [models]
      else
        @$itemList.empty()
        orderBy = (orderMap[@orderBy] if orderMap[@orderBy]) or @orderBy
        @entriesCollection.orderBy = orderBy
        @entriesCollection.sort()
        list = @entriesCollection.toJSON()
        list.reverse() if @order is 'desc'

      _.each(list, (model) => @renderItem(model, isPrepend))
      return this

    renderItem: (model, isPrepend) ->
      _entryId = model.id or model._id
      $target = @$itemList.find(".entry-view[data-id=#{_entryId}]")
      $item = @requestSubView(EntryView,{
        _entryId: _entryId
        viewType:'open-detail'
      }).$el

      if $target.length
        $target.replaceWith($item)
      else
        $item[if isPrepend is true then 'prependTo' else 'appendTo'](@$itemList)
      return this

    removeItem: (model) ->
      _entryId = model.id or model._id
      @$itemList.find(".entry-view[data-id=#{_entryId}]").remove()
      return this

    renderSort: ->
      order = @order
      orderBy = @orderBy
      className = '.bookkeeping-sort'

      @$el.find("#{className}.dropup").removeClass('dropup')
      @$el.find("#{className} .caret").remove()

      $target = @$el.find("#{className}[data-orderby='#{orderBy}']")
      $target.append("<span class='caret'></span>")
      $target.addClass('dropup') if order is 'asc'
      return this

    initPanel: ->
      @bookkeepingPanel?.remove()
      @bookkeepingPanel = @requestSubView(BookkeepingPanelView, {
        _projectId: @_projectId
      })
      @listenTo(@bookkeepingPanel, 'filtering', =>
        @isFiltering = true
        @$el.addClass('filtering')
        @calculateAmount()
      )
      @listenTo(@bookkeepingPanel, 'stopFilter', =>
        @isFiltering = false
        @$el.removeClass('filtering')
        @calculateAmount()
      )
      @listenTo(@bookkeepingPanel, 'show', =>
        @$el.addClass('pannel-showing')
      )
      @listenTo(@bookkeepingPanel, 'hide', =>
        @$el.removeClass('pannel-showing')
      )
      @bookkeepingPanel.$el.appendTo(@$('.bookkeeping-header-wrap'))
      return this

    calculateAmount: ->
      expense = 0
      income = 0
      unless @isFiltering
        @entriesCollection.each((model) ->
          if model.get('type') is -1
            expense += (model.get('amount') or 0)
          else
            income += (model.get('amount') or 0)
        )
      else
        ids = []
        @$itemList.children().filter(':visible').each(->
          $target = $(this)
          id = $target.data('id')
          ids.push(id) if id
        )
        @entriesCollection.each((model) ->
          return unless model.id in ids
          if model.get('type') is -1
            expense += (model.get('amount') or 0)
          else
            income += (model.get('amount') or 0)
        )
      @$('.bookkeeping-expense .bookkeeping-amount').text(expense.toFixed(2))
      @$('.bookkeeping-income .bookkeeping-amount').text(income.toFixed(2))
      return this

    checkApproveTips: ->
      model = @bookkeepingModel
      collection = @entriesCollection
      $headerTips = @$('.bookkeeping-header-tips')
      $placeholderTips = @$('.bookkeeping-approve-tips')
      showing = 'header-tips-showing'
      isAdmin = @bookkeepingModel.isAdmin()
      # 显示或隐藏头部的提示信息
      if model.get('_approverIds').length is 0 and collection.length and isAdmin and not model.get('tipsClosed')
        $headerTips.show()
        @layout()
      else
        $headerTips.hide()
        @layout()
      # 显示或隐藏placeholder中的提示信息
      if model.get('_approverIds').length is 0 and collection.length is 0 and isAdmin
        $placeholderTips.show()
      else
        $placeholderTips.hide()
      return this

    checkPlaceholder: ->
      method = if @entriesCollection.length > 0 then 'hide' else 'show'
      @$placeholder[method]()
      return this

    openCreator: (e) ->
      if e?.currentTarget
        $target = @$(e.currentTarget)
        type = $target.data('type')
      else
        type = e
      type = parseInt(type)
      return unless type is 1 or type is -1

      @requestSubView(WindowView).open(EntryCreatorView, {
        backdrop: 'static'
        type: type
        _projectId: @_projectId
      })

    openSettingsDisplayFields: (e) ->
      @requestSubView(WindowView).open(SettingsDisplayFieldsView, {
        bookkeepingModel: @bookkeepingModel
      })

    openSettingsApprover: (e) ->
      @requestSubView(WindowView).open(SettingsApproverView, {
        bookkeepingModel: @bookkeepingModel
      })

    openDetail: (e, options) ->
      if e?.currentTarget
        $target = $(e.currentTarget)
        entryId = $target.data('id')
      else
        entryId = e
      return unless entryId

      teambition.APP.showPanel(EntryDetailPanelView, {
        _entryId: entryId
      })
      unless options?.isRouter
        url = teambition.router.getPrefix() + "/bookkeeping/entry/#{entryId}"
        teambition.router.navigate(url)

    closeHeaderTips: ->
      @bookkeepingModel.set('tipsClosed', true)
      return this

    togglePanel: ->
      @bookkeepingPanel.toggle()
      return this

    sortHandler: (e) ->
      if e.currentTarget
        $target = $(e.currentTarget)
        orderBy = $target.data('orderby')
      else
        orderBy = e # 不通过事件调用而是直接调用 传入排序参数

      if @orderBy is orderBy
        @order  = (if @order is 'asc' then 'desc' else 'asc')
      else
        @orderBy = orderBy
        list = ['category', 'content', 'creator', 'receiver'] # 默认使用asc的属性
        @order = if orderBy in list then 'asc' else 'desc'

      @renderItems()
      @bookkeepingPanel.filterEntries()


  _.extend(BookkeepingView::, Scrollable)
  return BookkeepingView

)
