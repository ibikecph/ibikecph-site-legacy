# Represents the waypoints (ie. from/to/via) entered by the user.

class IBikeCPH.Collections.Waypoints extends Backbone.Collection
	model: IBikeCPH.Models.Waypoint
	
	initialize: ->
		waypoint = new IBikeCPH.Models.Waypoint type: 'from'
		@add waypoint, at: 0
		waypoint = new IBikeCPH.Models.Waypoint type: 'to'
		@add waypoint, at: 1
		
		@on 'remove', (model) ->
			@waypoint_removed model
			
	waypoint_removed: (model) ->
		@to().set 'type', 'to'
		@from().set 'type', 'from'

	from: ->
		@first()

	to: ->
		@last()
	
	all_located: ->
		@all (waypoint) -> waypoint.located()
		
	get_from_and_to: ->
		from = @at(0)
		to = @at(@length - 1)

		from = null unless from?.get and from.get('type') == 'from'
		to = null unless to?.get and to.get('type') == 'to'

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