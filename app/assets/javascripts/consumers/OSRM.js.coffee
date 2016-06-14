class IBikeCPH.OSRM

  constructor: (@model) ->
    @request      = new IBikeCPH.SmartJSONP
    @zoom         = null
    @instructions = true
    @hints        = {}

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
  
    profile = @model.get('profile') or @model.standard_profile()
    url = @build_request(profile, locations)     
    
    do (locations) =>
      @request.exec url, (response) =>
        @update_model locations,response
  
  update_model: (locations,response) ->
    #console.log response
    if response.code == "Ok"
      route = response.routes[0]    
      @hints = {}
      #for hint, index in response.hint_data.locations
      #  @hints[locations[index]] = hint
    
      @model.set 'route', route.geometry
      @model.summary.set { total_distance: route.distance, total_time: route.duration, summary: route.summary } 
      @model.instructions.reset_from_osrm route

  build_request: (profile, locations) ->
    base_url = IBikeCPH.config.routing_service.base_url
    profile_str = IBikeCPH.config.routing_service.profiles[ profile ]
    
    locations_str = locations.join(';')
    hints_str = (@hints[loc] for loc in locations).join(';')

    params = []
    params.push "overview=full"   #"z=#{@zoom}" if @zoom?
    params.push "geometries=polyline"
    params.push "hints=#{hints_str}"
    params.push "steps=#{!!@instructions}"
    params.push "alternatives=false"
    params_str = params.join('&')
    
    path = "#{base_url}/route/v1/#{profile_str}/#{locations_str}"
    url = [path,params_str].join('?')
    
    return url
    
    
  locations_array: ->
    locations = []
    for waypoint in @model.waypoints.models
      location = waypoint.get 'location'
      locations.push "#{location.lng.toFixed 5},#{location.lat.toFixed 5}"
    locations
