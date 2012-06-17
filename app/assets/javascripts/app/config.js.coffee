window.ibikecph or= {}

ibikecph.config =

	start:
		lat: 55.68
		lng: 12.50
		zoom: 12

	current_route:
		style:
			color   : 'blue'
			weight  : 5
			opacity : 0.6

	old_route:
		style:
			color   : 'black'
			weight  : 5
			opacity : 0.4

	invalid_route:
		style:
			color   : 'black'
			weight  : 1
			opacity : 0.5

	tiles: [
		name: 'Open Street Map'
		url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
		options:
			attribution: 'Map data &copy 2011 OpenStreetMap contributors, Imagery &copy 2011 Mapnik'
	,
		name: 'Solar'
		url: 'http://83.221.133.5/tiles/{z}/{x}/{y}.png'
		options:
			attribution: 'Map data &copy 2011 OpenStreetMap contributors, Imagery &copy 2011 Mapnik'
	]
