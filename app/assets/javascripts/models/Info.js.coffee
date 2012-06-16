class ibikecph.Info

	constructor: ->
		#@from = new ibikecph.Point field_name: 'from'
		#@to   = new ibikecph.Point field_name: 'to'
		#@via  = new ibikecph.Point field_name: 'via'

		@waypoints = new ibikecph.Waypoints

		@route        = new ibikecph.Route
		@instructions = new ibikecph.Instructions
		@summary      = new ibikecph.InstructionsSummary

		new ibikecph.OSRM this

	endpoint: (type) ->
		@waypoints.endpoint type

	clear: (type) ->
		@waypoints.clear type
