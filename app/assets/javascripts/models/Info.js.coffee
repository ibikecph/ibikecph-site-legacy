# Holds references to all the important models and collections for a given
# instance of the app. Also contains the route (model attribute `route`) as a
# compressed string, see OSRM API documentation.

class ibikecph.Info extends Backbone.Model

	initialize: ->
		@waypoints    = new ibikecph.Waypoints
		@instructions = new ibikecph.Instructions
		@summary      = new ibikecph.InstructionsSummary

	endpoint: (type) ->
		@waypoints.endpoint type

	clear: (type) ->
		@waypoints.clear type
