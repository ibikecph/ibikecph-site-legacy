class ibikecph.Map extends Backbone.View

	initialize: ->
		@map = new L.Map @el.id

		@pin =
			from : null
			to   : null
			via  : null

		@path = null

		open_street_map = new L.TileLayer ibikecph.config.tiles.url, ibikecph.config.tiles.options

		initial_location = new L.LatLng ibikecph.config.start.lat, ibikecph.config.start.lng
		@map.setView(initial_location, ibikecph.config.start.zoom).addLayer(open_street_map)

		@model.from.bind 'change:location', @location_changed, this
		@model.to.bind   'change:location', @location_changed, this
		@model.via.bind  'change:location', @location_changed, this

		@model.route.bind 'reset', @geometry_changed, this

	location_changed: (model) ->
		field_name = model.get 'field_name'
		location   = model.get 'location'
		lat        = location?.lat
		lng        = location?.lng
		valid      = !!(lat? and lng?)

		location = new L.LatLng lat, lng

		if @pin[field_name]
			if valid
				@pin[field_name].setLatLng location
			else
				@pin[field_name].removeLayer location
				@pin[field_name] = null
		else if valid

			pin = new L.Marker location, (
				draggable : true
				icon      : ibikecph.icons[field_name]
			)

			pin.on 'drag', (event) =>
				location = event.target.getLatLng()
				@model[field_name].set 'location', (
					lat: location.lat
					lng: location.lng
				)

			@map.addLayer pin
			@pin[field_name] = pin
 
	geometry_changed: (points) ->
		latlngs = points.map (point) ->
			new L.LatLng point.get('lat'), point.get('lng')

		@map.removeLayer(@path) if @path

		@path = new L.Polyline latlngs, color: 'red'
		#g@map.fitBounds new L.LatLngBounds(latlngs)
		@map.addLayer @path
