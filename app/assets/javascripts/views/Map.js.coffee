class IBikeCPH.Views.Map extends Backbone.View

	bounds: true

	initialize: ->
		@osrm = new IBikeCPH.OSRM @model, IBikeCPH.config.routing_service.url
		
		@map = new L.Map @el.id, zoomControl: false		#leaflet map
		@map.on 'zoom', (event) =>
			@osrm.set_zoom event.zoom

		@dragging_pin = false
		@pin_views = {}		#used to map from waypoint models to views

		@current_route = new L.Polyline [], IBikeCPH.config.route_styles.current
		@invalid_route = new L.Polyline [], IBikeCPH.config.route_styles.invalid
		@old_route     = new L.Polyline [], IBikeCPH.config.route_styles.old

		@via_marker = new L.Marker null, draggable: false, icon: IBikeCPH.icons.route_marker

		for control in IBikeCPH.config.map_controls
			switch control.type

				when 'layers'
					@layers_control = new L.Control.Layers
					@layers_control.setPosition control.position if control.position

					for tileset, index in IBikeCPH.config.map_tiles
						layer = new L.TileLayer tileset.url, tileset.options
						@layers_control.addBaseLayer layer, tileset.name
						@map.addLayer layer if index == 0
					@map.addControl @layers_control

				when 'zoom'
					@zoom_control = new L.Control.Zoom
					@zoom_control.setPosition control.position if control.position
					@map.addControl @zoom_control

				when 'goto'
					@goto_control = new L.Control.Goto
					@goto_control.setPosition control.position if control.position
					@goto_control.go_to_my_location = => @go_to_my_location()
					@goto_control.go_to_route       = => @go_to_route()
					@map.addControl @goto_control

		initial_location = new L.LatLng IBikeCPH.config.initial_location.lat, IBikeCPH.config.initial_location.lng
		@map.setView initial_location, IBikeCPH.config.initial_location.zoom

		#setTimeout =>
		#	@trigger 'zoom', zoom: @map.getZoom()
		#	@trigger 'dragging_pin', dragging_pin: @dragging_pin
		#, 1

		@via_marker.on 'mousedown', (event) =>
			@start_via_drag event
		
		@map.on 'mousemove', (event) =>
			@move_via_marker event

		@map.on 'click', (event) =>
			@click event

		@map.on 'zoomend', (event) =>
			@trigger 'zoom', zoom: @map.getZoom()

		@map.on 'locationfound', (event) =>
			@model.waypoints.a.set 'location', event.latlng unless @model.waypoints.has_valid_from()

		@model.on 'change:route', (model, compressed_route) =>
			@geometry_changed compressed_route

		@model.waypoints.on 'add', (model) =>
			@waypoint_added model

		@model.waypoints.on 'remove', (model) =>
			@waypoint_removed model

		@model.waypoints.on 'reset', (collection) =>
			@waypoints_reset collection

	go_to_my_location: ->
		@map.locate
			setView: true
			enableHighAccuracy: true

	go_to_route: ->
		latlngs = @model.waypoints.to_latlngs()

		# In order to not display route behind sidebar.
		translate = new L.Point -374, -50

		for latlng in latlngs[..]
			latlngs.push @map.layerPointToLatLng @map.latLngToLayerPoint(latlng).add(translate)

		@map.fitBounds new L.LatLngBounds(latlngs).pad(.05) if latlngs.length > 0

	go_to_point: (location) ->
		if @map.getZoom() < 16
			@map.setZoom 16
			do (location) =>
				setTimeout =>
					@map.panTo location
				, 500
		else
			@map.panTo location

	waypoint_added_or_updated: (model) ->
		#@waypoint_show_hide_update model, false

	waypoints_reset: (collection) ->
		#for cid, pin of @pin_views
		#	@waypoint_show_hide_update pin.model, true
		#for model in collection.models
		#	@waypoint_show_hide_update model, false

	waypoint_show_hide_update: (model, remove) ->
		#field_name = model.get 'type'
		#location   = model.get 'location'
		#cid        = model.cid
		#pin        = @pin_views[cid]
    #
		#if location.lat? and location.lng? and not remove
		#	location = new L.LatLng location.lat, location.lng
		#else
		#	location = null
    #
		#if location
		#	if pin
		#		unless pin.dragged
		#			pin.setLatLng location
		#			pin.setIcon IBikeCPH.icons[field_name]
		#	else
		#		pin = new L.Marker location, (
		#			draggable : true
		#			icon      : IBikeCPH.icons[field_name]
		#		)
		#		pin.model = model
		#		@pin_views[cid] = pin
    #
    #
		#		@map.addLayer pin
		#else if pin
		#	@map.removeLayer pin
		#	delete @pin_views[cid]
    #
		#return pin


