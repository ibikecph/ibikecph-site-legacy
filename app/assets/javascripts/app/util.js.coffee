IBikeCPH.util or= {}

IBikeCPH.util.normalize_whitespace = (text) ->
  "#{text}".replace(/^\s+|\s+$/g, '').replace(/\s+/g, ' ')

IBikeCPH.util.decode_path = (encoded) ->
  len    = encoded.length
  index  = 0
  points = []
  lat    = 0
  lng    = 0

  while index < len

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
    
    precision = IBikeCPH.config.routing_service.precision
    points.push new L.LatLng(lat * precision, lng * precision)

  return points

IBikeCPH.util.displayable_address = (geocoding_response) ->
  address = geocoding_response.address
  
  if address.country_code == 'dk'
    country_code = "#{address.country_code}".toUpperCase()
    city = address.city or address.town or address.suburb or address.village or address.hamlet or address.administrative
    if address.postcode
      postcode = "#{address.postcode} "
    else
      postcode = ''
    if address.road and not /^\d+$/.test "#{address.road}"
      road = "#{address.road}"
    else
      road = ''
    house_number = address.house_number

    if road and house_number and city
      display_address = "#{road} #{house_number}, #{postcode}#{city}"
    else if road and city
      display_address = "#{road}, #{postcode}#{city}"
    else if city
      display_address = "#{postcode}#{city}"
  else
    display_address = IBikeCPH.util.normalize_whitespace "#{[geocoding_response?.display_name]}"
  return display_address or null

