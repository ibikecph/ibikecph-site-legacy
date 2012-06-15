class ibikecph.Sidebar extends Backbone.View

	events:
		'change .from' : 'fields_updated'
		'change .to'   : 'fields_updated'
		'change .via'  : 'fields_updated'
		'mouseenter label' : 'show_delete'
		'mouseleave label' : 'hide_delete'
		'click .delete' : 'clear'


	show_delete: (event) ->
		label = $(event.target)

		label = label.parent() while label[0].tagName isnt 'LABEL'
		
		label.prepend('<div class="delete">');


	hide_delete: (event) ->
		$(".delete").remove();

	clear: (event) ->
		del = $(event.target);

		parent = del;

		parent = parent.parent() while parent[0].tagName isnt 'LABEL'

		$("input", parent).val('').trigger('change');


	initialize: (options) ->
		@app = options.app

		@model.from.bind 'change:address', @address_changed, this
		@model.to.bind   'change:address', @address_changed, this
		@model.via.bind  'change:address', @address_changed, this

		@model.from.bind 'change:loading', @loading_changed, this
		@model.to.bind   'change:loading', @loading_changed, this
		@model.via.bind  'change:loading', @loading_changed, this

	address_changed: (model, address) ->
		field_name = model.get 'field_name'
		@set_field field_name, address

		@app.router.navigate_field field_name, address, trigger: false

	loading_changed: (model, loading) ->
		@set_loading model.get('field_name'), loading

	get_field: (field_name) ->
		return @$(".#{field_name}").val()

	set_field: (field_name, text) ->
		@$(".#{field_name}").val "#{text}"

	set_loading: (field_name, loading) ->
		@$(".#{field_name}").toggleClass 'loading', !!loading

	fields_updated: ->
		from = @get_field 'from'
		to   = @get_field 'to'
		via  = @get_field 'via'

		@app.router.navigate_route from, via, to, trigger: true
