
class ibikecph.Sidebar extends Backbone.View

	events:
		'change label input'           : 'fields_updated'
		'click .pin.reset'             : 'clear'
		'mousedown .pin.to, .pin.from' : 'drag_pin_start'
		'mouseup .pin.draging'         : 'drag_pin_end'
		'click input.link'			   : 'select_url'
		'change input.link'			   : 'waypoints_changed'


	select_url: (event) ->
		$(event.target).select()

	drag_pin_start: (event) ->
		if $(event.target).hasClass 'reset'
			return true
		@draging = $(event.target).clone();
		$(event.target).addClass 'reset'
		$(@el).append(@draging);
		self = @
		$("html").mousemove (event) ->
			self.drag_pin_move(event)
		@draging.css position : 'fixed', left : event.pageX - 18, top : event.pageY - 20, 'z-index' : 100
		@draging.addClass 'draging'

	drag_pin_move : (event) ->
		if @draging
			@draging.css position : 'fixed', left : event.pageX - 18, top : event.pageY - 20, 'z-index' : 100

	drag_pin_end : (event) ->
		if @draging
			@draging.remove()
			field_name = @draging.removeClass('draging pin').attr('class');
			
			if not @app.map.set_pin_at field_name, event.pageX + 1, event.pageY + 24
				$('.pin.' + field_name).removeClass 'reset' 
			@draging = undefined

	initialize: (options) ->
		@app = options.app

		self = @

		@model.waypoints.bind 'from:change:address to:change:address', @address_changed, @
		@model.waypoints.bind 'from:change:loading to:change:loading', @loading_changed, @
		@model.waypoints.bind 'clear:from', ->
			self.set_field('from', '')
		@model.waypoints.bind 'clear:to', ->
			self.set_field('to', '')


		@model.waypoints.bind 'reset change', @waypoints_changed, this

		@model.summary.bind 'change', @summary_changed, @app.info.summary;

	clear : (event) ->
		pin = $(event.target);

		label = pin;

		label = label.parent() while not label.hasClass 'label'

		input = $ "input", label;

		pin.removeClass 'reset'

		input.val ''
		@fields_updated target: input

	address_changed: (model, address) ->
		field_name = model.get 'type'
		@set_field field_name, address

	loading_changed: (model, loading) ->
		@set_loading model.get('type'), loading

	waypoints_changed: ->
		url = window.location.protocol + '//' + window.location.host + '#!/' + @model.waypoints.to_code()

		if @model.waypoints.length > 1
			$('input.link').val url
			$('.label.text').show()
		else
			$('input.link').val ''
			$('.label.text').hide()

	summary_changed: ->
		meters = @.get 'total_distance'
		seconds  = @.get 'total_time'

		if meters and seconds
			$('.actions').show()
			$(".time", @el).show()
			$(".distance .count", @el).text(meters/1000 + ' km');
			$(".duration .count", @el).text(Math.floor(seconds/60 + 2) + ' min');
			d = new Date;
			d.setTime d.getTime() + seconds * 1000 + 1000 * 60 * 2;
			m = d.getMinutes();
			if m < 10
				m = '0' + m
			$(".arrival .count").text d.getHours() + ':' + m
		else
			$('.actions').hide()
			$(".time", @el).hide()

	get_field: (field_name) ->
		return @$("input.#{field_name}").val() or ''

	set_field: (field_name, text) ->
		if text 
			$("div.#{field_name}").addClass 'reset'
		else
			$("div.#{field_name}").removeClass 'reset'			
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
		value = ibikecph.util.normalize_whitespace raw_value

		input.val(value) if value != raw_value

		if value
			@model.endpoint(type).set 'address', value
		else
			@model.clear type
