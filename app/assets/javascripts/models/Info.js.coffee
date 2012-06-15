class ibikecph.Info

	constructor: ->
		@from = new ibikecph.Point field_name: 'from'
		@to   = new ibikecph.Point field_name: 'to'
		@via  = new ibikecph.Point field_name: 'via'

		@route        = new ibikecph.Route
		@instructions = new ibikecph.Instructions
		@summary      = new ibikecph.InstructionsSummary

		new ibikecph.OSRM this
