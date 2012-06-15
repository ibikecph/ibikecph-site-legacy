class ibikecph.Map extends Backbone.View

	initialize: ->
		@map = new L.Map @el.id

		@pin =
			from : null
			to   : null
			via  : null

		open_street_map = new L.TileLayer ibikecph.config.tiles.url, ibikecph.config.tiles.options

		initial_location = new L.LatLng ibikecph.config.start.lat, ibikecph.config.start.lng
		@map.setView(initial_location, ibikecph.config.start.zoom).addLayer(open_street_map)

		@model.from.bind 'change:location', @location_changed, this
		@model.to.bind   'change:location', @location_changed, this
		@model.via.bind  'change:location', @location_changed, this

	location_changed: (model) ->
		field_name = model.get 'field_name'
		location   = model.get 'location'

		return unless location?.lat? and location.lng?

		location = new L.LatLng location.lat, location.lng

		if @pin[field_name]
			@pin[field_name].setLatLng location
		else
			pin = new L.Marker location, draggable: true

			pin.on 'drag', (event) =>
				location = event.target.getLatLng()
				@model[field_name].set 'location', (
					lat: location.lat
					lng: location.lng
				)

			@map.addLayer pin
			@pin[field_name] = pin
