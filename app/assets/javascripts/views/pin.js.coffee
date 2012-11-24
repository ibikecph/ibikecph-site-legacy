class IBikeCPH.Views.Pin extends Backbone.View

	initialize: (options) ->
		@map = options.map
		@model = options.model
		location = @model.get 'location'
		latlon = new L.LatLng location.lat, location.lng
		@marker = new L.Marker latlon, draggable: true, icon: IBikeCPH.icons[@model.get 'type']
		@map.map.addLayer @marker
		
		@model.on 'change', (event) =>
			#console.log 'model change'

		@model.on 'destroy', (event) =>
			@map.map.removeLayer @marker
			this.remove()
		
		@marker.on 'drag', (event) =>
			location = @marker.getLatLng()
			@model.set 'location', lat: location.lat, lng: location.lng

		@marker.on 'click', (event) =>
			@model.destroy()
			#model = event.target.model
			#type  = model.get 'type'
			#if type == 'from' or type == 'to'
			#	@model.clear type
			#else
			#	@model.waypoints.remove model
			#@map.removeLayer @route_marker
		