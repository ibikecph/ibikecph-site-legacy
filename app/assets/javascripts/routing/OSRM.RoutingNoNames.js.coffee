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


# OSRM routing
# [renders route segments that are unnamed streets]


OSRM.RoutingNoNames = 
		
# displays route segments that are unnamed streets
show: (response) ->
	# do not display unnamed streets?
	unless $('#option-highlight-nonames').attr('checked')
		OSRM.G.route.hideUnnamedRoute()
		return
	
		
	# mark geometry positions where unnamed/named streets switch
	named = []
	for i in [0...response.route_instructions.length]
		if response.route_instructions[i][1] == '' 
			named[ response.route_instructions[i][3] ] = false		# no street name
		else
			named[ response.route_instructions[i][3] ] = true		# yes street name
	

	# aggregate geometry for unnamed streets
	geometry = OSRM.RoutingGeometry._decode(response.route_geometry, 5)
	is_named = true
	current_positions = []
	all_positions = []
	for i in [0...geometry.length]
		current_positions.push( new L.LatLng(geometry[i][0], geometry[i][1]) )

		# still named/unnamed?
		if (named[i] == is_named || named[i] == undefined) && i != geometry.length-1
			continue

		# switch between named/unnamed!
		if is_named == false
			all_positions.push( current_positions )
		current_positions = []
		current_positions.push( new L.LatLng(geometry[i][0], geometry[i][1]) )
		is_named = named[i]
	
	
	# display unnamed streets
	OSRM.G.route.showUnnamedRoute(all_positions)
,

showNA: () -> 
	OSRM.G.route.hideUnnamedRoute()	

