class ibikecph.RoutePoint extends Backbone.Model

	to_latlng: ->
		return new L.LatLng @get('lat'), @get('lng')
