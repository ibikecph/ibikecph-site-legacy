class ibikecph.Sidebar extends Backbone.View

	events:
		'change label input' : 'fields_updated'
		'click .pin.reset' : 'clear'
		'mousedown .pin.to, .pin.from'  : 'drag_pin_start'
		'mouseup .pin.draging'	: 'drag_pin_end'

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
			@app.map.set_pin_at field_name, event.pageX + 1, event.pageY + 24
			@draging = undefined

	initialize: (options) ->
		@app = options.app

		@model.from.bind 'change:address', @address_changed, this
		@model.to.bind   'change:address', @address_changed, this

		@model.from.bind 'change:loading', @loading_changed, this
		@model.to.bind   'change:loading', @loading_changed, this

	clear : (event) ->
		pin = $(event.target);

		label = pin;

		label = label.parent() while label[0].tagName isnt 'LABEL'

		input = $("input", label)
		input.val ''
		@fields_updated()

	address_changed: (model, address) ->
		field_name = model.get 'field_name'
		@set_field field_name, address
		@app.router.navigate_field field_name, address, trigger: false

	loading_changed: (model, loading) ->
		@set_loading model.get('field_name'), loading

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

	fields_updated: ->
		from = @get_field 'from'
		to   = @get_field 'to'
		via  = @get_field 'via'

		@app.router.navigate_route from, via, to, trigger: true
