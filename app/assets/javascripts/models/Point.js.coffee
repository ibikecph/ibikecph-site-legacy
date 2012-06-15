class ibikecph.Point extends Backbone.Model

	defaults:
		address: ''
		location:
			lat: null
			lng: null
		loading: false

	initialize: ->
		new ibikecph.Geocoder this
