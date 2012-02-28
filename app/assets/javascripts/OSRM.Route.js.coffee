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

# OSRM routes
# [drawing of all types of route geometry] 


# simple route class (wraps Leaflet Polyline)
OSRM.SimpleRoute = (label, style) ->
	@label = (label ? label : "route")
	@route = new L.DashedPolyline()
	@route.setLatLngs( [] )
	if style
		@route.setStyle( style )
	@shown = false

OSRM.extend( OSRM.SimpleRoute,
show: () ->
	OSRM.G.map.addLayer(@route)
	@shown = true
,
hide: () ->
	OSRM.G.map.removeLayer(@route)
	@shown = false
,
isShown: () ->
	return @shown
,
getPoints: () ->
	return @route._originalPoints
,
getPositions: () ->
	return @route.getLatLngs()
,
setPositions: (positions) ->
	@route.setLatLngs( positions )
,
setStyle: (style) ->
	@route.setStyle(style)
,
centerView: () ->
	bounds = new L.LatLngBounds( @getPositions() )
	OSRM.g.map.fitBoundsUI( bounds )
,
toString: () ->
	return "OSRM.Route("+ @label + ", " + @route.getLatLngs().length + " points)"

)


# multiroute class (wraps Leaflet LayerGroup to hold several disjoint routes)
OSRM.MultiRoute = (label) ->
	@label = (label ? label : "multiroute")
	@route = new L.LayerGroup()

	@shown = false

OSRM.extend( OSRM.MultiRoute,
show: () ->
	OSRM.G.map.addLayer(@route)
	@shown = true
,
hide: () ->
	OSRM.G.map.removeLayer(@route)
	@shown = false
,
isShown: () ->
	return @shown
,
addRoute: (positions) ->
	line = new L.DashedPolyline( positions )
	
	line.on('click', (e) ->
		OSRM.G.route.fire('click',e)
	) 
	@route.addLayer( line )
	return
,
clearRoutes: () ->
	@route.clearLayers()
,
setStyle: (style) ->
	@route.invoke('setStyle', style)
,
toString: () ->
	return "OSRM.MultiRoute("+ @label + ")"

)


# route management (handles drawing of route geometry - current route, old route, unnamed route, highlight unnamed streets) 
# [this holds the route geometry]
OSRM.Route = () ->
	@_current_route	= new OSRM.SimpleRoute("current" , {dashed:false} )
	@_old_route		= new OSRM.SimpleRoute("old", {dashed:false,color:"#123"} )
	@_unnamed_route	= new OSRM.MultiRoute("unnamed")
	
	@_current_route_style	= {dashed:false,color:'#0033FF', weight:5}
	@_current_noroute_style	= {dashed:true, color:'#222222', weight:2}
	@_old_route_style	= {dashed:false,color:'#112233', weight:5}
	@_old_noroute_style	= {dashed:true, color:'#000000', weight:2}
	@_unnamed_route_style = {dashed:false, color:'#FF00FF', weight:10}
	@_old_unnamed_route_style = {dashed:false, color:'#990099', weight:10}
	
	@_noroute = OSRM.Route.ROUTE

OSRM.Route.NOROUTE = true
OSRM.Route.ROUTE = false
OSRM.extend( OSRM.Route,
	
showRoute: (positions, noroute) ->
	@_noroute = noroute
	@_current_route.setPositions( positions )
	if ( @_noroute == OSRM.Route.NOROUTE )
		@_current_route.setStyle( @_current_noroute_style )
	else
		@_current_route.setStyle( @_current_route_style )
	@_current_route.show()
	#@_raiseUnnamedRoute()
,
hideRoute: () ->
	@_current_route.hide()
	@_unnamed_route.hide()
,
hideAll: () ->
	@_current_route.hide()
	@_unnamed_route.hide()
	@_old_route.hide()
	@_noroute = OSRM.Route.ROUTE
,	

showUnnamedRoute: (positions) ->
	@_unnamed_route.clearRoutes()
	for i in [0...positions.length]
		@_unnamed_route.addRoute(positions[i])	
	
	@_unnamed_route.setStyle( @_unnamed_route_style )
	@_unnamed_route.show()
,
hideUnnamedRoute: () ->
	@_unnamed_route.hide()
,
# TODO: hack to put unnamed_route above old_route -> easier way in will be available Leaflet 0.4	
_raiseUnnamedRoute: () ->
	if(@_unnamed_route.isShown())
		@_unnamed_route.hide()
		@_unnamed_route.show()
			
,	
showOldRoute: () ->
	@_old_route.setPositions( @_current_route.getPositions() )
	if @_noroute == OSRM.Route.NOROUTE
		@_old_route.setStyle( @_old_noroute_style )
	else
		@_old_route.setStyle( @_old_route_style )
	@_old_route.show()
	@_raiseUnnamedRoute()
	# change color of unnamed route highlighting - no separate object as dragged route does not have unnamed route highlighting
	@_unnamed_route.setStyle( @_old_unnamed_route_style )
,
hideOldRoute: () ->
	@_old_route.hide()
,

isShown: () ->
	return @_current_route.isShown()
,
isRoute: () ->
	return !(@_noroute)
,	
getPositions: () ->
	return @_current_route.getPositions()
,
getPoints: () ->
	return @_current_route.getPoints()
,	
fire: (type,event) ->
	@_current_route.route.fire(type,event)
,
centerView: () ->
	@_current_route.centerView()
	
)
