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
		
		@model.waypoints.on 'reset add remove change', =>
			@load_route()

	abort: ->
		@request.abort()

	set_zoom: (zoom) ->
		@zoom = zoom
		@load_route()

	get_zoom: ->
		@zoom

	set_instructions: (instructions) =>
		had_instructions = @instructions
		@instructions = instructions
		@load_route() if instructions and not had_instructions

	get_instructions: ->
		@instructions

	load_route: ->
		locations = @build_location_params()

		if locations.length < 2
			@model.set 'route', ''
			@model.instructions.reset() if @model.instructions.length > 0
			@model.summary.set(
				total_distance : null
				total_time     : null
			)
			return

		current_query = "#{@zoom}/#{!!@instructions}/#{locations.join ';'}"
		current_query_with_instructions = "#{@zoom}/true/#{locations.join ';'}"
		return if current_query == @last_query or current_query_with_instructions == @last_query
		@last_query = current_query

		{prehints, query_string} = @build_request locations

		do (prehints) =>
			@request.exec @url + query_string, (response) =>
				@update_model response, prehints

	update_model: (response, prehints) ->
		return unless response

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
		return {} unless location_codes and location_codes.length >= 2

		if @zoom?
			query_string = "z=#{@zoom}&"
		else
			query_string = ''

		query_string += 'output=json'
		query_string += "&checksum=#{@checksum}" if @checksum?

		prehints = []
		for location_code in location_codes
			prehints.push location_code
			hint = @hint_for_location location_code
			query_string += "&loc=#{location_code}"
			query_string += "&hint=#{hint}" if hint

		query_string += "&instructions=#{!!@instructions}"

		return (
			prehints     : prehints
			query_string : query_string
		)

	build_location_params: ->
		return [] unless @model.waypoints.has_endpoints()

		locations = []

		for waypoint in @model.waypoints.models
			location = waypoint.get 'location'
			if location?.lat? and location.lng?
				lat = 1 * location.lat
				lng = 1 * location.lng
				locations.push "#{lat.toFixed 6},#{lng.toFixed 6}" unless isNaN(lat) or isNaN(lng)

		if locations.length < 2
			[]
		else
			locations
