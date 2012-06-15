class ibikecph.Info

	constructor: ->
		@from = new ibikecph.Point field_name: 'from'
		@to   = new ibikecph.Point field_name: 'to'
		@via  = new ibikecph.Point field_name: 'via'

		@route = new ibikecph.Route

		new ibikecph.OSRM this
