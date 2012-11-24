# Represents the waypoints (ie. from/to/via) entered by the user.

class IBikeCPH.Models.Waypoints extends Backbone.Collection
	model: IBikeCPH.Models.Waypoint
	
	initialize: ->
		@_setup_event_proxy()
		@on 'remove', (model) -> @waypoint_removed model
		
	waypoint_removed: (model) ->
		#@ends['from'] = null if @ends['from'] and @ends['from'].cid == model.cid
		#@ends['to'] = null if @ends['to'] and @ends['to'].cid == model.cid
	
	add_endpoint: (latlon) ->
		if @length < 2
			if @from()?
				@add new IBikeCPH.Models.Waypoint(location: latlon, type: 'to'), at: 1
			else
				@add new IBikeCPH.Models.Waypoint(location: latlon, type: 'from'), at: 0
		
	from: ->
		waypoint = @first()
		if waypoint and waypoint.get('type')=='from'
			waypoint

	to: ->
		waypoint = @last()
		if waypoint and waypoint.get('type')=='to'
			waypoint

	has_valid_from: ->
		@from()?

	has_valid_to: ->
		@to()?

	has_endpoints: ->
		@from()? and @to()?

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
			if @from()?
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

	get_from_and_to: ->
		from = @at(0)
		to   = @at(@length - 1)

		from = null unless from?.get and from.get('type') == 'from'
		to   = null unless to?.get   and to.get('type')   == 'to'

		return (
			from : from
			to   : to
		)

	# Converts the waypoints into route points, used to display invalid/unknown routes.
	to_latlngs: ->
		_.filter @map((model) -> model.to_latlng()), (location) -> location

	to_code: ->
		codes = @map (waypoint) -> waypoint.to_code()

		codes.unshift '' unless @from()?
		codes.push    '' unless @to()?

		return codes.join '/'

	# Initialize collection with a string representation, fx. when the user is
	# linking to a specific route.
	reset_from_code: (code) ->
		waypoints = []

		for location_code in code.split '/'
			waypoint = IBikeCPH.Models.Waypoint.from_code location_code
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
