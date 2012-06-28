class ibikecph.Icon extends L.Icon
	options:
		iconUrl    : '/assets/marker-icon.png'
		iconSize   : new L.Point(48, 48)
		iconAnchor : new L.Point(42, 42)

class ibikecph.RouteMarker extends L.Icon
	options:
		iconUrl    : '/assets/marker-drag.png'
		iconSize   : new L.Point(48, 48)
		iconAnchor : new L.Point(42, 42)

ibikecph.icons = {}

ibikecph.icons.from = new ibikecph.Icon
	iconUrl : '/assets/marker-start.png'

ibikecph.icons.to = new ibikecph.Icon
	iconUrl : '/assets/marker-end.png'

ibikecph.icons.via = new ibikecph.Icon
	iconUrl : '/assets/marker-via.png'

ibikecph.icons.route_marker = new ibikecph.RouteMarker
