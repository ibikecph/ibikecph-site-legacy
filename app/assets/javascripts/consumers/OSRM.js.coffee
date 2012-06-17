class ibikecph.OSRM

	constructor: (@model) ->
		@request     = new ibikecph.SmartJSONP
		@zoom        = null
		@checksum    = null
		@hints       = ({} for i in [0...10])
		@hints_index = 0

		@model.waypoints.bind 'reset change', @load_route, this

	abort: ->
		@request.abort()

	load_route: ->
		{prehints, query_string} = @build_request()

		if query_string
			do (prehints) =>
				@request.exec 'http://83.221.133.2/viaroute?jsonp=?&' + query_string, (response) =>
					@update_model response, prehints
		else
			@model.route.reset() if @model.route.length > 0
			@model.instructions.reset() if @model.instructions.length > 0
			@model.summary.set(
				total_distance : null
				total_time     : null
			)

	update_model: (response, prehints) ->
		return unless response

		if response.hint_data
			@checksum = response.hint_data.checksum

			@hints_index = (@hints_index + 1) % @hints.length
			@hints[@hints_index] = hints = {}

			for hint, index in response.hint_data.locations or []
				location_string = prehints[index]
				hints[location_string] = hint if location_string

		if response.route_geometry
			path = ibikecph.util.decode_path response.route_geometry
			@model.route.reset path
		else
			@model.route.reset()

		if response.route_instructions
			@model.instructions.reset_from_osrm response.route_instructions
		else
			@model.instructions.reset()

		if response.route_summary
			@model.summary.set response.route_summary

		#console.log 'routing', response

	hint_for_location: (location_string) ->
		for hints in @hints
			hint = hints[location_string]
			return hint if hint
		return null

	build_request: ->
		return {} unless @model.waypoints.has_endpoints()

		if @zoom?
			qs = "z=#{@current.zoom}&"
		else
			qs = ''

		qs += 'output=json&geomformat=cmp'
		qs += "&checksum=#{@checksum}" if @checksum?

		prehints = []
		for waypoint in @model.waypoints.models
			waypoint_qs = @build_location_query_string waypoint, prehints
			qs += waypoint_qs if waypoint_qs

		qs += '&instructions=true'

		return (
			prehints     : prehints
			query_string : qs
		)

	build_location_query_string: (waypoint, prehints) ->
		location = waypoint.get 'location'

		lat = 1 * location?.lat
		lng = 1 * location?.lng
		return null if isNaN(lat) or isNaN(lng)

		lat = lat.toFixed(5)
		lng = lng.toFixed(5)
		location_string = "&loc=#{lat},#{lng}"
		hint = @hint_for_location(location_string)

		qs = location_string
		qs += "&hint=#{hint}" if hint

		prehints.push location_string
		return qs
