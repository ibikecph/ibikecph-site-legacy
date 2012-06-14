window.ibikecph or= {}

window.ibikecph.app = app = {}

app.start = ->
	app.start = -> null # run only once

	# TODO: Debug
	# L.Icon.Default.imagePath = "#{window.location.protocol}//#{window.location.host}/img/leaflet"

	app.info = new ibikecph.Info

	app.sidebar = new ibikecph.Sidebar
		model : app.info
		el    : '#sidebar'
		app   : app

	app.map = new ibikecph.Map
		model : app.info
		el    : '#map'
		app   : app

	app.router = new ibikecph.Router app: app

	Backbone.history.start()
