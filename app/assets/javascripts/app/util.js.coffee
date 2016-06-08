IBikeCPH.util or= {}

IBikeCPH.util.normalize_whitespace = (text) ->
  "#{text}".replace(/^\s+|\s+$/g, '').replace(/\s+/g, ' ');


IBikeCPH.util.instruction_string = (instruction) ->
  string = I18n.translate('instructions.'+instruction.turn);

  if instruction.turn is 'enter_roundabout'
    string += ' ' +  I18n.t('instructions.take_the_nth_exit').replace('{%nth}', I18n.translate('instructions.'+instruction.roundabout_exit + ''));
  
  street = instruction.street.match /\{highway:(.*)\}/
  if street
    street = I18n.translate('instructions.highway_'+street[1], {defaultValue: I18n.translate('instructions.highway_default') } )
  else
    street = instruction.street
  
  if instruction.street and instruction.turn isnt 'enter_roundabout'
    string += ' ' + I18n.translate('instructions.follow') + ' ' + street

  if instruction.turn is 'head'
    string += ' ' + I18n.translate('instructions.'+instruction.direction)

  if instruction.distance and instruction.turn isnt 'continue'
    string += ' ' + I18n.translate('instructions.and_continue') + ' ' + instruction.distance + 'm';

  if instruction.turn is 'continue'
    string += ' ' + I18n.translate('instructions.for') + ' ' + instruction.distance + 'm'

  if instruction.mode == 2
    string +=  " (#{I18n.translate('instructions.mode_push')})"
  else if instruction.mode == 3
    string +=  " (#{I18n.translate('instructions.mode_ferry')})"
  else if instruction.mode == 4
    string +=  " (#{I18n.translate('instructions.mode_train')})"

  string
  # string = I18n.translate('instructions.'+instruction.turn);

  # if instruction.turn is 'enter_roundabout'
  #   string += ' ' +  I18n.t('instructions.take_the_nth_exit').replace('{%nth}', I18n.translate('instructions.'+instruction.roundabout_exit + ''));
  
  # street = instruction.street.match /\{highway:(.*)\}/
  
  # if street
  #   street = I18n.translate('instructions.highway_'+street[1], {defaultValue: I18n.translate('instructions.highway_default') } )
  # else
  #   street = instruction.street
  

  # if instruction.street and instruction.turn isnt 'enter_roundabout'
  #   string += ' ' + I18n.translate('instructions.follow') + ' ' + street

  # if instruction.turn is 'head'
  #   string += ' ' + I18n.translate('instructions.'+instruction.direction)

  # if instruction.distance and instruction.turn isnt 'continue'
  #   string += ' ' + I18n.translate('instructions.and_continue') + ' ' + instruction.distance + 'm';

  # if instruction.turn is 'continue'
  #   string += ' ' + I18n.translate('instructions.for') + ' ' + instruction.distance + 'm'
  
  # if instruction.mode == 2
  #   string +=  " (#{I18n.translate('instructions.mode_push')})"
  # else if instruction.mode == 3
  #   string +=  " (#{I18n.translate('instructions.mode_ferry')})"
  # else if instruction.mode == 4
  #   string +=  " (#{I18n.translate('instructions.mode_train')})"
  
  # string

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

IBikeCPH.util.translate_turn_instruction = (turn) ->
  switch turn | 0
    when 1 then 'continue'
    when 2 then 'turn_slight_right'
    when 3 then 'turn_right'
    when 4 then 'turn_sharp_right'
    when 5 then 'u-turn'
    when 6 then 'turn_sharp_left'
    when 7 then 'turn_left'
    when 8 then 'turn_slight_left'
    when 9 then 'reach-via-point'
    when 10 then 'head'
    when 11 then 'enter_roundabout'
    when 12 then 'leave-roundabout'
    when 13 then 'stay-on-roundabout'
    when 14 then 'start'
    when 15 then 'reached_destination'
    when 16 then 'enter_opposite'
    when 17 then 'leave_opposite'
    else 'no-instruction'

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

