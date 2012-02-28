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

# OSRM geocoding routines
# [geocoder query, management and display of geocoder results]

# some constants
OSRM.CONSTANTS.SOURCE_LABEL = "source"
OSRM.CONSTANTS.TARGET_LABEL = "target"
OSRM.CONSTANTS.VIA_LABEL = "via"
OSRM.CONSTANTS.DO_FALLBACK_TO_LAT_LNG = true

OSRM.Geocoder =

# [normal geocoding]

# process input request and call geocoder if needed
call: (marker_id, query) ->
	if query==""
		return
	
	# geo coordinates given -> directly draw results
	if query.match(/^\s*[-+]?[0-9]*\.?[0-9]+\s*[,]\s*[-+]?[0-9]*\.?[0-9]+\s*$/)
		coord = query.split(/[,]/)
		OSRM.Geocoder._onclickResult(marker_id, coord[0], coord[1])
		OSRM.Geocoder.updateAddress( marker_id )
		return
	
	# build request for geocoder
	call = OSRM.DEFAULTS.HOST_GEOCODER_URL + "?format=json" + OSRM.DEFAULTS.GEOCODER_BOUNDS + "&accept-language="+I18n.locale+"&q=" + query
	OSRM.JSONP.call( call, OSRM.Geocoder._showResults, OSRM.Geocoder._showResults_Timeout, OSRM.DEFAULTS.JSONP_TIMEOUT, "geocoder_"+marker_id, {marker_id:marker_id,query:query} )
,

# helper function for clicks on geocoder search results
_onclickResult: (marker_id, lat, lon) ->
	index
	if marker_id == OSRM.C.SOURCE_LABEL
		index = OSRM.G.markers.setSource( new L.LatLng(lat, lon) )
	else if marker_id == OSRM.C.TARGET_LABEL
		index = OSRM.G.markers.setTarget( new L.LatLng(lat, lon) )
	else
		return
	
	OSRM.G.markers.route[index].show()
	OSRM.G.markers.route[index].centerView()	
	if OSRM.G.markers.route.length > 1
		OSRM.Routing.getRoute()
,


# process geocoder response
_showResults: (response, parameters) ->
	if !response
		OSRM.Geocoder._showResults_Empty(parameters)
		return
	
	if response.length == 0 
		OSRM.Geocoder._showResults_Empty(parameters)
		return
	
	# show first result
	OSRM.Geocoder._onclickResult(parameters.marker_id, response[0].lat, response[0].lon)
	if OSRM.G.markers.route.length > 1		# if a route is displayed, we don't need to show other possible geocoding results
		return
	
	# show possible results for input
	html = ""
	html += '<table class="results-table medium-font">'	
	for i in [0...response.length]
		result = response[i]

		# odd or even ?
		rowstyle='results-odd'
		if i%2==0
			rowstyle='results-even'
 
		html += '<tr class="'+rowstyle+'">'
		html += '<td class="result-counter"><span">'+(i+1)+'.</span></td>'
		html += '<td class="result-items">'

		if result.display_name
			html += '<div class="result-item" onclick="OSRM.Geocoder._onclickResult(\''+parameters.marker_id+'\', '+result.lat+', '+result.lon+')">'+result.display_name+'</div>'
		html += "</td></tr>"
	html += '</table>'
		
	$('#information-box-header').html "<div class='header-title'>"+I18n.t("search_results")+"</div>" +
		"<div class='header-content'>("+I18n.t("found_x_results").replace(/%i/,response.length)+")</div>"+
		"<div class='header-content'>(found "+response.length+" results)"+"</div>"
	$('#information-box').html html
,
_showResults_Empty: (parameters) ->
	$('#information-box-header').html "<div class='header-title'>"+I18n.t("search_results")+"</div>" +
		"<div class='header-content'>("+I18n.t("found_x_results").replace(/%i/,0)+")</div>"		
	if parameters.marker_id == OSRM.C.SOURCE_LABEL
		$('#information-box').html "<div class='no-results big-font'>"+I18n.t("no_results_found_SOURCE")+": "+parameters.query +"</div>"
	else if parameters.marker_id == OSRM.C.TARGET_LABEL
		$('#information-box').html "<div class='no-results big-font'>"+I18n.t("no_results_found_TARGET")+": "+parameters.query +"</div>"
	else
		$('#information-box').html "<div class='no-results big-font'>"+I18n.t("no_results_found")+": "+parameters.query +"</div>"
