window.IBikeCPH or= {}

IBikeCPH.config =

	initial_location:
		lat: 55.68
		lng: 12.55
		zoom: 13

	route_styles:
		current:
			color   : 'blue'
			weight  : 5
			opacity : 0.6
		old:
			color   : 'black'
			weight  : 5
			opacity : 0.4
		invalid:
			color   : 'grey'
			weight  : 5
			opacity : 0.3

	# The first tile set is used by default.
	map_tiles: [
		name: 'OpenStreetMap'
		url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
		options:
			attribution: 'Map data &copy 2012 OpenStreetMap contributors, Imagery &copy 2012 Mapnik'
	,
		name: 'IBikeCPH'
		url: 'http://tiles.ibikecph.dk/tiles/{z}/{x}/{y}.png'
		options:
			attribution: 'Map data &copy 2012 OpenStreetMap contributors, Imagery &copy 2012 IBikeCPH'
	,
		name: 'OpenCycleMap'
		url: 'http://{s}.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png'
		options:
			attribution: 'Map data &copy 2012 OpenStreetMap contributors, Imagery by Andy Allan and Dave Stubbs'
	]

	# The map controls are inserted in the specified order. Supported types:
	# 'zoom', 'layers'.
	map_controls: [
		type     : 'layers'
		position : 'topright'
	,
		type     : 'goto'
		position : 'topright'
	,
		type     : 'zoom'
		position : 'topright'
	]

	routing_service:
		url: 'http://routes.ibikecph.dk/viaroute'

	geocoding_service:
		url: 'http://nominatim.openstreetmap.org/search'
		options:
			'accept-language' : 'da'
			countrycodes      : 'DK'
#			viewbox           : '-27.0,72.0,46.0,36.0' # Europe
			viewbox           : '7.6,54.4,15.7,58' # DK, Bornholm and Skåne
			bounded           : '1'
			email             : 'emil.tin@tmf.kk.dk'

	reverse_geocoding_service:
		url: 'http://nominatim.openstreetmap.org/reverse'
		options:
			'accept-language' : 'da'
			addressdetails    : '1'
			email             : 'emil.tin@tmf.kk.dk'
