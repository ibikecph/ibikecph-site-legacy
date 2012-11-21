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
		
		@marker.on 'dragstart', (event) =>
			console.log 'dragstart'
			#event.target.dragged = true
			#@dragging_pin = true
			#@old_route.setLatLngs @current_route.getLatLngs()
			#@map.addLayer @old_route
			#@trigger 'dragging_pin', dragging_pin: @dragging_pin

		@marker.on 'dragend', (event) =>
			console.log 'dragend'
			#event.target.dragged = false
			#@dragging_pin = false
			#@map.removeLayer @old_route
			#@trigger 'dragging_pin', dragging_pin: @dragging_pin

		@marker.on 'drag', (event) =>
			console.log 'drag'
			#location = event.target.getLatLng()
			#event.target.model.set 'location', (
			#	lat: location.lat
			#	lng: location.lng
			#)

		@marker.on 'click', (event) =>
			@model.destroy()
			#model = event.target.model
			#type  = model.get 'type'
			#if type == 'from' or type == 'to'
			#	@model.clear type
			#else
			#	@model.waypoints.remove model
			#@map.removeLayer @route_marker
		