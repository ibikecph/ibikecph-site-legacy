ibikecph.app = app = {}





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
	

	$(".ln").click (event) ->
		event.preventDefault();
		href = $(this).attr('href') + $('.permalink').attr('href');
		window.location = href;


	$(window).trigger 'resize'

	$('.instructions').live 'click', ->
		$(this).remove()
	$('a.guide').click (event) ->
		event.preventDefault()
		if app.info.instructions.length
			end = false
			if $('.instructions').length
				end = true
			$('.instructions').remove()
			if end then return
			el = $('<div>', class : 'instructions')
			app.info.instructions.each (instruction) ->
				instruction_el = $('<div>', class : 'instruction')
				text = ibikecph.util.instruction_string instruction.toJSON();

				instruction_el.html(text)
				el.append instruction_el
				$('body').prepend(el);
			app.info.instructions.bind 'reset', ->
				el.remove()

