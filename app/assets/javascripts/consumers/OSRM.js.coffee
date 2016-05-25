class IBikeCPH.OSRM

  constructor: (@model) ->
    @request      = new IBikeCPH.SmartJSONP
    @zoom         = null
    @instructions = true
    @checksum     = null
    @hints        = {}
    @last_query   = ''

    @model.waypoints.on 'add remove reset change:location', => @waypoints_changed()
    @model.on 'change:profile', => @profile_changed()

  abort: ->
    @request.abort()

  set_zoom: (zoom) ->
    if @zoom != zoom
      @zoom = zoom
      if @model.waypoints.all_located()
        @request_route()
    
  get_zoom: ->
    @zoom

  set_instructions: (instructions) =>
    if @instructions != instructions
      @instructions = instructions
      @request_route() if @model.waypoints.all_located()
      
  get_instructions: ->
    @instructions
  
  waypoints_changed: ->
    if @model.waypoints.all_located()
      @request_route()
    else
      @reset()
  
  profile_changed: ->
    if @model.waypoints.all_located()
      @request_route()

  reset: ->
    @model.set 'route', ''
    @model.instructions.reset()
    @model.summary.reset()
    
  request_route: ->
    locations = @locations_array()
    #current_query = "#{@zoom}/#{!!@instructions}/#{locations.join ';'}"
    #current_query_with_instructions = "#{@zoom}/true/#{locations.join ';'}"
    #return if current_query == @last_query or current_query_with_instructions == @last_query
    #@last_query = current_query
            
    profile = @model.get('profile') or @model.standard_profile()
    url = IBikeCPH.config.routing_service[ profile ]
    url += if /\?/.test(url) then '&' else '?'
    
    do (locations) =>
      @request.exec url + @build_request(locations), (response) =>
        @update_model locations,response

  update_model: (locations,response) ->
    if response.hint_data
      @checksum = response.hint_data.checksum
      @hints = {}
      for hint, index in response.hint_data.locations
        @hints[locations[index]] = hint
  
    if response.route_geometry
      @model.set 'route', response.route_geometry
    else
      @model.set 'route', ''
        
    if response.route_summary
      @model.summary.set response.route_summary
    else
      @model.summary.reset()
    
    if response.route_instructions
      @model.instructions.reset_from_osrm response.route_instructions
    else
      @model.instructions.reset()

  build_request: (locations) ->
    params = []
    params.push 'jsonp=?'
    params.push "z=#{@zoom}" if @zoom?
    params.push 'output=json'
    params.push "checksum=#{@checksum}" if @checksum?
    params.push "instructions=#{!!@instructions}"
    params.push "alt=false"
    for location, index in locations
      params.push "loc=#{location}"
      hint = @hints[location]
      params.push "hint=#{hint}" if hint and @checksum?
    params.join('&')

  locations_array: ->
    locations = []
    for waypoint in @model.waypoints.models
      location = waypoint.get 'location'
      locations.push "#{location.lat.toFixed 5},#{location.lng.toFixed 5}"
    locations
