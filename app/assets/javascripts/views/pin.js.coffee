class IBikeCPH.Views.Pin extends Backbone.View

	initialize: (options) ->
		@map = options.map
		@model = options.model
		location = @model.get 'location'
		latlon = new L.LatLng location.lat, location.lng
		@marker = new L.Marker latlon, draggable: true, icon: IBikeCPH.icons[@model.get 'type']
		@map.map.addLayer @marker
		
		@model.on 'change:type', (model) =>
			@marker.setIcon IBikeCPH.icons[model.get 'type']

		@model.on 'remove', (event) =>
			@map.map.removeLayer @marker
			@off()
			@remove()

		@marker.on 'drag', (event) =>
			location = @marker.getLatLng()
			@model.set 'location', lat: location.lat, lng: location.lng

		@marker.on 'click', (event) =>
			@model.destroy()