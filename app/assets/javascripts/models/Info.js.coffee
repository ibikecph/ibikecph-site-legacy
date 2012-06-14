class ibikecph.Info extends Backbone.Model

	initialize: ->
		@from = new ibikecph.Point field_name: 'from'
		@to   = new ibikecph.Point field_name: 'to'
		@via  = new ibikecph.Point field_name: 'via'

		@route = new ibikecph.Route
