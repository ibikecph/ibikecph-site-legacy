class ibikecph.Map extends Backbone.View

	initialize: ->
		@map = new L.Map @el.id

		@pin =
			from : null
			to   : null
			via  : null

		@path = null

		layers_control = new L.Control.Layers
		for tileset, index in ibikecph.config.tiles
			layer = new L.TileLayer tileset.url, tileset.options
			layers_control.addBaseLayer layer, tileset.name
			@map.addLayer(layer) if index == 0
		@map.addControl layers_control

		initial_location = new L.LatLng ibikecph.config.start.lat, ibikecph.config.start.lng
		@map.setView initial_location, ibikecph.config.start.zoom

		@model.from.bind 'change:location', @location_changed, this
		@model.to.bind   'change:location', @location_changed, this
		@model.via.bind  'change:location', @location_changed, this

		@model.route.bind 'reset', @geometry_changed, this

	set_pin_at: (field_name, x, y) ->
		offset = $(@el).offset()
		width  = $(@el).width()
		height = $(@el).height()
		x -= offset.left
		y -= offset.top

		return if x < 0 or y < 0 or x >= width or y >= height

		position = new L.Point x, y
		location = @map.layerPointToLatLng @map.containerPointToLayerPoint position

		@model[field_name].set 'location', location

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
