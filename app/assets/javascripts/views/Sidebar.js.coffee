
class ibikecph.Sidebar extends Backbone.View

	events:
		'change label input'           : 'fields_updated'
		'click .reset'                 : 'reset'
		'mousedown .pin.to, .pin.from' : 'drag_pin_start'
		'mouseup .pin.draging'         : 'drag_pin_end'
		'click input.link'             : 'select_all'
		'change input.link'            : 'waypoints_changed'
		'click .close'                 : 'colapse'
		'click .expand'                : 'expand'
		'click .instructions'          : 'instructions'

	instructions : (event) ->
		event.preventDefault()

		if $("div.route:visible").length
			$("div.route").hide()
			$(".instructions").removeClass('colapse')
			return

		if @app.info.instructions.length
			$(".instructions").addClass('colapse')

			instructions = $("div.route").empty()
			$("div.route").show()
			@app.info.instructions.each (model, index)->
				if index % 2 is 0 then odd = 'even' else odd = 'odd'

				instructions.append $("<div>", class : 'instruction ' + odd).text(ibikecph.util.instruction_string(model.toJSON()))
			$(window).trigger 'resize'


	colapse : (event) ->
		$(@el).width 16
		$(@el).height 16
		$("div.instructions").hide()
		$(event.target).removeClass('close').addClass 'expand'

	expand : (event) ->
		$(@el).attr 'style', ''
		$("div.instructions").show()
		$(event.target).removeClass('expand').addClass 'close'

	select_all: (event) ->
		$(event.target).select()

	drag_pin_start: (event) ->
		if $(event.target).hasClass 'reset'
			return true
		@draging = $(event.target).clone()
		$(event.target).addClass 'reset'
		$(@el).append @draging
		$('html').mousemove (event) =>
			@drag_pin_move event
		@draging.css position : 'fixed', left : event.pageX - 18, top : event.pageY - 20, 'z-index' : 100
		@draging.addClass 'draging'

	drag_pin_move : (event) ->
		if @draging
			@draging.css position : 'fixed', left : event.pageX - 18, top : event.pageY - 20, 'z-index' : 100

	drag_pin_end : (event) ->
		if @draging
			@draging.remove()
			field_name = @draging.removeClass('draging pin').attr('class')

			if not @app.map.set_pin_at field_name, event.pageX + 1, event.pageY + 24
				$('.pin.' + field_name).removeClass 'reset' 
			@draging = undefined

	initialize: (options) ->
		@app = options.app

		@model.waypoints.bind 'from:change:address to:change:address reset', (model, address) =>
			@set_field model.get('type'), address
			if _gaq? and address
				_gaq.push ['_trackEvent', 'location', model.get 'type', address]

		@model.waypoints.bind 'from:change:loading to:change:loading reset', (model, loading) =>
			@set_loading model.get('type'), loading

		@model.waypoints.bind 'clear:from reset', =>
			@set_field 'from', ''
		@model.waypoints.bind 'clear:to reset', =>
			@set_field 'to', ''

		@model.waypoints.bind 'reset change', =>
			@waypoints_changed()

		@model.summary.bind 'change', @summary_changed, @app.info.summary

	reset: ->
		@model.waypoints.reset()

	waypoints_changed: ->

		return if @app.map.dragging_pin

		$('div.instructions').remove()

		if @model.instructions.length
			url = "#{window.location.protocol}//#{window.location.host}/#!/#{@model.waypoints.to_code()}"
			$('a.link').attr href : url
			$('.label.text').show()
		else
			$('a.link').attr href : '#'
			$('.label.text').hide()

	summary_changed: ->
		meters = @.get 'total_distance'
		seconds  = @.get 'total_time'


		if meters and seconds
			$('.actions').show()
			$(".time", @el).show()
			$(".meta", @el).show()
			$(".instructions").removeClass('colapse')


			$(".route").hide()
			$(".distance .count", @el).text(meters/1000 + ' km')
			$(".duration .count", @el).text(Math.floor(seconds/60 + 2) + ' min')
			d = new Date
			d.setTime d.getTime() + seconds * 1000 + 1000 * 60 * 2
			m = d.getMinutes()
			if m < 10
				m = '0' + m
			$(".arrival .count").text d.getHours() + ':' + m
		else
			$('.actions').hide()
			$(".time", @el).hide()
			$(".meta", @el).hide()

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
		value = ibikecph.util.normalize_whitespace raw_value

		input.val(value) if value != raw_value

		if value
			@model.endpoint(type).set 'address', value
		else
			@model.clear type
