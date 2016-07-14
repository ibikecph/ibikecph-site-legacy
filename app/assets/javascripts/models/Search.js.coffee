# Holds references to all the important models and collections for a given
# instance of the app. Also contains the route (model attribute `route`) as a
# compressed string, see OSRM API documentation.

class IBikeCPH.Models.Search extends Backbone.Model

  initialize: ->
    @waypoints      = new IBikeCPH.Collections.Waypoints
    @instructions   = new IBikeCPH.Collections.Instructions
    @summary        = new IBikeCPH.Models.Summary
    @set 'profile', @standard_profile(), silent: true
    
  reset: ->
    @waypoints.reset()
    @instructions.reset()
    @summary.reset()
    @set 'route', ''
    @profile = @standard_profile()
  
  set_profile_from_legacy_url: (path) ->
    profile = @standard_profile()
    match = path.match /mode:(\w+)/
    if match
      if match[1] == "cargobike"
        profile = "cargo"        # convert legacy mode name
      else
        profile = match[1]
    @set 'profile', profile

  standard_profile: ->
    'fast'