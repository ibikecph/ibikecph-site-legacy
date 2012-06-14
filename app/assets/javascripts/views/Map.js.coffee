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

		@model.from.bind 'change:lat change:lng', @location_changed, this
		@model.to.bind   'change:lat change:lng', @location_changed, this
		@model.via.bind  'change:lat change:lng', @location_changed, this

	location_changed: (model) ->
		field_name = model.get 'field_name'
		location = new L.LatLng model.get('lat'), model.get('lng')

		if @pin[field_name]
			@pin[field_name].setLatLng location
		else
			pin = new L.Marker location, draggable: true

			pin.on 'dragend', (event) =>
				@model[field_name].set event.target.getLatLng()

			@map.addLayer pin
			@pin[field_name] = pin
