window.IBikeCPH =
	Models: {}
	Collections: {}
	Views: {}
	Routers: {}
	
	initialize: ->
		new IBikeCPH.Routers.Map
		Backbone.history.start()

$(document).ready ->
	IBikeCPH.initialize()