class ibikecph.Info

	constructor: ->
		@waypoints    = new ibikecph.Waypoints
		@route        = new ibikecph.Route
		@instructions = new ibikecph.Instructions
		@summary      = new ibikecph.InstructionsSummary

	endpoint: (type) ->
		@waypoints.endpoint type

	clear: (type) ->
		@waypoints.clear type
