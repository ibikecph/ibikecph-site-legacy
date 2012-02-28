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


# OSRM printer
# [printing support]

OSRM.Printing = 
		
init: () ->
	icon = document.createElement('div')
	icon.id = "gui-printer"
	icon.className = "iconic-button top-right-button"
	
	spacer = document.createElement('div')
	spacer.className = "quad top-right-button"
	
	input_mask_header = $('#input-mask-header') 
	input_mask_header.appendChild(spacer,input_mask_header.lastChild)
	input_mask_header.appendChild(icon,input_mask_header.lastChild)
	
	$('#gui-printer').click OSRM.Printing.print	
,
		
windowLoaded: () ->
	OSRM.Printing.show( OSRM.G.response )
	OSRM.printwindow.focus()
,

show: (response) ->
	# create header
	header = 
		'<div class="full">' +
		'<div class="left">' +
		'<div class="header-title base-font">' + I18n.t("route_description") + '</div>' +
		'<div class="header-content">' + I18n.t("distance")+": " + OSRM.Utils.metersToDistance(response.route_summary.total_distance) + '</div>' +
		'<div class="header-content">' + I18n.t("duration")+": " + OSRM.Utils.secondsToTime(response.route_summary.total_time) + '</div>' +
		'</div>' +
		'<div class="right">' +
		'</div>' +		
		'</div>'	
	
	# create route description
	route_desc = ''
	route_desc += '<table id="thetable" class="results-table medium-font">'
	route_desc += '<thead style="display:table-header-group"><tr><td colspan="3">'+header+'</td></tr></thead>'
	route_desc += '</thead>'
	route_desc += '<tbody stlye="display:table-row-group">'
	
	for i in [0...response.route_instructions.length]
		# odd or even ?
		rowstyle='results-odd'
		if i%2==0
			rowstyle='results-even' 

		route_desc += '<tr class="'+rowstyle+'">'
		
		route_desc += '<td class="result-directions">'
		route_desc += '<img width="18px" src="'+OSRM.RoutingDescription.getDrivingInstructionIcon(response.route_instructions[i][0])+'" alt="" />'
		route_desc += "</td>"		
		
		route_desc += '<td class="result-items">'
		route_desc += '<div class="result-item">'

		# build route description
		if i == 0
			route_desc += I18n.t(OSRM.RoutingDescription.getDrivingInstruction(response.route_instructions[i][0])).replace(/\[(.*)\]/,"$1").replace(/%s/, I18n.t(response.route_instructions[i][6]) )
		else if( response.route_instructions[i][1] != "" )
			route_desc += I18n.t(OSRM.RoutingDescription.getDrivingInstruction(response.route_instructions[i][0])).replace(/\[(.*)\]/,"$1").replace(/%s/, response.route_instructions[i][1])
		else
			route_desc += I18n.t(OSRM.RoutingDescription.getDrivingInstruction(response.route_instructions[i][0])).replace(/\[(.*)\]/,"")

		route_desc += '</div>'
		route_desc += "</td>"
		
		route_desc += '<td class="result-distance">'
		if i != response.route_instructions.length-1
			route_desc += '<b>'+OSRM.Utils.metersToDistance(response.route_instructions[i][2])+'</b>'
		route_desc += "</td>"
		
		route_desc += "</tr>"
	
	route_desc += '</tbody>'
	route_desc += '</table>'
	
	# put everything in DOM
	OSRM.printwindow.$('#description').html route_desc
	
	# init map
	map = OSRM.printwindow.initialize()
	markers = OSRM.G.markers.route
	map.addLayer( new L.MouseMarker( markers[0].getPosition(), draggable:false,clickable:false,icon:OSRM.G.icons['marker-source'] ) )
	for i in [0...markers.length]
		map.addLayer( new L.MouseMarker( markers[i].getPosition(), draggable:false,clickable:false,icon:OSRM.G.icons['marker-via'] ) )
	map.addLayer( new L.MouseMarker( markers[markers.length-1].getPosition(), draggable:false,clickable:false,icon:OSRM.G.icons['marker-target'] ))
	route = new L.DashedPolyline()
	route.setLatLngs( OSRM.G.route.getPositions() )
	route.setStyle( dashed:false,clickable:false,color:'#0033FF', weight:5 )
	map.addLayer( route )
	bounds = new L.LatLngBounds( OSRM.G.route.getPositions() )
	map.fitBounds( bounds )
,

# react to click
print: () ->
	OSRM.printwindow = window.open("printing/printing.html","","width=540,height=500,left=100,top=100,dependent=yes,location=no,menubar=no,scrollbars=yes,status=no,toolbar=no,resizable=yes")
	OSRM.printwindow.addEventListener("DOMContentLoaded", OSRM.Printing.windowLoaded, false)

