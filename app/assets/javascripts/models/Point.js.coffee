window.ibikecph or= {}

window.ibikecph.Point = Backbone.Model.extend

	defaults:
		address : ''
		lat     : null
		lng     : null
		loading : false

	initialize: ->
		new ibikecph.Geocoder this
