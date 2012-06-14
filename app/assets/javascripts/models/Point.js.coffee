class ibikecph.Point extends Backbone.Model

	defaults:
		address : ''
		lat     : null
		lng     : null
		loading : false

	initialize: ->
		new ibikecph.Geocoder this
