class IBikeCPH.Models.ReportIssue extends Backbone.Model

  sync: (method, model, options) ->
    options or (options = {})
    switch method
      when "create"
        options.url = "/api/issues"
      when "read"
        if model.get("id")
          options.url = "/api/issues/" + model.get("id")
        else
          options.url = "/api/issues/"
      when "delete"
        options.url = "/api/issues/" + model.get("id")
      when "update"
        options.url = "/api/issues/" + model.get("id")

    options.headers = options.headers or {}
    _.extend options.headers,
      'accept': 'application/vnd.ibikecph.v1'
      'contentType': 'application/json'

    
    Backbone.sync.call model, method, model, options  if options.url