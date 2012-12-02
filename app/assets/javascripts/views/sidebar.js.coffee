class IBikeCPH.Views.Sidebar extends Backbone.View
	template: JST['sidebar']
	
	events:
		'change .address input'        : 'fields_updated'
		'click .reset'                 : 'reset'
		'click input.link'             : 'select_all'
		'change input.link'            : 'waypoints_changed'
		'click .fold'                  : 'fold'
		'change .departure'	  		     : 'change_departure'
		'change .arrival'	   		       : 'change_arrival'
		'click #instructions .step'	   : 'zoom_to_instruction'


	initialize: (options) ->
		Backbone.View.prototype.initialize.apply this, options
		@router = options.router
		
		@model.waypoints.on 'from:change:address to:change:address reset', (model, address) =>
			@set_field model.get('type'), address
		@model.waypoints.on 'from:change:loading to:change:loading reset', (model, loading) =>
			@set_loading model.get('type'), loading

		@model.waypoints.on 'clear:from reset', =>
			@set_field 'from', ''
		@model.waypoints.on 'clear:to reset', =>
			@set_field 'to', ''

		@model.waypoints.on 'reset change', =>
			@waypoints_changed()
		
		
		@departure = @getNow()
		@model.summary.on 'change', @update_departure_arrival, this
	
	render: ->
		@$el.html @template()
		this

	getNow: ->
		now = new Date()
		now.setSeconds 0		#avoid minutes that are off by one
		now
		
	zoom_to_instruction: (event) ->
		path = _.find @router.map.map._layers, (layer) ->
			if layer._latlngs?
				return true
		point = path._latlngs[ $(event.target).attr('data-index') ]
		@router.map.go_to_point point
	
	help: (event) ->
		$('#help').toggle()

	fold: (event) ->
		$(@el).toggleClass('hidden')
	
	select_all: (event) ->
		$(event.target).select()

	reset: ->
		@model.reset()
		@departure = undefined
		@arrival = undefined
		@update_departure_arrival()
		@departure = @getNow()
		
		
	waypoints_changed: ->
		#$('IBikeCPH.Collections.Waypoints').hide()
		return if @router.map.dragging_pin
		#$('IBikeCPH.Collections.Waypoints').remove()
		if @model.instructions.length
			url = "#{window.location.protocol}//#{window.location.host}/#!/#{@model.waypoints.to_code()}"
			$('a.permalink').attr href : url
		else
			$('a.permalink').attr href : '#'
			#$('#summary').hide()
			#$('IBikeCPH.Collections.Waypoints').hide()
	
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
		#hide/show clear buttons
		if(text)
			@$("p.#{field_name}").show()
		else
			@$("p.#{field_name}").hide()

		@$(".#{field_name}").val "#{text}"

	set_loading: (field_name, loading) ->
		@$(".#{field_name}").toggleClass 'loading', !!loading

	fields_updated: (event) ->
		input = $(event.target)

		if input.is '.from'
			type = 'from'
		else if input.is '.to'
			type = 'to'
		else
			return
		
		raw_value = input.val()
		value = IBikeCPH.util.normalize_whitespace raw_value
		
		#be a little smarter when parsing adresses, to make nominatim happier
		value = value.replace /\b[kK][bB][hH]\b/g, "København"		# kbh -> København
		value = value.replace /\b[nNøØsSvV]$/, ""					# remove north/south/east/west postfix
		value = value.replace /(\d+)\s+(\d+)/, "$1, $2"				# add comma between street nr and zip code
		
		input.val(value) if value != raw_value

		if value
			#TODO @model.endpoint(type).set 'address', value
		else
			@model.clear type