#	set_pin_at: (field_name, x, y) ->
#		offset = $(@el).offset()
#		width  = $(@el).width()
#		height = $(@el).height()
#		x -= offset.left
#		y -= offset.top
#
#		return false if x < 0 or y < 0 or x >= width or y >= height
#
#		position = new L.Point x, y
#		location = @map.layerPointToLatLng @map.containerPointToLayerPoint position
#
#		@model.endpoint(field_name).set 'location', location

	showing_route: ->
		@current_route.getLatLngs().length > 0

	geometry_changed: (compressed_route) ->
		latlngs = IBikeCPH.util.decode_path compressed_route

		valid   = latlngs.length >= 2
		latlngs = @model.waypoints.to_latlngs() if not valid

		if valid
			@current_route.setLatLngs latlngs
			@invalid_route.setLatLngs []
			@map.addLayer    @current_route
			@map.removeLayer @invalid_route

			# Autozoom on load
			@go_to_route() if @bounds and window.location.hash

		else
			@current_route.setLatLngs []
			@invalid_route.setLatLngs latlngs
			@map.removeLayer @current_route
			@map.addLayer    @invalid_route

		@bounds = false
	
	waypoint_added: (model) =>
		view = new IBikeCPH.Views.Pin map: this, model: model
		@pin_views[model.cid] = view
		
		view.marker.on 'dragstart', (event) =>
			@osrm.set_instructions false
			@dragging_pin = true
			@old_route.setLatLngs @current_route.getLatLngs()
			@map.addLayer @old_route

		view.marker.on 'dragend', (event) =>
			@osrm.set_instructions true
			@dragging_pin = false
			@map.removeLayer @old_route

		view.marker.on 'drag', (event) =>
			@map.removeLayer @via_marker

	waypoint_removed: (model) ->
		@pin_views[model.cid] = undefined
		
	click: (event) ->
		@model.waypoints.add_endpoint event.latlng
		
	move_via_marker: (event) ->
		if @showing_route() and not @dragging_pin
			closest = @current_route.closestLayerPoint event.layerPoint
			if closest and closest.distance < 10
				@via_marker.setLatLng @map.layerPointToLatLng closest
				@map.addLayer @via_marker
			else
				@map.removeLayer @via_marker

	closest_waypoint_index: (location) ->
		return 1 if @model.waypoints.length == 2
		clicked_segment = @closest_route_point_index location
		waypoint_index = 0
		bump_at = 0
		for route_point, i in @current_route.getLatLngs()
			if i == bump_at
				waypoint_index = waypoint_index + 1
				location = @model.waypoints.at(waypoint_index).get('location')
				bump_at =  @closest_route_point_index location
			if i == clicked_segment
				return waypoint_index

	closest_route_point_index: (location) ->
		min_distance = Infinity
		closest      = undefined
		for route_point, index in @current_route.getLatLngs()
			distance = route_point.distanceTo location
			if distance < min_distance
				min_distance = distance
				closest      = index
		return closest

	start_via_drag: (event) ->
		location = event.target.getLatLng()
		waypoint = new IBikeCPH.Models.Waypoint type: 'via', location: location
		@model.waypoints.add waypoint, at: @closest_waypoint_index(location)
		@map.removeLayer @via_marker
		# Fake an initial dragstart event, so that the new via marker is actually dragged.
		@pin_views[waypoint.cid].marker.dragging._draggable._onDown event.originalEvent
