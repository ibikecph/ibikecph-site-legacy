ibikecph.app = app = {}

$(window).resize ->
	w = $(window).width()
	h = $(window).height()
	m = parseInt($('body').css('margin-left' ), 10) * 2
	p = parseInt($('body').css('padding-left'), 10) * 2
	tb = $('#topbar').outerHeight()
	$('body').height(h - p - m)
	$('#viewport').height h - p - m - 2 - tb;
	$("#topbar").width w - m - p - 2;


app.start = ->
	app.start = ->  null

	app.info = new ibikecph.Info

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
	$(window).trigger('resize')

