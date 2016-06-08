noop = -> null # no operation


class IBikeCPH.SmartJSONP

  constructor: ->
    @current_request = null
    #@pending_request = null

  abort: ->
    @current_request.abort()# if @current_request?.abort

  exec: (url, callback) ->
    if @current_request
      #@pending_request =
      #  url      : url
      #  callback : callback
      return

    @current_request = $.ajax
      url      : url
      cache    : true # to prevent sending _=[timestamp] query string parameter
      dataType : 'json'
      timeout  : 1000
      success  : (data, status, xhr) =>
        callback data
      error    : (xhr, status, error) =>
        console.error 'request failed', status, error, xhr
      complete : (xhr, status) =>
        pending          = @pending_request
        @current_request = null
        #@pending_request = null
        #if pending
        #  @exec pending.url, pending.data, pending.callback
