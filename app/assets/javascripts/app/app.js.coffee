ibikecph.app = app = {}

$(window).bind 'resize', ->
	$('#map').height $(window).height() - $('#header').height()

jQuery ->
	$('#help .help').click (event) ->
		event.preventDefault()
		$('#help').toggle()

app.start = ->
	app.start = -> null

	app.info = new ibikecph.Info

	app.info.waypoints.on 'from:change:address to:change:address reset', ->
		if _gaq? and not app.map.dragging_pin
			{from, to} = app.info.waypoints.get_from_and_to()

			from = from.get 'address' if from
			to   = to.get   'address' if to

			_gaq.push ['_trackEvent', 'location', 'from', from] if from
			_gaq.push ['_trackEvent', 'location', 'to'  , to  ] if to
			_gaq.push ['_trackEvent', 'location', 'route', "#{from} -- #{to}"] if from and to

	app.osrm = new ibikecph.OSRM app.info, ibikecph.config.routing_service.url

	app.sidebar = new ibikecph.Sidebar
		model : app.info
		el    : '#ui'
		app   : app

	app.map = new ibikecph.Map
		model : app.info
		el    : '#map'
		app   : app

	app.map.on 'zoom', (event) =>
		app.osrm.set_zoom event.zoom

	app.map.on 'dragging_pin', (event) =>
		app.osrm.set_instructions not event.dragging_pin

	app.router = new ibikecph.Router app: app

	Backbone.history.start()


	$('.ln').click (event) ->
		event.preventDefault()
		href = $(this).attr('href') + $('.permalink').attr('href')
		window.location = href

	$(window).trigger 'resize'
