ibikecph.app = app = {}

$(window).bind 'resize', ->
	$("div.instructions").height $(window).height() - $('#topbar').outerHeight(true) - 35



app.start = ->
	app.start = ->  null

	app.info = new ibikecph.Info

	new ibikecph.OSRM app.info, ibikecph.config.routing_service.url

	app.sidebar = new ibikecph.Sidebar
		model : app.info
		el    : '#topbar'
		app   : app

	app.map = new ibikecph.Map
		model : app.info
		el    : '#map'
		app   : app

	app.router = new ibikecph.Router app: app

	Backbone.history.start()
	

	$(".ln").click (event) ->
		event.preventDefault();
		href = $(this).attr('href') + $('.permalink').attr('href');
		window.location = href;


	$(window).trigger 'resize'

