ibikecph.util or= {}

ibikecph.util.normalize_whitespace = (text) ->
	"#{text}".replace(/^\s+|\s+$/g, '').replace(/\s+/g, ' ')

ibikecph.util.decode_path = (encoded) ->
	len   = encoded.length
	index = 0
	array = []
	lat   = 0
	lng   = 0

	while (index < len)

		b      = null
		shift  = 0
		result = 0

		loop
			b = encoded.charCodeAt(index++) - 63
			result |= (b & 0x1f) << shift
			shift  += 5
			break if b < 0x20

		if result & 1
			dlat = ~(result >> 1)
		else
			dlat = result >> 1

		lat += dlat

		shift  = 0
		result = 0

		loop
			b = encoded.charCodeAt(index++) - 63
			result |= (b & 0x1f) << shift
			shift  += 5
			break if b < 0x20

		if result & 1
			dlng = ~(result >> 1)
		else
			dlng = result >> 1

		lng += dlng

		array.push(
			lat: lat * 1e-5
			lng: lng * 1e-5
		)

	return array
