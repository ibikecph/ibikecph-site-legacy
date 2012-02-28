# This program is free software you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# or see http://www.gnu.org/licenses/agpl.txt.


# OSRM map handling
# [initialization, event handling, centering relative to UI]

# will hold the map object
OSRM.GLOBALS.map = null


# map view/model
# [extending Leaflet L.Map with setView/fitBounds methods that respect UI visibility] 
OSRM.MapView = L.Map.extend(
	setViewUI: (position, zoom) ->
		if OSRM.GUI.visible == true 
			point = OSRM.G.map.project( position, zoom)
			point.x-=OSRM.GUI.width/2
			position = OSRM.G.map.unproject(point,zoom)		
		
		this.setView( position, zoom)
		return null	
	,
	fitBoundsUI: (bounds) ->
		southwest = bounds.getSouthWest()
		northeast = bounds.getNorthEast()
		zoom = OSRM.G.map.getBoundsZoom(bounds)
		sw_point = OSRM.G.map.project( southwest, zoom)
		if OSRM.GUI.visible == true 
			sw_point.x-=OSRM.GUI.width/2
		else
			sw_point.x-=10
		sw_point.y+=10
		ne_point = OSRM.G.map.project( northeast, zoom)
		ne_point.y-=10
		sw_point.x+=10
		bounds.extend( OSRM.G.map.unproject(sw_point,zoom) )
		bounds.extend( OSRM.G.map.unproject(ne_point,zoom) )
		this.fitBounds( bounds )	
		return null	
	,
	getCenterUI: (unbounded) ->
		viewHalf = this.getSize()
		if OSRM.GUI.visible == true 
			viewHalf.x += OSRM.GUI.width
		centerPoint = this._getTopLeftPoint().add(viewHalf.divideBy(2))
		
		return this.unproject(centerPoint, this._zoom, unbounded)
	
)


# map controller
# [map initialization, event handling]
OSRM.Map =

# map initialization
init: () ->
	# check if GUI is initialized!
	if OSRM.GUI.visible == null
		OSRM.GUI.init()
	
	# setup tile servers
	tile_servers = OSRM.DEFAULTS.TILE_SERVERS
	base_maps = {}
	for i in [0...tile_servers.length]
		tile_servers[i].options.attribution = tile_servers[i].attribution 
		base_maps[ tile_servers[i].display_name ] = new L.TileLayer( tile_servers[i].url, tile_servers[i].options )
	

	# setup map
	OSRM.G.map = new OSRM.MapView('map',
    	center: new L.LatLng(OSRM.DEFAULTS.ONLOAD_LATITUDE, OSRM.DEFAULTS.ONLOAD_LONGITUDE),
	    zoom: OSRM.DEFAULTS.ONLOAD_ZOOM_LEVEL,
	    layers: [base_maps[tile_servers[0].display_name]],	    
	    zoomAnimation: false,								# remove animations -> routes are not hidden during zoom
	    fadeAnimation: false
	)

	# add layer control
	layersControl = new L.Control.Layers(base_maps,)
	OSRM.G.map.addControl(layersControl)

    # move zoom markers
	$('div.leaflet-control-zoom').css('left', (OSRM.GUI.width+5)+"px" )
	$('div.leaflet-control-zoom').css('top',"0")

	# initial correct map position and zoom (respect UI visibility, use browser position)
	position = new L.LatLng( OSRM.DEFAULTS.ONLOAD_LATITUDE, OSRM.DEFAULTS.ONLOAD_LONGITUDE)
	OSRM.G.map.setViewUI( position, OSRM.DEFAULTS.ONLOAD_ZOOM_LEVEL)
	if navigator.geolocation && document.URL.indexOf("file://") == -1		# convenience during development, as FF doesn't save rights for local files 
		navigator.geolocation.getCurrentPosition(OSRM.Map.geolocationResponse)

	# map events
	OSRM.G.map.on('zoomend', OSRM.Map.zoomed )
	OSRM.G.map.on('click', OSRM.Map.click )
	OSRM.G.map.on('contextmenu', OSRM.Map.contextmenu )
	OSRM.G.map.on('mousemove', OSRM.Map.mousemove )
	return null	
,

# map event handlers
zoomed: (e) ->
	OSRM.Routing.getRoute()
	return null	
,
contextmenu: (e) ->
	return null	
,
mousemove: (e) ->
	OSRM.Via.drawDragMarker(e)
	return null	
,
click: (e) ->
	if !OSRM.G.markers.hasSource() 
		index = OSRM.G.markers.setSource( e.latlng )
		OSRM.Geocoder.updateAddress( OSRM.C.SOURCE_LABEL, OSRM.C.DO_FALLBACK_TO_LAT_LNG )
		OSRM.G.markers.route[index].show()
		OSRM.G.markers.route[index].centerView( OSRM.G.map.getZoom() )
		OSRM.Routing.getRoute()
	else if !OSRM.G.markers.hasTarget() 
		index = OSRM.G.markers.setTarget( e.latlng )
		OSRM.Geocoder.updateAddress( OSRM.C.TARGET_LABEL, OSRM.C.DO_FALLBACK_TO_LAT_LNG )
		OSRM.G.markers.route[index].show()
		OSRM.G.markers.route[index].centerView( OSRM.G.map.getZoom() )
		OSRM.Routing.getRoute()
	return null	
	
,
geolocationResponse: (response) ->
	latlng = new L.LatLng(response.coords.latitude, response.coords.longitude)		
	OSRM.G.map.setViewUI(latlng, OSRM.DEFAULTS.ZOOM_LEVEL )
	return null	

