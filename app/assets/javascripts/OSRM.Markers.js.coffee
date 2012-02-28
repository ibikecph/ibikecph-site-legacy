# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# or see http:# www.gnu.org/licenses/agpl.txt.


# OSRM markers 
# [base marker class, derived highlight marker and route marker classes, marker management]  

# base marker class (wraps Leaflet markers)
OSRM.Marker = (label, style, position) ->
	@label = label ? label : "marker"
	@position = position ? position : new L.LatLng(0,0)
	@marker = new L.MouseMarker( @position, style )
	@marker.parent = this	
	@shown = false
	@hint = null

OSRM.extend OSRM.Marker, 
show: () ->
	OSRM.G.map.addLayer(@marker)
	@shown = true
,
hide: () ->
	OSRM.G.map.removeLayer(@marker)
	@shown = false
,
setPosition: (position) ->
	@position = position
	@marker.setLatLng( position )
	@hint = null;	
,
getPosition: () ->
	@position
,
getLat: () ->
	@position.lat
,
getLng: () ->
	@position.lng
,
isShown: () ->
	@shown
,
centerView: (zoom) ->
	if zoom == undefined
		zoom = OSRM.DEFAULTS.ZOOM_LEVEL
	OSRM.G.map.setViewUI( @position, zoom )
,
toString: () ->
	"OSRM.Marker: \""+@label+"\", "+@position+")"


# route marker class (draggable, invokes route drawing routines) 
OSRM.RouteMarker = (label, style, position) ->
	style.baseicon = style.icon
	OSRM.RouteMarker.prototype.base.constructor.apply( this, arguments )
	@label = label ? label : "route_marker"
	@marker.on( 'click', @onClick )
	@marker.on( 'drag', @onDrag )
	@marker.on( 'dragstart', @onDragStart )
	@marker.on( 'dragend', @onDragEnd )
	return null

OSRM.inheritFrom( OSRM.RouteMarker, OSRM.Marker )

OSRM.extend OSRM.RouteMarker,
onClick: (e) ->
	for i in [0..OSRM.G.markers.route.length-1]
		if OSRM.G.markers.route[i].marker == this
			OSRM.G.markers.removeMarker( i )
			break	
	
	OSRM.Routing.getRoute()
	OSRM.G.markers.highlight.hide()
	OSRM.G.markers.dragger.hide()
,
onDrag: (e) ->
	@parent.setPosition( e.target.getLatLng() )
	if OSRM.G.markers.route.length>1
		OSRM.Routing.getDragRoute()
	OSRM.Geocoder.updateLocation( @parent.label )
,
onDragStart: (e) ->
	OSRM.G.dragging = true
	@switchIcon(@options.dragicon)
	
	# store id of dragged marker
	for i in [0..OSRM.G.markers.route.length-1]
		if OSRM.G.markers.route[i].marker == this
			OSRM.G.dragid = i
			break
		
	if @parent != OSRM.G.markers.highlight
		OSRM.G.markers.highlight.hide()
	if @parent != OSRM.G.markers.dragger
		OSRM.G.markers.dragger.hide()
	if OSRM.G.route.isShown()
		OSRM.G.route.showOldRoute()
,
onDragEnd: (e) ->
	OSRM.G.dragging = false
	@switchIcon(@options.baseicon)
	
	@parent.setPosition( e.target.getLatLng() );	
	if OSRM.G.route.isShown()
		OSRM.Routing.getRoute()
		OSRM.G.route.hideOldRoute()
		OSRM.G.route.hideUnnamedRoute()
	else
		OSRM.Geocoder.updateAddress(@parent.label)
		OSRM.GUI.clearResults()	
,
toString: () ->
	"OSRM.RouteMarker: \""+@label+"\", "+@position+")"



# drag marker class (draggable, invokes route drawing routines) 
OSRM.DragMarker = (label, style, position) ->
	OSRM.DragMarker.prototype.base.constructor.apply( this, arguments )
	@label = label ? label : "drag_marker"

OSRM.inheritFrom( OSRM.DragMarker, OSRM.RouteMarker )
OSRM.extend OSRM.DragMarker,
onClick: (e) ->
	if @parent != OSRM.G.markers.dragger
		@parent.hide()
,
onDragStart: (e) ->
	new_via_index = OSRM.Via.findViaIndex( e.target.getLatLng() )
	OSRM.G.markers.route.splice(new_via_index+1,0, @parent )

	OSRM.RouteMarker.prototype.onDragStart.call(this,e)
