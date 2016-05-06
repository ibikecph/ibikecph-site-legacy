
//this is needed to avoid ajax calls clearing the session in rails 3
//see http://weblog.rubyonrails.org/2011/2/8/csrf-protection-bypass-in-ruby-on-rails
$(document).ajaxSend(function(e, xhr, options) {
  var token = $("meta[name='csrf-token']").attr("content");
  xhr.setRequestHeader("X-CSRF-Token", token);
});

//add support for maxlength in text-areas, bu setting the 'maxlength' attribute.
jQuery.fn.limitMaxlength = function(options){

  var settings = jQuery.extend({
    attribute: "maxlength",
    onLimit: function(){},
    onEdit: function(){}
  }, options);

  // Event handler to limit the textarea
  var onEdit = function(){
    var textarea = jQuery(this);
    var maxlength = parseInt(textarea.attr(settings.attribute));

    if(textarea.val().length > maxlength){
      textarea.val(textarea.val().substr(0, maxlength));

      // Call the onlimit handler within the scope of the textarea
      jQuery.proxy(settings.onLimit, this)();
    }

    // Call the onEdit handler within the scope of the textarea
    jQuery.proxy(settings.onEdit, this)(maxlength - textarea.val().length);
  }

  this.each(onEdit);

  return this.keyup(onEdit)
  .keydown(onEdit)
  .focus(onEdit);
}

//add support for showing maxlength in text-areas, by setting the 'data-maxlength' attribute
jQuery.fn.showMaxlength = function(options){

  var settings = jQuery.extend({
    attribute: "data-maxlength",
    onLimit: function(){},
    onEdit: function(){}
  }, options);

  // Event handler to limit the textarea
  var onEdit = function(){
    var textarea = jQuery(this);
    var maxlength = parseInt(textarea.attr(settings.attribute));

    if(textarea.val().length > maxlength){

      // Call the onlimit handler within the scope of the textarea
      jQuery.proxy(settings.onLimit, this)(textarea.val().length - maxlength);
    }

    // Call the onEdit handler within the scope of the textarea
    jQuery.proxy(settings.onEdit, this)(maxlength - textarea.val().length);
  }

  this.each(onEdit);

  return this.keyup(onEdit)
  .keydown(onEdit)
  .focus(onEdit);
}

$(document).ready(function(){
  var onEditCallback = function(remaining){    
    if(remaining >= 0){
      $(this).siblings('.chars_remaining').text(' '+I18n.t('character.remaining', {count: remaining} ));
      $(this).siblings('.chars_remaining').removeClass('too_long');
    }
  }

  var onLimitCallback = function(excess){
    $(this).siblings('.chars_remaining').text(' '+I18n.t('character.too_long', {count: excess} ));
    $(this).siblings('.chars_remaining').addClass('too_long');
  }

  $('textarea[maxlength]').limitMaxlength({
    onEdit: onEditCallback,
    onLimit: onLimitCallback,
  });

  $('textarea[data-maxlength]').showMaxlength({
    onEdit: onEditCallback,
    onLimit: onLimitCallback,
  });

  $('input:text[maxlength]').limitMaxlength({
    onEdit: onEditCallback,
    onLimit: onLimitCallback,
  });

  $('input:text[data-maxlength]').showMaxlength({
    onEdit: onEditCallback,
    onLimit: onLimitCallback,
  });
  
  //begin continous updating of 'time ago' labels
    jQuery("span.timeago").timeago();
  
  //set focus in forms
  $('#focus_input').focus()
  
  if (window.location.href.indexOf('#_=_') > 0) { window.location = window.location.href.replace(/#.*/, '') };
});




