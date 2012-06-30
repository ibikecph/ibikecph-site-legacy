window.ibikecph or= {}

ibikecph.config =

	initial_location:
		lat: 55.68
		lng: 12.50
		zoom: 12

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
			color   : 'black'
			weight  : 1
			opacity : 0.5

	# The first tile set is used by default.
	map_tiles: [
		name: 'Solar'
		url: 'http://83.221.133.5/tiles/{z}/{x}/{y}.png'
		options:
			attribution: 'Map data &copy 2011 OpenStreetMap contributors, Imagery &copy 2011 Mapnik'
	,
		name: 'Open Street Map'
		url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
		options:
			attribution: 'Map data &copy 2011 OpenStreetMap contributors, Imagery &copy 2011 Mapnik'
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
		url: 'http://83.221.133.2/viaroute'

	geocoding_service:
		url: 'http://nominatim.openstreetmap.org/search'
		options:
			'accept-language' : 'da'
			countrycodes      : 'DK'
#			viewbox           : '-27.0,72.0,46.0,36.0' # Europe
			viewbox           : '7.6,54.4,15.7,58' # DK, Bornholm and Skåne
			bounded           : '1'
			email             : 'info@contingent.dk'

	reverse_geocoding_service:
		url: 'http://nominatim.openstreetmap.org/reverse'
		options:
			'accept-language' : 'da'
			addressdetails    : '1'
			email             : 'info@contingent.dk'
