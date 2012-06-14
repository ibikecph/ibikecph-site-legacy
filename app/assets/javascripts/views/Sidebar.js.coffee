window.ibikecph or= {}

window.ibikecph.Sidebar = Backbone.View.extend

	events:
		'change .from' : 'fields_updated'
		'change .to'   : 'fields_updated'
		'change .via'  : 'fields_updated'

	initialize: (options) ->
		@app = options.app

		@model.from.bind 'change:address', @address_changed, this
		@model.to.bind   'change:address', @address_changed, this
		@model.via.bind  'change:address', @address_changed, this

		@model.from.bind 'change:loading', @loading_changed, this
		@model.to.bind   'change:loading', @loading_changed, this
		@model.via.bind  'change:loading', @loading_changed, this

	address_changed: (model, address) ->
		@set_field model.get('field_name'), address

	loading_changed: (model, loading) ->
		@set_loading model.get('field_name'), loading

	get_field: (field_name) ->
		return @$('.' + field_name).val()

	set_field: (field_name, text) ->
		@$('.' + field_name).val "#{text}"

	set_loading: (field_name, loading) ->
		@$('.' + field_name).toggleClass 'loading', !!loading

	fields_updated: ->
		from = @get_field 'from'
		to   = @get_field 'to'
		via  = @get_field 'via'

		@app.router.navigate_route from, via, to
