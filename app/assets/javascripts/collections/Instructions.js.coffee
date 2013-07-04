# Represent the instructions for the user to follow a given route.

class IBikeCPH.Collections.Instructions extends Backbone.Collection
	model: IBikeCPH.Models.Instruction
		
	reset_from_osrm: (instructions) ->
		@reset()
		for instruction in instructions
			[turn, street, distance, index, _, _, direction, _,mode] = instruction
			roundabout_exit = "#{turn}".match /^1[123]-(\d+)$/
			if roundabout_exit
				turn = 11
				roundabout_exit = roundabout_exit[1] | 0
			else
				roundabout_exit = null
			@add new IBikeCPH.Models.Instruction (
				turn            : IBikeCPH.util.translate_turn_instruction turn
				street          : street
				roundabout_exit : roundabout_exit
				distance        : distance
				direction       : direction
				mode			: mode
				index			: index
			),
			silent: true
		@trigger 'change' if instructions.length>0
		