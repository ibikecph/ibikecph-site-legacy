# Represent the instructions for the user to follow a given route.

class IBikeCPH.Collections.Instructions extends Backbone.Collection
  model: IBikeCPH.Models.Instruction
    
  reset_from_osrm: (route) ->
    @reset()
    leg_index = 0
    for leg in route.legs
      for step in leg.steps
        @add new IBikeCPH.Models.Instruction (
          step: step
          first: leg_index == 0
          last: leg_index == (route.legs.length - 1)
        ),
        silent: true
      leg_index = leg_index + 1
    @trigger 'change'
    