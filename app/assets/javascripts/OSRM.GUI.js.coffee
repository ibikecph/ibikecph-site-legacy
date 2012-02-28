# This program is free software you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY without even the implied warranty of
2# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# or see http://www.gnu.org/licenses/agpl.txt.


# OSRM GUI functionality
# [responsible for all non-routing related GUI behaviour]

OSRM.GUI =
		
# defaults
visible: null,
width: null,

# init GUI
init: () ->
	OSRM.GUI.visible = true
	OSRM.GUI.width = $("#main-wrapper").width()
	
	# init favicon
	$('#favicon').attr('href',OSRM.G.images["favicon"].src)
		
	# init starting source/target
	$('#gui-input-source').val OSRM.DEFAULTS.ONLOAD_SOURCE
	$('#gui-input-target').val OSRM.DEFAULTS.ONLOAD_TARGET
	
	# init events
	# [TODO: switch to new event model]
	$('#gui-toggle-in').click OSRM.GUI.toggleMain
	$('#gui-toggle-out').click OSRM.GUI.toggleMain
	$('#gui-reset').click OSRM.RoutingGUI.resetRouting
	$('#gui-reverse').click OSRM.RoutingGUI.reverseRouting
	$('#gui-options-toggle').click OSRM.GUI.toggleOptions
	$('#open-josm').click OSRM.RoutingGUI.openJOSM
	$('#open-osmbugs').click OSRM.RoutingGUI.openOSMBugs
	$('#option-highlight-nonames').click OSRM.Routing.getRoute
	
	$('#gui-input-source').change () ->
		OSRM.RoutingGUI.inputChanged(OSRM.C.SOURCE_LABEL)
	$('#gui-delete-source').click () ->
		OSRM.RoutingGUI.deleteMarker(OSRM.C.SOURCE_LABEL)
	$('#gui-search-source').click () ->
		OSRM.RoutingGUI.showMarker(OSRM.C.SOURCE_LABEL)	
	$('#gui-input-target').change () ->
		OSRM.RoutingGUI.inputChanged(OSRM.C.TARGET_LABEL)
	$('#gui-delete-target').click () ->
		OSRM.RoutingGUI.deleteMarker(OSRM.C.TARGET_LABEL)
	$('#gui-search-target').click () ->
		OSRM.RoutingGUI.showMarker(OSRM.C.TARGET_LABEL)	
,
		
# show/hide main-gui
toggleMain: () ->
	# show main-gui
	if OSRM.GUI.visible == false  
		$('div.leaflet-control-zoom').css('visibility','hidden')
		$('div.leaflet-control-zoom').css('left',(OSRM.GUI.width+5)+"px")
		$('#blob-wrapper').css('visibility','hidden');
		$('#main-wrapper').css('left',"5px")
	# hide main-gui
	else 
		$('div.leaflet-control-zoom').css('visibility','hidden')
		$('div.leaflet-control-zoom').css('left',"30px")
		$('#main-wrapper').css('left',-OSRM.GUI.width+"px")
	
	# execute after animation (old browser support)
	if OSRM.Browser.FF3!=-1 || OSRM.Browser.IE6_9!=-1 
		OSRM.GUI.onMainTransitionEnd()		
,

# do stuff after main-gui animation finished
onMainTransitionEnd: () ->
	# after hiding main-gui
	if OSRM.GUI.visible == true  
		$('#blob-wrapper').css('visibility', 'visible')
		$('div.leaflet-control-zoom').css('visibility','visible')
		OSRM.GUI.visible = false		
	# after showing main-gui
	else 
		$('div.leaflet-control-zoom').css('visibility','visible')
		OSRM.GUI.visible = true		
,

# show/hide small options bubble
toggleOptions: () ->
	$('#options-box').toggle()
,

# clear output area
clearResults: () ->
	$('#information-box').html ""
	$('#information-box-header').html ""	



