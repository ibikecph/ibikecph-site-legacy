class ibikecph.Map extends Backbone.View

	initialize: ->
		@map          = new L.Map @el.id, zoomControl : false
		@dragging_pin = false
		@pins         = {}

		@route_point_index = []

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

		@route_marker.on 'mousedown', (event) =>
			@create_via_point event

		@map.on 'mousemove', (event) =>
			@update_route_marker event

		@map.on 'click', (event) =>
			@set_pin_by_mouse_click event

		@model.route.on 'reset', (points) =>
			@geometry_changed points

		@model.route.on 'add remove change', =>
			# TODO: Are the events sent before or after the collection is updated?
			@geometry_changed @model.route

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
					window.location.hash = ''
					location = event.target.getLatLng()
					event.target.model.set 'location', (
						lat: location.lat
						lng: location.lng
					)

				pin.on 'click', (event) =>
					model = event.target.model
					type  = model.get 'type'
					if type == 'from' or type == 'to'
						@model.clear type
					else
						@model.waypoints.remove model
					@map.removeLayer @route_marker

				@map.addLayer pin
		else if pin
			@map.removeLayer pin
			delete @pins[cid]

		return pin

	update_route_marker: (event) ->
		return unless @showing_route()

		closest = @current_route.closestLayerPoint event.layerPoint

		if closest and closest.distance < 10 and not @dragging_pin
			@route_marker.setLatLng @map.layerPointToLatLng closest
			@map.addLayer @route_marker
		else
			@map.removeLayer @route_marker

	create_via_point: (event) ->
		location = event.target.getLatLng()

		waypoint = new ibikecph.Waypoint
			type     : 'via'
			location : location

		@model.waypoints.add waypoint, at: @closest_waypoint_index(location)

		via_marker = @waypoint_show_hide_update waypoint, false

		# Fake an initial dragstart event, so that the new via marker is actually dragged.
		via_marker.dragging._draggable._onDown event.originalEvent

		@map.removeLayer @route_marker

	closest_waypoint_index: (location) ->
		seg_index = @closest_route_point_index location

		if seg_index < 1
			seg_index = 1
		else if seg_index > @route_point_index.length - 1
			seg_index = @route_point_index.length - 1

		return @route_point_index[seg_index] or 1

	closest_route_point_index: (location) ->
		min_distance = Infinity
		closest      = 0

		for route_point, index in @current_route.getLatLngs()
			distance = route_point.distanceTo location

			if distance < min_distance
				min_distance = distance
				closest      = index

		return closest

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

		return false if x < 0 or y < 0 or x >= width or y >= height

		position = new L.Point x, y
		location = @map.layerPointToLatLng @map.containerPointToLayerPoint position

		@model.endpoint(field_name).set 'location', location

	showing_route: ->
		@current_route.getLatLngs().length > 0

	geometry_changed: (route) ->
		valid  = route.length >= 2
		route = @model.waypoints.as_route_points() if not valid

		latlngs = route.map (point) -> 
			point.to_latlng();

		@update_route_point_index @model.waypoints.to_latlngs(), latlngs

		if valid
			@map.addLayer    @current_route
			@map.removeLayer @invalid_route
			@current_route.setLatLngs latlngs
			@invalid_route.setLatLngs []

			#autozoom
			#@map.fitBounds new L.LatLngBounds(latlngs).pad(1) unless @dragging_pin

		else
			@map.removeLayer @current_route
			@map.addLayer    @invalid_route
			@current_route.setLatLngs []
			@invalid_route.setLatLngs latlngs

	update_route_point_index: (waypoints, route) ->
		@route_point_index = []

		return unless waypoints.length >= 2 and route.length >= 2

		reverse_index = []

		# Map 'to' endpoint
		reverse_index.push [waypoints.length - 1, route.length]

		for i in [1...waypoints.length-1]
			waypoint = waypoints[i]

			min_distance = Infinity
			closest      = 0

			# Brute-force search for nearest via waypoint
			for j in [1...route.length-1]
				route_point = route[j]
				distance    = route_point.distanceTo waypoint

				if distance < min_distance
					min_distance = distance
					closest      = j

			reverse_index.push [i, closest]

		reverse_index.sort (a, b) -> a[1] - b[1]

		last_waypoint    = 0
		last_route_point = 0
		for [waypoint, route_point] in reverse_index
			for i in [last_route_point...route_point]
				@route_point_index[i] = last_waypoint + 1
			last_waypoint    = waypoint
			last_route_point = route_point
