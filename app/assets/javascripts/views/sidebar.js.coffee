class IBikeCPH.Views.Sidebar extends Backbone.View
	template: JST['sidebar']
	
	events:
		'change .address input'        : 'fields_updated'
		'click .reset'                 : 'reset'
		'click .permalink'             : 'permalink'
		'change .departure'	  		     : 'change_departure'
		'change .arrival'	   		       : 'change_arrival'

	initialize: (options) ->
		Backbone.View.prototype.initialize.apply this, options
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
		@$el.html @template()
		$('.help').click (event) => @help()
		$('.fold').click (event) => @fold()
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
		#url = "#{window.location.protocol}//#{window.location.host}/#!/#{@model.waypoints.to_code()}"
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

	fields_updated: (event) ->
		input = $(event.target)
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
		value = value.replace /\b[nNøØsSvV]$/, ""					# remove north/south/east/west postfix
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
