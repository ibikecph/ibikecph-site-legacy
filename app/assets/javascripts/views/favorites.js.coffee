class IBikeCPH.Views.Favorites extends Backbone.View
	template: JST['favorites']

	events:
		'click .header .back'			: 'hide'

	initialize: (options) ->

	render: (from, to) ->
		values =
			from: from
			to: to
		@$el.html @template()
		$('#favorites b.start').html(from)
		$('#favorites b.dest').html(to)
		$('#ui').css
			left: 25
		$("#favorites").css
			height: $("#ui").outerHeight()+2
			left: 0
		this
	
	hide: ->
		t = @
		$('#ui').css
			left: 0
		$("#favorites").css
			left: -390
		setTimeout ( ->
			t.unbind()
		), 500