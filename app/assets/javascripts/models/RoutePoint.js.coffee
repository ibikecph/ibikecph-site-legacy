class ibikecph.RoutePoint extends Backbone.Model

	to_latlng: ->
		new L.LatLng @get('lat'), @get('lng')
