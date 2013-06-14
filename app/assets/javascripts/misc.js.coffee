$().ready ->
	if $('#flash').length > 0
		$('#flash').css
			top: '+=50'
		setTimeout( ->
			$('#flash').css
				top: '-=70'
				opacity: 0
		,5000)

	if $('.drop_down .on').length > 0
		$('.drop_down .title span').text($('.drop_down .on').text())

	$("#mobile_app a").click ->
		$(this).parent().toggleClass "selected"
		$("#mobileapp").toggleClass 'rendered'
		return false

	$('#header .mobile_nav_trigger').click ->
		$('#header .menu').slideToggle(50)

	iBikeGrid =

		elements:
			container: $(".grid")
			items: $(".grid .item")
			thumb: $(".grid .item .item_thumb")
			win: $(window)

		config:
			box_styles: [
				background: "#dc1e19"
				"box-shadow": "0 1px 2px #e55955 inset, 0 2px 5px #b5b5b5"
				border: "2px solid #a81813"
			,
				background: "#00aeef"
				"box-shadow": "0 1px 2px #41b0d9 inset, 0 2px 5px #b5b5b5"
				border: "2px solid #008abd"
			,
				background: "#fa9100"
				"box-shadow": "0 1px 2px #fbae43 inset, 0 2px 5px #b5b5b5"
				border: "2px solid #c77400"
			]
			dimensions:
				window_width: $(window).width()

		resize_boxes: ->
			ibg = iBikeGrid
			width = ibg.elements.container.width()
			columns = 0

			if width > 1400
				columns = ibg.layouts.xlarge.columns
			else if width < 1400 and width > 1100
				columns = ibg.layouts.large.columns
			else if width < 1100 and width > 900
				columns = ibg.layouts.medium.columns
			else if width < 900 and width > 766
				columns = ibg.layouts.small.columns
			else
				columns = ibg.layouts.xmsall.columns
			ibg.elements.container.attr "data-ipr": columns
			ibg.elements.items.css width: (width / columns) - 24

		layouts:
			xlarge:
				columns: 6

			large:
				columns: 5

			medium:
				columns: 4

			small:
				columns: 3

			xmsall:
				columns: 1

		init: ->
			ibg = this
			ibg.elements.win.bind "resize", ->
				ibg.resize ibg

			setTimeout (->
				ibg.resize ibg
			), 0
			ibg.elements.items.each (i) ->
				el = $(this)
				ii = i + 1
				if i % 3 is 0
					#el.find(".item_thumb").css ibg.config.box_styles[2]
				else if ii % 2 is 0
					#el.find(".item_thumb").css ibg.config.box_styles[1]
				else
					#el.find(".item_thumb").css ibg.config.box_styles[0]


		resize: (ibg) ->
			ibg.config.dimensions.window_width = ibg.elements.win.width()
			ibg.resize_boxes()

	iBikeGrid.init()  if $(".grid").length > 0