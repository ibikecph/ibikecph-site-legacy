class ibikecph.Icon extends L.Icon
	options:
		iconUrl    : '/assets/images/marker-icon.png'
		iconSize   : new L.Point(48, 48)
		iconAnchor : new L.Point(42, 42)

class ibikecph.RouteMarker extends L.Icon
	options:
		iconUrl    : '/assets/marker-drag.png'
		iconSize   : new L.Point(18, 18)
		iconAnchor : new L.Point( 9,  9)

ibikecph.icons = {}

ibikecph.icons.from = new ibikecph.Icon
	iconUrl : '/assets/images/marker-start.png'

ibikecph.icons.to = new ibikecph.Icon
	iconUrl : '/assets/images/marker-end.png'

ibikecph.icons.via = new ibikecph.Icon
	iconUrl : '/assets/images/marker-via.png'

ibikecph.icons.route_marker = new ibikecph.RouteMarker
