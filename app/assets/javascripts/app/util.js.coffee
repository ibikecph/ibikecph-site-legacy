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

ibikecph.util.translate_turn_instruction = (turn) ->
	switch turn | 0
		when 1 then 'continue'
		when 2 then 'turn-slight-right'
		when 3 then 'turn-right'
		when 4 then 'turn-sharp-right'
		when 5 then 'u-turn'
		when 6 then 'turn-sharp-left'
		when 7 then 'turn-left'
		when 8 then 'turn-slight-left'
		when 9 then 'reach-via-point'
		when 10 then 'head'
		when 11 then 'enter-roundabout'
		when 12 then 'leave-roundabout'
		when 13 then 'stay-on-roundabout'
		when 14 then 'start'
		when 15 then 'reached-destination'
		else 'no-instruction'

ibikecph.util.displayable_address = (geocoding_response) ->
	address = geocoding_response?.address

	if address
		country_code = "#{address.country_code}".toUpperCase()
		city = address.city or address.town or address.village or address.hamlet or address.administrative
		if address.postcode
			postcode = "#{address.postcode} "
		else
			postcode = ''
		if address.road and not /^\d+$/.test "#{address.road}"
			road = "#{address.road}"
		else
			road = ''
		house_number = address.house_number

	if country_code == 'DK' or country_code == 'NO' or country_code == 'DE'
		if road and house_number and city
			display_address = "#{road} #{house_number}, #{postcode}#{city}"
		else if road and city
			display_address = "#{road}, #{postcode}#{city}"
		else if city
			display_address = "#{postcode}#{city}"

		if country_code == 'NO'
			display_address += ', Norge'
		else if country_code == 'DE'
			display_address += ', Tyskland'

	else if country_code == 'SE'
		postcode = postcode.match /^(\d{3})(\d{2}) $/
		if postcode
			postcode = "SE-#{postcode[1]} #{postcode[2]} "
		else
			postcode = ''

		if road and house_number and city
			display_address = "#{road} #{house_number}, #{postcode}#{city}"
		else if road and city
			display_address = "#{road}, #{postcode}#{city}"
		else if city
			display_address = "#{postcode}#{city}"

		display_address += ', Sverige'

	else
		display_address = ibikecph.util.normalize_whitespace "#{[geocoding_response?.display_name]}"

	return display_address or null
