class ibikecph.Instructions extends Backbone.Collection
	model: ibikecph.Instruction

	reset_from_osrm: (instructions) ->
		@reset _.map instructions, (instruction) ->
			[turn, street, distance, _, _, _, direction] = instruction

			roundabout_exit = "#{turn}".match /^1[123]-(\d+)$/
			if roundabout_exit
				turn = 11
				roundabout_exit = roundabout_exit[1] | 0
			else
				roundabout_exit = null

			(
				turn            : ibikecph.util.translate_turn_instruction turn
				street          : street
				roundabout_exit : roundabout_exit
				distance        : distance
				direction       : direction
			)
