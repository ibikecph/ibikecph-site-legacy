class ibikecph.Router extends Backbone.Router

	routes:
		'!/*code': 'show_route'


	initialize: (options) ->
		@app = options.app

	show_route: (code) ->
		@app.info.waypoints.reset_from_code code

	update: ->
		@navigate '!/' + @app.info.waypoints.to_code(), trigger: false
