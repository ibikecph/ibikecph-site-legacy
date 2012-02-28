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

# OSRM routing description
# [renders routing description and manages events]


OSRM.RoutingDescription =
		
# route description events
onClickRouteDescription: (geometry_index) ->
	positions = OSRM.G.route.getPositions()

	OSRM.G.markers.highlight.setPosition( positions[geometry_index] )
	OSRM.G.markers.highlight.show()
	OSRM.G.markers.highlight.centerView(OSRM.DEFAULTS.HIGHLIGHT_ZOOM_LEVEL)	
,
onClickCreateShortcut: (src) ->
	src += '&z='+ OSRM.G.map.getZoom() + '&center=' + OSRM.G.map.getCenter().lat.toFixed(6) + ',' + OSRM.G.map.getCenter().lng.toFixed(6)
	OSRM.JSONP.call(OSRM.DEFAULTS.HOST_SHORTENER_URL+src, OSRM.RoutingDescription.showRouteLink, OSRM.RoutingDescription.showRouteLink_TimeOut, OSRM.DEFAULTS.JSONP_TIMEOUT, 'shortener')
	$('#route-link').html '['+I18n.t("generate_link_to_route")+']'
,
showRouteLink: (response) ->
	$('#route-link').html '[<a class="result-link text-selectable" href="' +response.ShortURL+ '">'+response.ShortURL+'</a>]'
,
showRouteLink_TimeOut: () ->
	$('#route-link').html '['+I18n.t("link_to_route_timeout")+']'
,

# handling of routing description
show: (response) ->
	query_string = '?rebuild=1'
	for i in [0...OSRM.G.markers.route.length]
		query_string += '&loc=' + OSRM.G.markers.route[i].getLat().toFixed(6) + ',' + OSRM.G.markers.route[i].getLng().toFixed(6) 
	
	$('#information-box-header').html JST['templates/route_summary'](route_summary: response.route_summary, query_string: query_string)
	$('#information-box').html JST['templates/instructions'](instructions: response.route_instructions)
	$('#main-wrapper').addClass 'with_route'
,

# simple description
showSimple: (response) ->
	$('#information-box-header').html JST['templates/route_summary'](route_summary: response.route_summary)
	$('#information-box').html ""	
,

# no description
showNA: (display_text) ->
	$('#information-box-header').html JST['templates/no_route']()
	$('#information-box').html ""	
,

# retrieve driving instruction icon from instruction id
getDrivingInstructionIcon: (server_instruction_id) -> 
	local_icon_id = "direction_#{server_instruction_id.replace(/-.*/,"")}"		#roundabout 11-x all use 11
	if OSRM.G.images[local_icon_id]
		return OSRM.G.images[local_icon_id].src
	else
		alert( "no icon for #{local_icon_id}")
		return OSRM.G.images["direction_0"].src
,

instruction: (response) ->
	code = response[0]
	name = response[1]
	
	if code == "10"
		bearing = I18n.t response[6]
		key = "head"
		values = {bearing: bearing}
	else if code[0..1] == "11"
		exit = code[3..10]
		if exit<10
			ordinal = I18n.t "ordinal_#{exit}"
		else
			ordinal = "#{exit}."
		key = "roundabout"
		values = {nth: ordinal}
	else
		key = "direction_#{code}"
		values = {name: name}	
	
	if name != ""
		key += "_on"
		values.name = name	
	return I18n.t key, values