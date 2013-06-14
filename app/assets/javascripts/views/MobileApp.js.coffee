class IBikeCPH.Views.MobileApp extends Backbone.View
	template: JST['mobileapp']

	initialize: ->

	render: ->
		@$el.html @template()
		@toggle
		this