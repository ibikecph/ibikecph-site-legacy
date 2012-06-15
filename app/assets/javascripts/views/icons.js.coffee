class ibikecph.Icon extends L.Icon
	options:
		iconUrl    : '/assets/images/marker-icon.png'
		shadowUrl  : '/assets/images/marker-shadow.png'
		iconSize   : new L.Point(25, 41)
		shadowSize : new L.Point(41, 41)
		iconAnchor : new L.Point(12, 41)

ibikecph.icons = {}

ibikecph.icons.from = new ibikecph.Icon
	iconUrl : '/assets/images/marker-start.png'

ibikecph.icons.to = new ibikecph.Icon
	iconUrl : '/assets/images/marker-end.png'

ibikecph.icons.via = new ibikecph.Icon
	iconUrl : '/assets/images/marker-via.png'
