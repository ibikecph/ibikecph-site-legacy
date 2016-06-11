IBikeCPH.util or= {}

IBikeCPH.util.normalize_whitespace = (text) ->
  "#{text}".replace(/^\s+|\s+$/g, '').replace(/\s+/g, ' ')


IBikeCPH.util.instruction_string = (instruction) ->  
  step =  instruction.get('step')
  first = instruction.get('first')
  last = instruction.get('last')
  
  # replace spaces with underscore, so we can use key to lookup i18n string 
  if step.maneuver.modifier
    modifier_key = step.maneuver.modifier.replace(/\s/, '_')
  
  match = step.name.match /\{highway:(.*)\}/
  if match
    highway = match[1]
    name = I18n.translate('instructions.highway_'+highway, {defaultValue: I18n.translate('instructions.highway_default') } )
  else
    name = step.name
  
  base = switch step.maneuver.type
    when 'depart'
      heading_code = IBikeCPH.util.angle_to_cardinal step.maneuver.bearing_after
      heading = I18n.translate("instructions.cardinals.#{heading_code}" )
      if first
        I18n.translate("instructions.depart", {name:name, heading:heading})
      else
        I18n.translate("instructions.depart_from_via", {name:name, heading:heading})
    when 'arrive'
      # TODO should get addresses (including street nr) from searh model
      key = modifier_key || 'straight'
      side = I18n.translate("instructions.sides.#{key}" )
      if last
        I18n.translate("instructions.arrive", {name:name, side:side})
      else
        I18n.translate("instructions.arrive_to_via", {name:name, side:side})
    when 'turn', 'new_name', 'fork', 'end of road', 'notification'
      I18n.translate("instructions.turn_#{modifier_key}", {name:name} )
    when 'merge'
      I18n.translate("instructions.merge_#{modifier_key}", {name:name} )
    when 'on ramp'
      I18n.translate("instructions.on_ramp", {name:name} )
    when 'off ramp'
      I18n.translate("instructions.off_ramp", {name:name} )
    when 'continue'
      I18n.translate("instructions.continue_#{modifier_key}", {name:name} )
    when 'roundabout', 'rotary'
      #angle = step.maneuver.bearing_after - step.maneuver.bearing_before
      #cardinal = IBikeCPH.util.angle_to_cardinal(angle)
      #direction = I18n.translate("instructions.cardinals.turn_#{cardinal}" )
      exit = I18n.translate("instructions.#{step.maneuver.exit}" )
      if step.maneuver.rotary_name
        I18n.translate("instructions.rotary", {name:name, exit:exit, rotary_name:rotary_name} )
      else
        I18n.translate("instructions.roundabout", {name:name, exit:exit} )
    else
      # handle unknown instructions as a normal turn
      I18n.translate("instructions.turn_#{modifier_key}", {name:name} )
  
  if step.maneuver.type != 'arrive' and step.mode != "cycling"
    push = I18n.translate("instructions.mode_pushing_bike" )
    "#{base} (#{push})"
  else
    base

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

