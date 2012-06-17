class ibikecph.Waypoints extends Backbone.Collection
	model: ibikecph.Waypoint

	initialize: ->
		@_setup_event_proxy()

	endpoint: (type) ->
		last = (type == 'end' || type == 'to')

		if last
			index = @length - 1
			type  = 'to'
		else
			index = 0
			type  = 'from'

		waypoint   = @at index
		type_match = waypoint?.get and waypoint.get('type') == type

		unless type_match
			waypoint = new ibikecph.Waypoint type: type

			if last
				@add [waypoint]
			else
				@add [waypoint], at: 0

		return waypoint

	clear: (type) ->
		last = (type == 'end' || type == 'to')

		if last
			if @has_from()
				waypoint = @at(0)
		else
			if @has_to()
				waypoint = @at(@length - 1)

		if waypoint
			@reset [waypoint]
		else
			@reset()

	has_from: ->
		waypoint = @at(0)
		waypoint?.get and waypoint.get('type') == 'from'

	has_to: ->
		waypoint = @at(@length - 1)
		waypoint?.get and waypoint.get('type') == 'to'

	has_endpoints: ->
		@has_from() and @has_to()

	as_route_points: ->
		@models.map( (model) ->
			location = model.get 'location'

			lat = 1 * location.lat
			lng = 1 * location.lng

			if isNaN(lat) or isNaN(lng)
				null
			else
				new ibikecph.RoutePoint(
					lat: lat
					lng: lng
				)

		).filter( (model) -> model )

	to_latlngs: ->
		@as_route_points().map (point) -> point.to_latlng()

	to_code: ->
		codes = @map (waypoint) -> waypoint.to_code()

		codes.unshift '' unless @has_from()
		codes.push    '' unless @has_to()

		return codes.join '/'

	reset_from_code: (code) ->
		waypoints = []

		for location_code in code.split '/'
			waypoint = ibikecph.Waypoint.from_code location_code
			waypoints.push(waypoint) if waypoint

		if waypoints.length > 0
			waypoints[0].set 'type', 'from'

		if waypoints.length > 1
			waypoints[waypoints.length - 1].set 'type', 'to'

		@reset waypoints

	_setup_event_proxy: ->
		@_proxy_event_from = (event_name, a, b, c) =>
			@trigger 'from:' + event_name, a, b, c

		@_proxy_event_to = (event_name, a, b, c) =>
			@trigger 'to:' + event_name, a, b, c

		@on 'add', (waypoint) =>
			type = waypoint.get('type')

			if type == 'from'
				waypoint.on 'all', @_proxy_event_from
			else if type == 'to'
				waypoint.on 'all', @_proxy_event_to

		@on 'remove', (waypoint) =>
			type = waypoint.get('type')
			waypoint.clear() unless type == 'via'

			if type == 'from'
				waypoint.unbind 'all', @_proxy_event_from
			else if type == 'to'
				waypoint.unbind 'all', @_proxy_event_to

		@on 'reset', (new_waypoints) =>
			first = @at(0)
			first.unbind 'all', @_proxy_event_from if first

			last = @at(@length - 1)
			last.unbind 'all', @_proxy_event_to if last

			first = new_waypoints.at(0)
			last  = new_waypoints.at(new_waypoints.length - 1)

			if first and first.get('type') == 'from'
				first.on 'all', @_proxy_event_from

			if last and last.get('type') == 'to'
				last.on 'all', @_proxy_event_to
