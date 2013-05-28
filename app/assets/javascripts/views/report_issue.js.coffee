class IBikeCPH.Views.ReportIssue extends Backbone.View
	template: JST['report']

	events:
		'click .header .back'			: 'hide'
		'click .bug'					: 'step_2'

	initialize: (options) ->

	render: (from, to) ->
		render: (from, to) ->
		values =
			from: from
			to: to
		@$el.html @template()
		$('#ui').css
			left: 25
		$('#report').css
			height: $("#ui").outerHeight()+2
			left: 0
		$('#report #step_1.inner').css
			height: ($('#report').height()-$('#report .header').height())-40
		$('#report #step_2.inner').css
			height: ($('#report').height()-$('#report .header').height())-93
		this

	step_2: ->
		$('#step_1').hide()
		$('#step_2, .submits').show();
		#select = '<select name="#" id="" class="selectReplace"><option value="">Vælg trin i ruten at rapportére</option><option>Start ad Griffenfeldsgade mod sydvest</option><option>Fortsæt ad H.C. Ørsteds Vej</option><option>Drej let til venstre ad Danasvej</option><option>Drej til højre ad Sankt Knuds Vej</option><option>Fortsæt ad Sankt Knuds Vej</option><option>Ankomst til destinationen</option></select>'
		#$('#step_2 form').prepend(select)
		$('#step_2 form select').customSelect('.selectReplace')
		$(".reportProblemForm input[type='radio']").bind "click", ->
			container = $(this).parent()
			explainProblem = $(".reportProblemForm .explainProblem")
			explainProblem.remove()  if explainProblem.length > 0
			container.append "<textarea name=\"\" id=\"\" class=\"explainProblem\" placeholder=\"Uddyb evt. problemet...\"></textarea>"
			container.find("textarea").focus()


	hide: ->
		t = @
		$('#ui').css
			left: 0
		$('#report').css
			left: -390
		setTimeout ( ->
			t.unbind()
		), 500