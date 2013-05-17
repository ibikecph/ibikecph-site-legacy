class IBikeCPH.Views.MobileApp extends Backbone.View
	template: JST['mobileapp']

	render: ->
		@$el.html @template()
		this
		
	toggle: ->
		console.log "toggle"
		return false