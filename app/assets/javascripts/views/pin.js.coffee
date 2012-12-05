class IBikeCPH.Views.Pin extends Backbone.View

	initialize: (options) ->
		@model = options.model
		location = @model.get 'location'
		latlng = new L.LatLng location.lat, location.lng
		@marker = new L.Marker latlng, draggable: true, icon: IBikeCPH.icons[@model.get 'type']
		
		@model.on 'change:type',  =>
			@marker.setIcon IBikeCPH.icons[@model.get 'type']

		@model.on 'change:location', =>
			location = @model.get 'location'
			if location
				latlng = new L.LatLng location.lat, location.lng
				@marker.setLatLng latlng

		@marker.on 'click', (event) =>
			@trigger 'click', this

		@drag_pause = _.debounce =>
			@model.trigger 'input:location'
		, 100
		
		@marker.on 'drag', (event) =>
			@model.set 'location', @marker.getLatLng()
			@model.set 'address', null
			@drag_pause()