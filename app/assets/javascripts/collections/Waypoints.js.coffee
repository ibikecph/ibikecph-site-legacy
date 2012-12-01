# Represents the waypoints (ie. from/to/via) entered by the user.

class IBikeCPH.Collections.Waypoints extends Backbone.Collection
	model: IBikeCPH.Models.Waypoint
	
	initialize: ->
		@on 'remove', (model) -> 
			@waypoint_removed model
		
	waypoint_removed: (model) ->
		if @length > 1
			@first().set 'type', 'from', silence: true
			@last().set 'type', 'to', silence: true
			@trigger 'change'
	
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