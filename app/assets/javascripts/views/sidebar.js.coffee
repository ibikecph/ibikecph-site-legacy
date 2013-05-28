class IBikeCPH.Views.Sidebar extends Backbone.View
	template: JST['sidebar']
	
	events:
		'change .address input'			: 'fields_updated'
		'blur .address input'			: 'hide_suggestions'
		'keydown .address input'		: 'find_suggestions'
		'click .suggestions li'			: 'update_field_from_suggestion'
		'click .reset'					: 'reset'
		'click .permalink'				: 'permalink'
		'change .departure'				: 'change_departure'
		'change .arrival'				: 'change_arrival'
		'click .reverse_route'			: 'reverse_route'

	initialize: (options) ->
		@router = options.router
				
		@model.waypoints.on 'change:address', (model) =>
			#TODO should refactor address fields into backbone views, one for each endpoint (and perhaps for via points too)
			type = model.get 'type'
			value = model.get 'address'
			@$(".from").val(value) if type=='from'
			@$(".to").val(value) if type=='to'
		
		@model.waypoints.on 'reset', =>
			@set_field 'from', null
			@set_field 'to', null

		@departure = @getNow()
		@model.summary.on 'change', @update_departure_arrival, this

	render: ->
		m = @model
		@$el.html @template()
		$('.help').click (event) => @help()
		$('.fold').click (event) => @fold()
		$('.search_bottom .report').click (event) ->
			@report = new IBikeCPH.Views.ReportIssue model: this, el: '#report', router: @router
			@report.render(m.waypoints)
		$('.search_bottom .favorites').click (event) ->
			favourites = new IBikeCPH.Views.Favourites model: '', el: '#favorites', router: @router
			favourites.render(m.waypoints)
			return false
		this

	getNow: ->
		now = new Date()
		now.setSeconds 0		#avoid minutes that are off by one
		now

	help: ->
		$('#help').toggle()
	
	fold: ->
		$('#ui').toggleClass('folded')
		
	select_all: (event) ->
		$(event.target).select()

	reset: ->
		@model.reset()
		@router.map.reset()
		@departure = undefined
		@arrival = undefined
		@update_departure_arrival()
		@departure = @getNow()
		
	permalink: ->
		url = "#!/#{@model.waypoints.to_url()}"
		if url
			@router.navigate url, trigger: false
	
	pad_time: (min_or_hour) ->
		("00"+min_or_hour).slice -2
	
	format_time: (time, delta_seconds=0) ->
		if time
			adjusted = new Date()
			adjusted.setTime( time.getTime() + delta_seconds*1000 )
			@pad_time(adjusted.getHours()) + ':' + @pad_time(adjusted.getMinutes())
	
	parse_time: (str) ->
		time = new Date()
		time.setSeconds 0
		if /\d{1,2}[:\.]\d{1,2}/.test str  #looks like valid time? hh:mm and variations
			hours_mins = str.split /[:\.]/
			time.setHours hours_mins[0]
			time.setMinutes hours_mins[1]
		time
			
	update_departure_arrival: ->
		meters  = @router.search.summary.get 'total_distance'
		seconds  = @router.search.summary.get 'total_time'
		now = @getNow()
		valid = meters and seconds
		departure = arrival = ''
		if @departure
			departure = @format_time @departure
			arrival = @format_time @departure, seconds if valid
		else
			arrival = @format_time @arrival
			departure = @format_time @arrival, 59-seconds if valid
		$(".departure").val departure
		$(".arrival").val arrival

	change_departure: (event) ->
		time = @parse_time $(event.target).val()
		if time
			@departure = time
			@arrival = undefined
			@update_departure_arrival()
		
	change_arrival: (event) ->
		time = @parse_time $(event.target).val()
		if time
			@arrival = time
			@departure = undefined
			@update_departure_arrival()
		
	get_field: (field_name) ->
		return @$("input.#{field_name}").val() or ''

	set_field: (field_name, text) ->		
		text = '' unless text
		@$(".#{field_name}").val "#{text}"

	set_loading: (field_name, loading) ->
		@$(".#{field_name}").toggleClass 'loading', !!loading

	reverse_route: ->
		new_to = @get_field 'from'
		new_from = @get_field 'to'

		@set_field 'to', new_to
		@set_field 'from', new_from

		$(".address .to, .address .from").trigger('change')

	find_suggestions: ->
		t = @
		el = $(event.target)
		parent = el.parent()
		input = parent.find('input').attr('class')

		setTimeout (->
			val = el.val().toLowerCase()

			if val.length >= 4
				items = []
				foursquare_url = IBikeCPH.config.suggestion_service.foursquare.url+val+IBikeCPH.config.suggestion_service.foursquare.token
				oiorest_url = IBikeCPH.config.suggestion_service.oiorest.url+val+'&callback=?'

				$.getJSON oiorest_url, (data) ->
					$.each data, ->
						unless @wgs84koordinat['bredde'] is "0.0"
							items.push
								name: ''
								address: @vejnavn.navn + " " + @husnr + ", " + @postnummer.nr + " " + @postnummer.navn
								lat: @wgs84koordinat['bredde']
								lng: @wgs84koordinat['længde']

				$.getJSON foursquare_url, (data) ->
					$.each data.response.minivenues, ->
						unless @location.postalCode is ""
							items.push
								name: @name
								address: @location.address + ", " + @location.postalCode + " " + @location.city
								lat: @location.lat
								lng: @location.lng

				interval = setInterval(->
					if items.length > 0
						$('.suggestions').remove()
						suggestions = $('<ul />').addClass('suggestions')
						parent.append(suggestions)
						
						_.each items, (t,num) ->
							unless num > 5
								unless t.name is ''
									container = $('<li />').attr
										'data-name': t.name
										'data-lat': t.lat
										'data-lng': t.lng
										'data-type': input
										'class': 'poi'
									name = $('<span />').addClass('n').html(t.name+' ')
									address = t.address.replace(new RegExp("(" + preg_quote(val) + ")", "gi"), "<b style=\"color: #444;\">$1</b>")
									address = $("<span />").addClass("a").html(address)
									container.append(name).append address
								else
									container = $('<li />').attr
										'data-name': ''
										'data-lat': t.lat
										'data-lng': t.lng
										'data-type': input
										'class': 'address'
									address = t.address.replace(new RegExp("(" + preg_quote(val) + ")", "gi"), "<b style=\"color: #444;\">$1</b>")
									address = $('<span />').addClass('a').html(address)
									container.append address

								suggestions.append container
						
						clearInterval interval
				, 500)
						
			else
				return false

		), 150
	
	update_field_from_suggestion: (event) ->
		el = $(event.currentTarget)
		type = el.data('type')
		ll =
			lat: el.data('lat')
			lng: el.data('lng')
			name: el.data('name')
		
		if type is 'from'
			@model.waypoints.first().set 'location', ll
			@model.waypoints.first().trigger 'input:location'
		else if type is 'to'
			@model.waypoints.last().set 'location', ll
			@model.waypoints.last().trigger 'input:location'

		$('.address .'+type).attr
			'data-lat': ll.lat
			'data-lng': ll.lng
			'data-name': ll.name

		$('.suggestions').html('').hide()
			
	hide_suggestions: ->
		setTimeout (->
			$('.suggestions').html('').hide()
		), 200

	fields_updated: (event) ->
		input = $(event.currentTarget)
		if input.is '.from'
			waypoint = @model.waypoints.first()
		else if input.is '.to'
			waypoint = @model.waypoints.last()
		else
			return
		raw_value = input.val()
		value = IBikeCPH.util.normalize_whitespace raw_value
		
		#be a little smarter when parsing adresses, to make nominatim happier
		value = value.replace /\b[kK][bB][hH]\b/g, "København"		# kbh -> København
		value = value.replace /\b[nNøØsSvVkK]$/, ""					# remove north/south/east/west postfix
		value = value.replace /(\d+)\s+(\d+)/, "$1, $2"				# add comma between street nr and zip code
		
		input.val(value) if value != raw_value
		if value
			waypoint.set 'address', value
			waypoint.trigger 'input:address'
		else
			waypoint.reset()
			if @model.waypoints.length > 2
				@model.waypoints.remove waypoint
			else
				waypoint.trigger 'input:address'