,
onDragEnd: (e) ->
	OSRM.G.markers.route[OSRM.G.dragid] = 
	new OSRM.RouteMarker(
		OSRM.C.VIA_LABEL,
		draggable:true,
		icon:OSRM.G.icons['marker-via'],
		dragicon:OSRM.G.icons['marker-via-drag'],
		e.target.getLatLng() 
	)
	OSRM.G.markers.route[OSRM.G.dragid].show()

	OSRM.RouteMarker.prototype.onDragEnd.call(this,e)
	@parent.hide()
,
toString: () ->
	"OSRM.DragMarker: \""+@label+"\", "+@position+")"


# marker management class (all route markers should only be set and deleted with these routines!)
# [this holds the vital information of the route]
OSRM.Markers = () ->
	@route = new Array()
	@highlight = new OSRM.DragMarker("highlight",draggable:true,icon:OSRM.G.icons['marker-highlight'],dragicon:OSRM.G.icons['marker-highlight-drag'])
	@dragger = new OSRM.DragMarker("drag",draggable:true,icon:OSRM.G.icons['marker-drag'],dragicon:OSRM.G.icons['marker-drag'])
	return null
	
OSRM.extend OSRM.Markers,
removeAll: () ->
	for i in [0..@route.length-1]
		@route[i].hide()
	@route.splice(0, @route.length)
	$('#gui-delete-source').css('visibility', 'hidden');
	$('#gui-delete-target').css('visibility', 'hidden');
,
removeVias: () ->
	# assert correct route array s - v - t
	for i in [0..@route.length-1]
		@route[i].hide()
	@route.splice(1, @route.length-2)
,
setSource: (position) ->
	# source node is always first node
	if @route[0] && @route[0].label == OSRM.C.SOURCE_LABEL
		@route[0].setPosition(position)
	else
		@route.splice(0,0, new  OSRM.RouteMarker(OSRM.C.SOURCE_LABEL,draggable:true,icon:OSRM.G.icons['marker-source'],dragicon:OSRM.G.icons['marker-source-drag'], position))
	$('#gui-delete-source').css('visibility', 'visible');
	0;	
,
setTarget: (position) ->
	# target node is always last node
	if @route[@route.length-1] && @route[ @route.length-1 ].label == OSRM.C.TARGET_LABEL
		@route[@route.length-1].setPosition(position)
	else
		@route.splice( @route.length,0, new OSRM.RouteMarker(OSRM.C.TARGET_LABEL,draggable:true,icon:OSRM.G.icons['marker-target'],dragicon:OSRM.G.icons['marker-target-drag'], position))
	$('#gui-delete-target').css('visibility', 'visible');
	@route.length-1
,
setVia: (id, position) ->
	# via nodes only between source and target nodes
	if @route.length<2 || id > @route.length-2
		return -1
	@route.splice(id+1,0, new OSRM.RouteMarker(OSRM.C.VIA_LABEL,draggable:true,icon:OSRM.G.icons['marker-via'],dragicon:OSRM.G.icons['marker-via-drag'], position))
	id+1
,
removeMarker: (id) ->
	if id >= @route.length
		return
	
	# also remove vias if source or target are removed
	if id==0 && @route[0].label == OSRM.C.SOURCE_LABEL
		$('#main-wrapper').removeClass 'with_route'
		@removeVias()
		$('#gui-input-source').val ""
		$('#information-box').html ""
		$('#information-box-header').html ""
		$('#gui-delete-source').css('visibility', 'hidden')
	else if id == @route.length-1 && @route[ @route.length-1 ].label == OSRM.C.TARGET_LABEL
		$('#main-wrapper').removeClass 'with_route'
		@removeVias()
		id = @route.length-1
		$('#gui-input-target').val ""
		$('#information-box').html ""
		$('#information-box-header').html ""
		$('#gui-delete-target').css('visibility', 'hidden')
	
	@route[id].hide()
	@route.splice(id, 1)
,
hasSource: () ->
	if OSRM.G.markers.route[0] && OSRM.G.markers.route[0].label == OSRM.C.SOURCE_LABEL
		return true
	return false
,
hasTarget: () ->
	OSRM.G.markers.route[OSRM.G.markers.route.length-1] && OSRM.G.markers.route[OSRM.G.markers.route.length-1].label == OSRM.C.TARGET_LABEL
