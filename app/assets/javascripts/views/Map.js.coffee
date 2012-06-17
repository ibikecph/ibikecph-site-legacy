class ibikecph.Map extends Backbone.View

	initialize: ->
		@map      = new L.Map @el.id
		@dragging = false
		@pins     = {}

		@path = null
		@path_marker = new L.Marker null, (
			draggable : false
			icon      : ibikecph.icons.path_marker
		)

		layers_control = new L.Control.Layers
		for tileset, index in ibikecph.config.tiles
			layer = new L.TileLayer tileset.url, tileset.options
			layers_control.addBaseLayer layer, tileset.name
			@map.addLayer(layer) if index == 0
		@map.addControl layers_control

		initial_location = new L.LatLng ibikecph.config.start.lat, ibikecph.config.start.lng
		@map.setView initial_location, ibikecph.config.start.zoom

		@map.on 'mousemove', (event) =>
			@mouse_moved event

		@model.route.on 'reset', @geometry_changed, this

		@model.waypoints.on 'change:location change:type', (model) =>
			@waypoint_added_or_updated model

		@model.waypoints.on 'add', (model) =>
			@waypoint_added_or_updated model

		@model.waypoints.on 'remove', (model) =>
			@waypoint_removed model

		@model.waypoints.on 'reset', (collection) =>
			@waypoints_reset collection

	waypoint_added_or_updated: (model) ->
		@waypoint_show_hide_update model, false

	waypoint_removed: (model) ->
		@waypoint_show_hide_update model, true

	waypoints_reset: (collection) ->
		for cid, pin of @pins
			@waypoint_show_hide_update pin.model, true

		for model in collection.models
			@waypoint_show_hide_update model, false

	waypoint_show_hide_update: (model, remove) ->
		field_name = model.get 'type'
		location   = model.get 'location'
		cid        = model.cid
		pin        = @pins[cid]

		if location.lat? and location.lng? and not remove
			location = new L.LatLng location.lat, location.lng
		else
			location = null

		if location
			if pin
				unless pin.dragged
					pin.setLatLng location
					pin.setIcon ibikecph.icons[field_name]
			else
				pin = new L.Marker location, (
					draggable : true
					icon      : ibikecph.icons[field_name]
				)
				pin.model = model
				@pins[cid] = pin

				pin.on 'dragstart', (event) =>
					event.target.dragged = true
					@dragging = true

				pin.on 'dragend', (event) =>
					event.target.dragged = false
					@dragging = false

				pin.on 'drag', (event) =>
					location = event.target.getLatLng()
					event.target.model.set 'location', (
						lat: location.lat
						lng: location.lng
					)

				@map.addLayer pin
		else if pin
			@map.removeLayer pin
			delete @pins[cid]

	mouse_moved: (event) ->
		return unless @path

		closest = @path.closestLayerPoint event.layerPoint
		if closest and closest.distance < 10 and not @dragging
			@path_marker.setLatLng @map.layerPointToLatLng closest
			@map.addLayer @path_marker
		else
			@map.removeLayer @path_marker

	set_pin_at: (field_name, x, y) ->
		offset = $(@el).offset()
		width  = $(@el).width()
		height = $(@el).height()
		x -= offset.left
		y -= offset.top

		return if x < 0 or y < 0 or x >= width or y >= height

		position = new L.Point x, y
		location = @map.layerPointToLatLng @map.containerPointToLayerPoint position

		@model.endpoint(field_name).set 'location', location

	geometry_changed: (points) ->
		latlngs = points.map (point) ->
			new L.LatLng point.get('lat'), point.get('lng')

		@map.removeLayer(@path) if @path

		@path = new L.Polyline latlngs, color: ibikecph.config.path.color
		#@map.fitBounds new L.LatLngBounds(latlngs)
		@map.addLayer @path
