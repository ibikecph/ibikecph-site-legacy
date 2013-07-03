$().ready ->
	remove_flash()

	if $('.drop_down .on').length > 0
		$('.drop_down .title span').text($('.drop_down .on').text())

	$("#mobile_app a").click ->
		$(this).parent().toggleClass "selected"
		$("#mobileapp").toggleClass 'rendered'
		return false

	$('#header .mobile_nav_trigger').click ->
		$('#header .menu').slideToggle(50)

	$('input, textarea').placeholder();

	$(window).on 'resize', ->
		if $(window).width() > 767
			$('.menu').show()
		else
			$('.menu').hide()