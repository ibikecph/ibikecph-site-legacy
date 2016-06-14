class IBikeCPH.Views.Instruction extends Backbone.View
  template: JST['instructions/instruction']
  tagName: 'li'
  
  events:
    'mouseenter': 'show'
    'click': 'zoom'
  
  render: =>
    @step = @model.get('step')
    @$el.html @template(instruction: @instruction_string(), duration: @duration_string() )
    this

  show: ->
    @model.trigger 'show_step', @model
    
  zoom: ->
    @model.trigger 'zoom_to_step', @model
  
  way_name: (step) ->
    match = step.name.match /\{highway:(.*)\}/
    if match
      highway = match[1]
      I18n.translate("#instructions.highway_#{highway}", {defaultValue: I18n.translate('instructions.highway_default') } )
    else
      step.name
  
  instruction_string: ->  
    first = @model.get('first')
    last = @model.get('last')
    maneuver = @step.maneuver
    
    # replace spaces with underscore, so we can use key to lookup i18n string 
    if @step.maneuver.modifier
      modifier_key = maneuver.modifier.replace(/\s/, '_')
      
    name = @way_name(@step)

    base = switch @step.maneuver.type
      when 'depart'
        heading_code = @angle_to_cardinal(maneuver.bearing_after)
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
        exit = I18n.translate("instructions.#{maneuver.exit}" )
        if maneuver.rotary_name
          I18n.translate("instructions.rotary", {name:name, exit:exit, rotary_name:maneuver.rotary_name} )
        else
          I18n.translate("instructions.roundabout", {name:name, exit:exit} )
      else
        # handle unknown instructions as a normal turn
        I18n.translate("instructions.turn_#{modifier_key}", {name:name} )
    @append_mode(base)
  
  append_mode: (base) ->
    if @step.maneuver.type != 'arrive' and @step.mode != "cycling"
      push = I18n.translate("instructions.mode_pushing_bike" )
      "#{base} (#{push})"
    else
      base

  angle_to_cardinal: (angle) ->
    directions = 8
    slice = 360.0 / directions
    n = Math.round(angle/slice) % directions  # modulo will ensure range 0-7
    ["N","NE","E","SE","S","SW","W","NW"][n]
  
  duration_string: ->
    IBikeCPH.Views.Instruction.humanize_distance(@step.duration)

  @humanize_distance: (meters) ->
    if meters >= 1000
      "#{(meters/1000).toFixed(2)} km"
    else
      "#{meters.toFixed(0)} m"
      
  @humanize_duration: (seconds) ->
    if seconds >= 3600
      h = Math.floor(seconds / 3600.0)
      divisor_for_minutes = seconds % 3600
      m = Math.floor(divisor_for_minutes / 60)
      hour = I18n.translate("instructions.durations.hour" )
      minute = I18n.translate("instructions.durations.minute" )
      "#{h} #{hour} #{m} #{minute}"
    else if seconds>=60
      m = Math.floor(seconds/60.0)
      minute = I18n.translate("instructions.durations.minute" )
      "#{m} #{minute}"
    else
      s = Math.floor(seconds)
      second = I18n.translate("instructions.durations.second" )
      "#{s} #{second}"
