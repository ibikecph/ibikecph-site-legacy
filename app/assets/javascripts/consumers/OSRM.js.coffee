class ibikecph.OSRM

	constructor: (@model) ->
		@current =
			from : null
			to   : null
			via  : null

		@checksum = null
		@prehints = []
		@hints    = {}
		@request  = null

		@model.from.bind 'change:location', @load_route, this
		@model.to.bind   'change:location', @load_route, this
		@model.via.bind  'change:location', @load_route, this

	wait_for: (milliseconds, callback) ->
		clearTimeout(@timer) if @timer
		@timer = setTimeout callback, milliseconds

	abort: ->
		@request.abort() if @request?.abort

	load_route: (model, new_location) ->
		@wait_for 100, =>
			field_name = model.get 'field_name'

			if new_location?.lat? and new_location.lng?
				@current[field_name] = new_location
			else
				@current[field_name] = null

			#@abort()

			query_string = @build_query_string()

			if query_string
				@request = $.getJSON 'http://83.221.133.2/viaroute?jsonp=?&' + query_string, (result) =>
					return unless result

					if result.hint_data
						@checksum = result.hint_data.checksum

						for code, index in result.hint_data.locations or []
							hint = @prehints[index]
							if hint
								hint.value = code
								@hints[hint.field_name] = hint

						@prehints = []

					path = ibikecph.util.decode_path result.route_geometry
					@model.route.reset path

					console.log 'routing', result
			else
				@model.route.reset() if @model.route.length > 0

	build_query_string: ->
		if @current.zoom?
			data = "z=#{@current.zoom}&"
		else
			data = ''

		data += 'output=json&geomformat=cmp'
		data += "&checksum=#{@checksum}" if @checksum?

		@prehints = []
		from = @build_location_query_string @prehints, 'from'
		to   = @build_location_query_string @prehints, 'to'
		via  = @build_location_query_string @prehints, 'via'
		return null unless from and to

		data += from
		data += via if via
		data += to

		data += '&instructions=true'

		return data

	build_location_query_string: (prehints, field_name) ->
		location = @current[field_name]
		return null unless location

		lat = 1 * location.lat
		lng = 1 * location.lng
		return null if isNaN(lat) or isNaN(lng)

		lat = lat.toFixed(5)
		lng = lng.toFixed(5)

		data = "&loc=#{lat},#{lng}"

		hint = @hints[field_name]
		data += "&hint=#{hint.value}" if hint?.value and lat == hint.lat and lng == hint.lng

		prehints.push(
			field_name : field_name
			lat        : lat
			lng        : lng
		)

		return data
