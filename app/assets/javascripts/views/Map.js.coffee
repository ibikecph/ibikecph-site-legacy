class ibikecph.Map extends Backbone.View

	initialize: ->
		@map          = new L.Map @el.id
		@dragging_pin = false
		@pins         = {}

		@current_route = new L.Polyline [], ibikecph.config.current_route.style
		@invalid_route = new L.Polyline [], ibikecph.config.invalid_route.style
		@old_route     = new L.Polyline [], ibikecph.config.old_route.style

		@route_marker = new L.Marker null, (
			draggable : false
			icon      : ibikecph.icons.route_marker
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
			@update_route_marker event

		@map.on 'click', (event) =>
			@set_pin_by_mouse_click event

		@model.route.on 'reset', (points) =>
			@geometry_changed points

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
					@dragging_pin = true
					@old_route.setLatLngs @current_route.getLatLngs()
					@map.addLayer @old_route

				pin.on 'dragend', (event) =>
					event.target.dragged = false
					@dragging_pin = false
					@map.removeLayer @old_route

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

	update_route_marker: (event) ->
		return unless @showing_route()

		closest = @current_route.closestLayerPoint event.layerPoint

		if closest and closest.distance < 10 and not @dragging_pin
			@route_marker.setLatLng @map.layerPointToLatLng closest
			@map.addLayer @route_marker
		else
			@map.removeLayer @route_marker

	set_pin_by_mouse_click: (event) ->
		unless @model.waypoints.has_from()
			@model.endpoint('from').set 'location', event.latlng
			return

		unless @model.waypoints.has_to()
			@model.endpoint('to').set 'location', event.latlng
			return

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

	showing_route: ->
		@current_route.getLatLngs().length > 0

	geometry_changed: (points) ->
		valid  = points.length >= 2
		points = @model.waypoints.as_route_points() if not valid

		latlngs = points.map (point) ->
			new L.LatLng point.get('lat'), point.get('lng')

		if valid
			@map.addLayer    @current_route
			@map.removeLayer @invalid_route
			@current_route.setLatLngs latlngs
			@invalid_route.setLatLngs []

			unless @dragging_pin
				@map.fitBounds new L.LatLngBounds(latlngs)
				# TODO: Can we make it zoom out just a bit?

		else
			@map.removeLayer @current_route
			@map.addLayer    @invalid_route
			@current_route.setLatLngs []
			@invalid_route.setLatLngs latlngs
