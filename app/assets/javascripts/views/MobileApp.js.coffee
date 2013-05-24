class IBikeCPH.Views.MobileApp extends Backbone.View
	template: JST['mobileapp']

	initialize: ->
		$("#mobile_app a").click ->
			$(this).parent().toggleClass "selected"
			$("#mobileapp").toggleClass 'rendered'
			return false

	render: ->
		@$el.html @template()
		@toggle
		this