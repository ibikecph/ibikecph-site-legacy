class IBikeCPH.Views.Map extends Backbone.View

	bounds: true

	initialize: (options) ->
		@router = options.router

		$(window).on 'resize', ->
			$('#map').height $(window).height() - $('#header').height()
		$(window).trigger 'resize'

		@osrm = new IBikeCPH.OSRM @model
		
		bounds = IBikeCPH.config.maxbounds.value
		
		@map = new L.Map(@el.id,
			zoomControl: false
			worldCopyJump: false
			maxBounds: bounds
		)
		
		@map.setMaxBounds bounds 	#Limit the max bounds of the map

		@map.on 'zoomend', (event) =>
			@osrm.set_zoom @map.getZoom()

		@dragging_pin = false
		@pin_views = {}		#used to map from waypoint models to views

		@current_route = new L.Polyline [], IBikeCPH.config.route_styles.current
		@invalid_route = new L.Polyline [], IBikeCPH.config.route_styles.invalid
		@old_route     = new L.Polyline [], IBikeCPH.config.route_styles.old

		@via_marker = new L.Marker null, draggable: false, icon: IBikeCPH.icons.route_marker
		@step_marker = new L.Marker null, draggable: false, icon: IBikeCPH.icons.step
		
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
		
		@via_marker.on 'mousedown', (event) =>
			@initiate_via_drag event
		
		@map.on 'mousemove', (event) =>
			@move_via_marker event

		@map.on 'click', (event) =>
			@click_map event

		@map.on 'zoomend', (event) =>
			@trigger 'zoom', zoom: @map.getZoom()

		@model.on 'change:route', (model, compressed_route) =>
			@geometry_changed compressed_route

		@model.waypoints.on 'change:located', (model) =>
			if model.located()
				@show_waypoint model
			else
				@hide_waypoint model
		
		@model.waypoints.on 'reset', (model) =>
			@map.removeLayer @invalid_route
			@model.waypoints.each (t) =>
				@show_waypoint t if t.located()
		
		@model.waypoints.on 'remove', (model) =>
			@hide_waypoint model
		
		@model.instructions.on 'show_step', (model) =>
			@show_step model
		
		@model.instructions.on 'zoom_to_step', (model) =>
			@zoom_to_step model

		@model.instructions.on 'hide_step', =>
			@hide_step()
		
	reset: ->
		@map.removeLayer @invalid_route
		
	go_to_my_location: ->

		@map.locate
			setView: true
			enableHighAccuracy: true

		m = @map
		if navigator.geolocation
			navigator.geolocation.getCurrentPosition (position) ->
  				m.fireEvent "click",
  					latlng: latlng = new L.LatLng(position.coords.latitude, position.coords.longitude)
		else
			alert "Not supported"

	go_to_route: ->
		latlngs = @model.waypoints.to_latlngs()
		translate = new L.Point -374, -50  #In order to not display route behind sidebar.
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
			#@go_to_route() if @bounds and window.location.hash

		else
			@current_route.setLatLngs []
			@invalid_route.setLatLngs latlngs
			@map.removeLayer @current_route
			@map.addLayer    @invalid_route

		@bounds = false

	drag_pin_start: ->
		@osrm.set_instructions false
		@dragging_pin = true
		@old_route.setLatLngs @current_route.getLatLngs()
		@map.addLayer @old_route
		@map.removeLayer @via_marker
	
	drag_pin_end: ->
		@osrm.set_instructions true
		@dragging_pin = false
		@map.removeLayer @old_route
		
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
				closest = index
		return closest
	
	initiate_via_drag: (event) ->
		location = event.target.getLatLng()
		waypoint = new IBikeCPH.Models.Waypoint type: 'via', location: location
		@model.waypoints.add waypoint, at: @closest_waypoint_index(location)
		@map.removeLayer @via_marker
		@show_waypoint waypoint
		#trigger synthetic event, so that new via marker is actually dragged:
		@pin_views[waypoint.cid].marker.dragging._draggable._onDown event.originalEvent

	show_waypoint: (model) =>
		unless @pin_views[model.cid]
			view = new IBikeCPH.Views.Pin model: model
			@map.addLayer view.marker
			@pin_views[model.cid] = view
			view.marker.on 'dragstart', (event) => @drag_pin_start()
			view.marker.on 'dragend', (event) => @drag_pin_end()
			view.on 'click', (event) => @click_marker event

	hide_waypoint: (model) ->
		if @pin_views[model.cid]
			@pin_views[model.cid].remove()
			@map.removeLayer @pin_views[model.cid].marker
			@pin_views[model.cid] = undefined

	click_map: (event) ->
		if not @model.waypoints.first().located()
			@model.waypoints.first().set 'location', event.latlng
			@model.waypoints.first().trigger 'input:location'
		else if not @model.waypoints.last().located()
			@model.waypoints.last().set 'location', event.latlng
			@model.waypoints.last().trigger 'input:location'
		else if event.originalEvent.altKey
			location = event.latlng
			waypoint = new IBikeCPH.Models.Waypoint location: location
			l = @model.waypoints.first().get 'location'
			fromDist = new L.LatLng(l.lat, l.lng).distanceTo location
			l = @model.waypoints.last().get 'location'
			toDist = new L.LatLng(l.lat, l.lng).distanceTo location
			if fromDist < toDist
				@model.waypoints.unshift waypoint
			else
				@model.waypoints.push waypoint
			@map.removeLayer @via_marker
			@show_waypoint waypoint
		
	click_marker: (view) ->
		model = view.model
		if model.get('type') == 'via' or @model.waypoints.length > 2
			@model.waypoints.remove model
		else
			model.set 'location': null, 'address': null
		
	show_step: (model) ->
		index = model.get 'index'
		point = @current_route._latlngs[ index ]
		@step_marker.setLatLng point
		@map.addLayer @step_marker

	zoom_to_step: (model) ->
		index = model.get 'index'
		point = @current_route._latlngs[ index ]
		@go_to_point point

	hide_step: (model) ->
		@map.removeLayer @step_marker
