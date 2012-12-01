class IBikeCPH.OSRM

	constructor: (@model, @url) ->
		@request      = new IBikeCPH.SmartJSONP
		@zoom         = null
		@instructions = true
		@checksum     = null
		@hints        = {}
		@last_query   = ''

		@url += if /\?/.test @url then '&' else '?'

		@model.waypoints.on 'add remove change', => @waypoints_changed()

	abort: ->
		@request.abort()

	set_zoom: (zoom) ->
		@zoom = zoom
		@request_route()

	get_zoom: ->
		@zoom

	set_instructions: (instructions) =>
		had_instructions = @instructions
		@instructions = instructions
		@request_route() if instructions and not had_instructions

	get_instructions: ->
		@instructions
	
	waypoints_changed: ->
		if @model.waypoints.has_endpoints()
			@request_route()
		else
			@clear()
	
	clear: ->
			@model.set 'route', ''
			@model.instructions.reset()
			@model.summary.reset()
		
	request_route: ->
		locations = @locations_array()
		#current_query = "#{@zoom}/#{!!@instructions}/#{locations.join ';'}"
		#current_query_with_instructions = "#{@zoom}/true/#{locations.join ';'}"
		#return if current_query == @last_query or current_query_with_instructions == @last_query
		#@last_query = current_query
		do (locations) =>
			@request.exec @url+@build_request(locations), (response) =>
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
			@model.trigger 'change:route', @model, '', {}
				
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
			params.push "hint=#{hint}" if hint
		params.join('&')

	locations_array: ->
		locations = []
		for waypoint in @model.waypoints.models
			location = waypoint.get 'location'
			locations.push "#{location.lat.toFixed 5},#{location.lng.toFixed 5}"
		locations
