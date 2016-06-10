# Represent the instructions for the user to follow a given route.

class IBikeCPH.Collections.Instructions extends Backbone.Collection
  model: IBikeCPH.Models.Instruction
    
  reset_from_osrm: (route) ->
    @reset()
    index = 0
    for leg in route.legs
      for step in leg.steps
        #roundabout_exit = "#{turn}".match /^1[123]-(\d+)$/
        #if roundabout_exit
        #  turn = 11
        #  roundabout_exit = roundabout_exit[1] | 0
        #else
        #  roundabout_exit = null
      
        @add new IBikeCPH.Models.Instruction (
          step: step
        ),
        silent: true
        
        index = index + 1
    
    @trigger 'change'
    