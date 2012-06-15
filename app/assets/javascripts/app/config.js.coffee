window.ibikecph or= {}

ibikecph.config =

	start:
		lat: 55.68
		lng: 12.50
		zoom: 12

	tiles: [
		name: 'Open Street Map'
		url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
		options:
			attribution: 'Map data &copy 2011 OpenStreetMap contributors, Imagery &copy 2011 Mapnik'
			maxZoom: 18
	,
		name: 'Solar'
		url: 'http://83.221.133.5/tiles/{z}/{x}/{y}.png'
		options:
			attribution: 'Map data &copy 2011 OpenStreetMap contributors, Imagery &copy 2011 Mapnik'
			minZoom: 9
			maxZoom: 15
	]
