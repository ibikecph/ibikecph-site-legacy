IBikeCPH.util or= {}

IBikeCPH.util.normalize_whitespace = (text) ->
  "#{text}".replace(/^\s+|\s+$/g, '').replace(/\s+/g, ' ')


IBikeCPH.util.instruction_string = (instruction) ->  
  step =  instruction.get('step')
  
  # replace spaces with underscore, so we can use key to lookup i18n string 
  if step.maneuver.modifier
    modifier_key = step.maneuver.modifier.replace(/\s/, '_')
  
  highway = step.name.match /\{highway:(.*)\}/
  if highway
    name = I18n.translate('instructions.highway_'+highway[1], {defaultValue: I18n.translate('instructions.highway_default') } )
  else
    name = step.name
  
  switch step.maneuver.type
    when 'depart'
      heading_code = IBikeCPH.util.angle_to_cardinal step.maneuver.bearing_after
      heading = I18n.translate("instructions.cardinals.#{heading_code}" )
      I18n.translate("instructions.depart", {heading:heading, name:name})
    when 'arrive'
      I18n.translate("instructions.arrive", {name:step.name})
    when 'turn', 'new_name', 'fork', 'end of road'
      I18n.translate("instructions.turn_#{modifier_key}", {name:name} )
    when 'merge'
      I18n.translate("instructions.merge_#{modifier_key}", {name:name} )
    when 'on ramp'
      I18n.translate("instructions.on_ramp", {name:name} )
    when 'off ramp'
      I18n.translate("instructions.off_ramp", {name:name} )
    when 'continue'
      I18n.translate("instructions.continue_#{modifier_key}", {name:name} )
    when 'roundabout' then "traverse roundabout, has additional field exit with NR if the roundabout is left. the modifier specifies the direction of entering the roundabout"
    when 'rotary' then "a larger version of a roundabout, can offer rotary_name in addition to the exit parameter."
    when 'roundabout turn' then "Describes a turn at a small roundabout that should be treated as normal turn. The modifier indicates the turn direciton. Example instruction: At the roundabout turn left."
    when 'notification' then "not an actual turn but a change in the driving conditions. For example the travel mode. If the road takes a turn itself, the modifier describes the direction"
    else
      # handle unknown instructions as a normal turn
      I18n.translate("instructions.turn_#{modifier_key}", {name:name} )
  

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

IBikeCPH.util.angle_to_cardinal = (angle) ->
  directions = 8
  slice = 360.0 / directions
  n = Math.round(angle/slice) % directions  # modulo will ensure range 0-7
  ["N","NE","E","SE","S","SW","W","NW"][n]

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

