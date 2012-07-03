# Represents the waypoints (ie. from/to/via) entered by the user.

class ibikecph.Waypoints extends Backbone.Collection
	model: ibikecph.Waypoint

	initialize: ->
		@_setup_event_proxy()

	reset: (models, options) ->
		models || (models = []);
		options || (options = {});
		this._reset();
		@.models = models;
		this.trigger 'reset', @, options  if options.silent isnt false
		return this 

	# Returns the model for the from/to endpoint.

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

	# Clears the from/to endpoint. If there are via points, then the next via
	# point will become an endpoint and the proper events are triggered.
	clear: (type) ->
		last = (type == 'end' || type == 'to')

		if last
			if @has_to()
				@remove [@at @length - 1]
				next = @length - 1
				if next > 0
					model = @at(next)
					model.set 'type', 'to'
					@trigger 'to:change:location', model, model.get('location')
					@trigger 'to:change:address' , model, model.get('address')
					@trigger 'to:change', model
				else
					@trigger 'clear:to'
		else
			if @has_from()
				@remove [@at 0]
				next = 0
				if next < @length - 1
					model = @at(next)
					model.set 'type', 'from'
					@trigger 'from:change:location', model, model.get('location')
					@trigger 'from:change:address' , model, model.get('address')
					@trigger 'from:change', model
				else
					@trigger 'clear:from'

	has_from: ->
		waypoint = @at(0)
		waypoint?.get and waypoint.get('type') == 'from'

	has_to: ->
		waypoint = @at(@length - 1)
		waypoint?.get and waypoint.get('type') == 'to'

	has_valid_from: ->
		@has_from() and @at(0).valid_location()

	has_valid_to: ->
		@has_to() and @at(@length - 1).valid_location()

	has_endpoints: ->
		@has_from() and @has_to()

	# Converts the waypoints into route points, used to display invalid/unknown routes.
	as_route_points: ->
		_.filter(@map((model) ->
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

		), (model) -> model)

	to_latlngs: ->
		_.map @as_route_points(), (point) -> point.to_latlng()

	to_code: ->
		codes = @map (waypoint) -> waypoint.to_code()

		codes.unshift '' unless @has_from()
		codes.push    '' unless @has_to()

		return codes.join '/'

	# Initialize collection with a string representation, fx. when the user is
	# linking to a specific route.
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

	# Event magic to forward events fromt the models of the from/to endpoints to
	# observers of this collection. This is a bit difficult, since the events
	# must be unregistered from the models that are removed or when resetting the
	# whole collection.
	_setup_event_proxy: ->
		@_proxy_event_from = (event_name, a, b, c) =>
			@trigger 'from:' + event_name, a, b, c

		@_proxy_event_to = (event_name, a, b, c) =>
			@trigger 'to:' + event_name, a, b, c

		@on 'change:type add', (waypoint) =>
			type = waypoint.get('type')

			if type == 'from'
				waypoint.unbind 'all', @_proxy_event_from
				waypoint.on     'all', @_proxy_event_from
			else if type == 'to'
				waypoint.unbind 'all', @_proxy_event_to
				waypoint.on     'all', @_proxy_event_to

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
				first.unbind 'all', @_proxy_event_from
				first.on     'all', @_proxy_event_from

			if last and last.get('type') == 'to'
				last.unbind 'all', @_proxy_event_to
				last.on     'all', @_proxy_event_to
