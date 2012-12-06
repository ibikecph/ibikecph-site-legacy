# Represents the waypoints (ie. from/to/via) entered by the user.

class IBikeCPH.Collections.Waypoints extends Backbone.Collection
	model: IBikeCPH.Models.Waypoint
	
	initialize: ->
		@reset()
		@on 'remove add reset', (model) ->
			@set_endpoints @model
			
	set_endpoints: (model) ->
		@first().set 'type', 'from'
		@last().set 'type', 'to'
	
	reset: (models) ->
		@each (t) ->
			t.set 'location', null
			t.set 'address', null
		Backbone.Collection.prototype.reset.call this, models, silent: true;
		unless models
			waypoint = new IBikeCPH.Models.Waypoint type: 'from'
			@add waypoint, (at: 0), silent: true
			waypoint = new IBikeCPH.Models.Waypoint type: 'to'
			@add waypoint, (at: 1), silent: true
		@trigger 'reset'
		
	all_located: ->
		@all (waypoint) -> waypoint.located()

	# Converts the waypoints into route points, used to display invalid/unknown routes.
	to_latlngs: ->
		_.filter @map((model) -> model.to_latlng()), (location) -> location

	to_url: ->
		return null unless @all_located()
		codes = @map (waypoint) -> waypoint.to_str()
		return codes.join '/'

	reset_from_url: (code) ->
		codes = code.split '/'
		if codes.length > 1
			waypoints = []
			for code in codes
				waypoint = new IBikeCPH.Models.Waypoint type: 'via'
				waypoint.from_str code
				waypoints.push waypoint	
			@reset waypoints
			