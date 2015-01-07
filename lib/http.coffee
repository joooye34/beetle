define(require, exports, module) ->

  $           = require('jquery')
  Backbone    = require('backbone')
  ExpireCache = require('expireCache')
  Warehouse   = require('warehouse')
  _           = require('underscore')
  teambition  = require('teambition')

  _essage     = require('essage')

  DELAY = _.random(5, 10) * 1000 # 5 ~ 10 sec
  connectDelay = DELAY
  isConnected = true
  isConnecting = false

  _.extend({}, Backbone.Events, {
    initialize: ->
      # 已经重连上
      $(window).on('offline', ->
        Essage.show({
          message: "{{__disconnected}}"
          status: 'error'
        })
      ).on('online', ->
        Essage.hide()
      )

      @on('reconnected', =>
        unless isConnected
          Essage.show({
            message: "{{__connected}}"
            status: 'success'
          }, 2000)
        connectDelay = DELAY
        isConnected = true
      )

      # 断开连接
      @on('disconnect', =>
        if isConnected
          Essage.show({
            message: "{{__disconnected}}"
            status: 'error'
          })
        connectDelay = DELAY
        isConnected = false
      )

      # 正在重连
      @on('checkConnect', =>
        return if isConnecting
        isConnecting = true
        _.delay(=>
          @_reconnecting()
        , connectDelay)
      )

    _reconnecting: ->
      return unless isConnecting
      Backbone.ajax({
        url: "#{teambition.apiHost}/"
        success: =>
          isConnecting = false
          @trigger('reconnected')
        error: =>
          @trigger('disconnect')
          connectDelay *= 1.5
          if connectDelay > 60000 # 1 min
            isConnecting = false
          else
            _.delay(=>
              @_reconnecting()
            , connectDelay)
      })

    wrapSuccess: (callback)->
      return (resp) =>
        @trigger('reconnected') unless isConnected
        callback?(resp)

    wrapError: (callback, silentError) ->
      return (xhr) =>
        error = {message:'', code: ''}
        if xhr.responseJSON
          error = _.extend(error, xhr.responseJSON)
        else if _.isObject(xhr)
          error.message = xhr.message or xhr.statusText or error.message or ''
          error.code = xhr.code or xhr.status or 1
          error.stack = error.stack
        else
          error.message = xhr

        console.error(error)
        if error.code is 404
          @trigger('checkConnect')
        else
          Essage.show({
            message: error.message or "{{__error}}"
            status: 'error'
          }, 2000) unless silentError
        callback?(error)

    wrapForExpireCache: (options) ->
      return unless cacheOptions = options.expireCache
      beforeSend = options.beforeSend or ->
      success = options.success or ->
      setCache = ->
      options.beforeSend = (xhr, s) ->
        beforeSend(xhr, s)
        return unless s.type is 'GET'
        cacheKey = s.url.replace(/_=\d+/, '_=')
        expireCache = ExpireCache
        if cacheOptions.namespace
          expireCache = expireCache.namespace(cacheOptions.namespace, cacheOptions.expire)

        data = expireCache(cacheKey)
        if data
          success(data)
          return false
        else
          setCache = (resp) ->
            expireCache(cacheKey, resp)

      options.success = (resp) ->
        setCache(resp)
        success(resp)

    ajax: (path, options) ->
      if _.isString(path)
        options.url or= "#{teambition.apiHost}/#{path}" # 当 path 存在时，自动添加 API host 前缀
      else
        options = path # 否则应该在 options 中写入完整的 url
      _options = _.extend({
        type: 'GET'
      }, options)

      _options.xhrFields = {withCredentials: true} if _options.url.indexOf("#{teambition.apiHost}/") >= 0
      _options.success = @wrapSuccess(options.success)
      _options.error = @wrapError(options.error)

      @wrapForExpireCache(_options) if _options.type is 'GET'

      success = _options.success or ->

      _options.success = (resp) ->
        return _options.error(resp) if resp.code
        success(resp)

      Backbone.ajax(_options)

  })
)
