ibikecph.app = app = {}

$(window).resize ->
	w = $(window).width()
	h = $(window).height()
	# Left and right margin
	m = parseInt($('body').css('margin-left' ), 10) * 2
	p = parseInt($('body').css('padding-left'), 10) * 2
	sb = $('#sidebar').outerWidth()
	$('body').height(h - p - m)
	$('#sidebar').height(h - p - m - 2)
	$('#viewport').height(h - p - m - 2)
	$('#viewport').width(w - sb - p - m - 2)


app.start = ->
	app.start = ->  null

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
	$(window).trigger('resize')

