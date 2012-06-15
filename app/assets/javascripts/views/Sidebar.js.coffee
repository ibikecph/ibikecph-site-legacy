class ibikecph.Sidebar extends Backbone.View

	events:
		'change label input' : 'fields_updated'
		'click .pin.reset' : 'clear'

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
		input.trigger 'change'


	address_changed: (model, address) ->
		field_name = model.get 'field_name'
		@set_field field_name, address
		@app.router.navigate_field field_name, address, trigger: false

	loading_changed: (model, loading) ->
		@set_loading model.get('field_name'), loading

	get_field: (field_name) ->
		return @$("input.#{field_name}").val()

	set_field: (field_name, text) ->
		console.log('text',text);
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
		via   = @get_field 'via'


		@app.router.navigate_route from, via, to, trigger: true
