#This program is free software you can redistribute it and/or modify
#it under the terms of the GNU AFFERO General Public License as published by
#the Free Software Foundation either version 3 of the License, or
#any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU Affero General Public License
#along with this program if not, write to the Free Software
#Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#or see http://www.gnu.org/licenses/agpl.txt.


# OSRM routing
# [handles GUI events]

OSRM.RoutingGUI = 

# click: button "reset"
resetRouting: () ->
	$('#main-wrapper').removeClass 'with_route'
	
	$('#gui-input-source').val ""
	$('#gui-input-target').val ""
	
	OSRM.G.route.hideAll()
	OSRM.G.markers.removeAll()
	OSRM.G.markers.highlight.hide()
	
	$('#information-box').html ""
	$('#information-box-header').html ""
	
	OSRM.JSONP.reset()	
,

# click: button "reverse"
reverseRouting: () ->
	# invert input boxes
	tmp = $('#gui-input-source').val()
	$('#gui-input-source').val $('#gui-input-target').val()
	$('#gui-input-target').val tmp
	
	# invert route
	OSRM.G.markers.route.reverse()
	if OSRM.G.markers.route.length == 1
		if OSRM.G.markers.route[0].label == OSRM.C.TARGET_LABEL
			OSRM.G.markers.route[0].label = OSRM.C.SOURCE_LABEL
			OSRM.G.markers.route[0].marker.setIcon( OSRM.G.icons['marker-source'] )
		else if OSRM.G.markers.route[0].label == OSRM.C.SOURCE_LABEL
			OSRM.G.markers.route[0].label = OSRM.C.TARGET_LABEL
			OSRM.G.markers.route[0].marker.setIcon( OSRM.G.icons['marker-target'] )
		
	else if OSRM.G.markers.route.length > 1
		OSRM.G.markers.route[0].label = OSRM.C.SOURCE_LABEL
		OSRM.G.markers.route[0].marker.setIcon( OSRM.G.icons['marker-source'] )
		
		OSRM.G.markers.route[OSRM.G.markers.route.length-1].label = OSRM.C.TARGET_LABEL
		OSRM.G.markers.route[OSRM.G.markers.route.length-1].marker.setIcon( OSRM.G.icons['marker-target'] )		
	
	
	# recompute route
	if OSRM.G.route.isShown()
		OSRM.Routing.getRoute()
		OSRM.G.markers.highlight.hide()
	else 
		$('#information-box').html ""
		$('#information-box-header').html ""		
	
,

# click: button "show"
showMarker: (marker_id) ->
	if OSRM.JSONP.fences["geocoder_source"] || OSRM.JSONP.fences["geocoder_target"]
		return
	
	if marker_id == OSRM.C.SOURCE_LABEL && OSRM.G.markers.hasSource()
		OSRM.G.markers.route[0].centerView()
	else if marker_id == OSRM.C.TARGET_LABEL && OSRM.G.markers.hasTarget()
		OSRM.G.markers.route[OSRM.G.markers.route.length-1].centerView()
,

# changed: any inputbox (is called when enter is pressed [after] or focus is lost [before])
inputChanged: (marker_id) ->
	if marker_id == OSRM.C.SOURCE_LABEL
		OSRM.Geocoder.call(OSRM.C.SOURCE_LABEL, $('#gui-input-source').val() )
	else if marker_id == OSRM.C.TARGET_LABEL
		OSRM.Geocoder.call(OSRM.C.TARGET_LABEL, $('#gui-input-target').val() )
,

# click: button "open JOSM"
openJOSM: () ->
	x = OSRM.G.map.getCenterUI()
	ydelta = 0.01
	xdelta = ydelta * 2
	p = [ 'left='  + (x.lng - xdelta), 'bottom=' + (x.lat - ydelta), 'right=' + (x.lng + xdelta), 'top='    + (x.lat + ydelta)]
	url = 'http://localhost:8111/load_and_zoom?' + p.join('&')
	
	frame = L.DomUtil.create('iframe', null, document.body)
	frame.style.width = frame.style.height = "0px"
	frame.src = url
	frame.onload = (e) ->
		document.body.removeChild(frame) 
,

# click: button "open OSM Bugs"
openOSMBugs: () ->
	position = OSRM.G.map.getCenterUI()
	window.open( "http://osmbugs.org/?lat="+position.lat.toFixed(6)+"&lon="+position.lng.toFixed(6)+"&zoom="+OSRM.G.map.getZoom() )
,

# click: button "delete marker"
deleteMarker: (marker_id) -> 
	id = null
	if marker_id == 'source' && OSRM.G.markers.hasSource()
		id = 0
	else if marker_id == 'target' && OSRM.G.markers.hasTarget()
		id = OSRM.G.markers.route.length-1
	if id == null
		return

	OSRM.G.markers.removeMarker( id )
	OSRM.Routing.getRoute()
	OSRM.G.markers.highlight.hide()