,
_showResults_Timeout: () ->
	$('#information-box-header').html "<div class='header-title'>"+I18n.t("search_results")+"</div>" +
		"<div class='header-content'>("+I18n.t("found_x_results").replace(/%i/,0)+")</div>"		
	$('#information-box').html "<div class='no-results big-font'>"+I18n.t("timed_out")+"</div>"	
,


# [reverse geocoding]

# update geo coordinates in input boxes
updateLocation: (marker_id) ->
	if (marker_id == OSRM.C.SOURCE_LABEL && OSRM.G.markers.hasSource()) 
		$('#gui-input-source').val OSRM.G.markers.route[0].getLat().toFixed(6) + ", " + OSRM.G.markers.route[0].getLng().toFixed(6)
	else if (marker_id == OSRM.C.TARGET_LABEL && OSRM.G.markers.hasTarget()) 
		$('#gui-input-target').val OSRM.G.markers.route[OSRM.G.markers.route.length-1].getLat().toFixed(6) + ", " + OSRM.G.markers.route[OSRM.G.markers.route.length-1].getLng().toFixed(6)		
,

# update address in input boxes
updateAddress: (marker_id, do_fallback_to_lat_lng) ->
	# build request for reverse geocoder
	lat = null
	lng = null
	
	if marker_id == OSRM.C.SOURCE_LABEL && OSRM.G.markers.hasSource()
		lat = OSRM.G.markers.route[0].getLat()
		lng = OSRM.G.markers.route[0].getLng()		
	else if marker_id == OSRM.C.TARGET_LABEL && OSRM.G.markers.hasTarget() 
		lat = OSRM.G.markers.route[OSRM.G.markers.route.length-1].getLat()
		lng = OSRM.G.markers.route[OSRM.G.markers.route.length-1].getLng()		
	else
		return
	
	call = OSRM.DEFAULTS.HOST_REVERSE_GEOCODER_URL + "?format=json" + "&accept-language="+I18n.locale + "&lat=" + lat + "&lon=" + lng
	OSRM.JSONP.call( call, OSRM.Geocoder._showReverseResults, OSRM.Geocoder._showReverseResults_Timeout, OSRM.DEFAULTS.JSONP_TIMEOUT, "reverse_geocoder_"+marker_id, {marker_id:marker_id, do_fallback: do_fallback_to_lat_lng} )
,


# processing JSONP response of reverse geocoder
_showReverseResults: (response, parameters) ->
	if !response
		OSRM.Geocoder._showReverseResults_Timeout(response, parameters)
		return
	
	if response.address == undefined
		OSRM.Geocoder._showReverseResults_Timeout(response, parameters)
		return

	# build reverse geocoding address
	used_address_data = 0
	address = ""
	if response.address.road
		address += response.address.road
		used_address_data++
	if response.address.city
		if used_address_data > 0
			address += ", "
		address += response.address.city
		used_address_data++
	else if response.address.village
		if used_address_data > 0
			address += ", "
		address += response.address.village
		used_address_data++
	if used_address_data < 2 && response.address.country
		if used_address_data > 0
			address += ", "
		address += response.address.country
		used_address_data++
	if used_address_data == 0
		OSRM.Geocoder._showReverseResults_Timeout(response, parameters)
		return
		
	# add result to DOM
	if parameters.marker_id == OSRM.C.SOURCE_LABEL && OSRM.G.markers.hasSource()
		$('#gui-input-source').val address
	else if parameters.marker_id == OSRM.C.TARGET_LABEL && OSRM.G.markers.hasTarget()
		$('#gui-input-target').val address
,
_showReverseResults_Timeout: (response, parameters) ->
	if !parameters.do_fallback
		return
	OSRM.Geocoder.updateLocation(parameters.marker_id)