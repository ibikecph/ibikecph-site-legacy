class IBikeCPH.OSRM

	constructor: (@model, @url) ->
		@request      = new IBikeCPH.SmartJSONP
		@zoom         = null
		@instructions = true
		@checksum     = null
		@hints        = ({} for i in [0...10])
		@hints_index  = 0
		@last_query   = ''

		@url += if /\?/.test @url then '&' else '?'
		@url += 'jsonp=?&'
		
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
		locations = @build_location_params()
		current_query = "#{@zoom}/#{!!@instructions}/#{locations.join ';'}"
		current_query_with_instructions = "#{@zoom}/true/#{locations.join ';'}"
		return if current_query == @last_query or current_query_with_instructions == @last_query
		@last_query = current_query
		{ prehints, query_string } = @build_request locations
		do (prehints) =>
			@request.exec @url + query_string, (response) =>
				@update_model response, prehints if response

	update_model: (response, prehints) ->
		if response.hint_data
			@checksum = response.hint_data.checksum
			@hints_index = (@hints_index + 1) % @hints.length
			@hints[@hints_index] = hints = {}
			for hint, index in response.hint_data.locations or []
				location_code = prehints[index]
				hints[location_code] = hint if location_code

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

	hint_for_location: (location_code) ->
		for hints in @hints
			hint = hints[location_code]
			return hint if hint
		return null

	build_request: (location_codes) ->
		params = []
		params.push "z=#{@zoom}" if @zoom?
		params.push 'output=json'
		params.push "checksum=#{@checksum}" if @checksum?
		params.push "instructions=#{!!@instructions}"

		prehints = []
		for location_code in location_codes
			prehints.push location_code
			hint = @hint_for_location location_code
			params.push "loc=#{location_code}"
			params.push "hint=#{hint}" if hint

		return (
			prehints     : prehints
			query_string : params.join('&')
		)

	build_location_params: ->
		locations = []
		for waypoint in @model.waypoints.models
			location = waypoint.get 'location'
			if location?.lat? and location.lng?
				lat = 1 * location.lat
				lng = 1 * location.lng
				locations.push "#{lat.toFixed 5},#{lng.toFixed 5}" unless isNaN(lat) or isNaN(lng)
		locations
