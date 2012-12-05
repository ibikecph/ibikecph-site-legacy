class IBikeCPH.Routers.Map extends Backbone.Router

	routes:
		'': 'index'
		'!/*code': 'show_route'

	initialize: ->
		@search = new IBikeCPH.Models.Search

		#TODO
		#@search.waypoints.on 'from:change:address to:change:address reset', ->
		#	if _gaq? and not app.map.dragging_pin
		#		{from, to} = app.info.waypoints.get_from_and_to()
    #
		#		from = from.get 'address' if from
		#		to   = to.get   'address' if to
    #
		#		_gaq.push ['_trackEvent', 'location', 'from', from] if from
		#		_gaq.push ['_trackEvent', 'location', 'to'  , to  ] if to
		#		_gaq.push ['_trackEvent', 'location', 'route', "#{from} -- #{to}"] if from and to
				
		@map = new IBikeCPH.Views.Map model: @search, el: '#map', router: this
		@sidebar = new IBikeCPH.Views.Sidebar model: @search, el: '#search', router: this
		@summary = new IBikeCPH.Views.Summary model: @search.summary, el: '#summary', router: this
		@instructions = new IBikeCPH.Views.Instructions collection: @search.instructions, el: '#instructions_div'

		$(window).on 'resize', ->
			$('#map').height $(window).height() - $('#header').height()

		$('.ln').click (event) ->
			event.preventDefault()
			href = $(this).attr('href') + $('.permalink').attr('href')
			window.location = href

		$(window).trigger 'resize'
		@sidebar.render()
		
	show_route: (code) ->
		#TODO @app.info.waypoints.reset_from_code code

	update: ->
		@navigate '!/' + @app.info.waypoints.to_code(), trigger: false
