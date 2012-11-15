# Holds references to all the important models and collections for a given
# instance of the app. Also contains the route (model attribute `route`) as a
# compressed string, see OSRM API documentation.

class IBikeCPH.Models.Search extends Backbone.Model

	initialize: ->
		@waypoints    = new IBikeCPH.Models.Waypoints
		@instructions = new IBikeCPH.Models.Instructions
		@summary      = new IBikeCPH.Models.Summary

	endpoint: (type) ->
		@waypoints.endpoint type

	clear: (type) ->
		@waypoints.clear type
