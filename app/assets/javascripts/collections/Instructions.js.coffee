# Represent the instructions for the user to follow a given route.

class IBikeCPH.Models.Instructions extends Backbone.Collection
	model: IBikeCPH.Instruction

	reset_from_osrm: (instructions) ->
		@reset _.map instructions, (instruction) ->
			[turn, street, distance, index, _, _, direction] = instruction


			roundabout_exit = "#{turn}".match /^1[123]-(\d+)$/
			if roundabout_exit
				turn = 11
				roundabout_exit = roundabout_exit[1] | 0
			else
				roundabout_exit = null

			(
				turn            : IBikeCPH.util.translate_turn_instruction turn
				street          : street
				roundabout_exit : roundabout_exit
				distance        : distance
				direction       : direction
				index			: index
			)
