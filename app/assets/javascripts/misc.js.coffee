$().ready ->

  unless window.location.href.match('account')
    unless $.cookie('trigger_mobile') is 'done'
      $("#mobile_app a").parent().addClass 'selected'
      $("#mobileapp").toggleClass 'rendered'

  remove_flash()

  if $('.drop_down .on').length > 0
    $('.drop_down .title span').text($('.drop_down .on').text())

  $('input, textarea').placeholder();

  $(window).on 'resize', ->
    if $(window).width() > 767
      $('.menu').show()
    else
      $('.menu').hide()