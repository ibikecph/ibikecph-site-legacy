# The time, distance and arrival time for a given route.

class IBikeCPH.Models.Summary extends Backbone.Model
	
	defaults:
		total_distance: undefined
		total_time: undefined
	
	reset: ->
		@trigger 'reset'