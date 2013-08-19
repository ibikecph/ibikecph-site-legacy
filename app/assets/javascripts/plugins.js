/*!
 * jquery.customSelect() - v0.4.0
 * http://adam.co/lab/jquery/customselect/
 * 2013-04-28
 *
 * Copyright 2013 Adam Coulombe
 * @license http://www.opensource.org/licenses/mit-license.html MIT License
 * @license http://www.gnu.org/licenses/gpl.html GPL2 License
 */
(function(a){a.fn.extend({customSelect:function(c){if(typeof document.body.style.maxHeight==="undefined"){return this}var e={customClass:"customSelect",mapClass:true,mapStyle:true},c=a.extend(e,c),d=c.customClass,f=function(h,k){var g=h.find(":selected"),j=k.children(":first"),i=g.html()||"&nbsp;";j.html(i);if(g.attr("disabled")){k.addClass(b("DisabledOption"))}else{k.removeClass(b("DisabledOption"))}setTimeout(function(){k.removeClass(b("Open"));a(document).off("mouseup."+b("Open"))},60)},b=function(g){return d+g};return this.each(function(){var g=a(this),i=a("<span />").addClass(b("Inner")),h=a("<span />");g.after(h.append(i));h.addClass(d);if(c.mapClass){h.addClass(g.attr("class"))}if(c.mapStyle){h.attr("style",g.attr("style"))}g.addClass("hasCustomSelect").on("update",function(){f(g,h);var k=parseInt(g.outerWidth(),10)-(parseInt(h.outerWidth(),10)-parseInt(h.width(),10));h.css({display:"inline-block"});var j=h.outerHeight();if(g.attr("disabled")){h.addClass(b("Disabled"))}else{h.removeClass(b("Disabled"))}i.css({width:k,display:"inline-block"});g.css({"-webkit-appearance":"menulist-button",width:h.outerWidth(),position:"absolute",opacity:0,height:j,fontSize:h.css("font-size")})}).on("change",function(){h.addClass(b("Changed"));f(g,h)}).on("keyup",function(){if(!h.hasClass(b("Open"))){g.blur();g.focus()}}).on("mousedown",function(j){h.removeClass(b("Changed"))}).on("mouseup",function(j){if(!h.hasClass(b("Open"))){h.addClass(b("Open"));j.stopPropagation();a(document).one("mouseup."+b("Open"),function(k){if(k.target!=g.get(0)&&a.inArray(k.target,g.find("*").get())<0){g.blur()}else{f(g,h)}})}}).focus(function(){h.removeClass(b("Changed")).addClass(b("Focus"))}).blur(function(){h.removeClass(b("Focus")+" "+b("Open"))}).hover(function(){h.addClass(b("Hover"))},function(){h.removeClass(b("Hover"))}).trigger("update")})}})})(jQuery);

function preg_quote( str ) { return (str+'').replace(/([\\\.\+\*\?\[\^\]\$\(\)\{\}\=\!\<\>\|\:])/g, "\\$1"); }

// /*!
//  * backbone.basicauth.js v0.2.0
//  * Copyright 2013, Tom Spencer (@fiznool)
//  * backbone.basicauth.js may be freely distributed under the MIT license.
//  */
//  ;(function(window) {

//   // Local copy of global variables
//   var _ = window._;
//   var Backbone = window.Backbone;
//   var btoa = window.btoa;

//   var token = null;

//   var encode = function(username, password) {
//     // Use Base64 encoding to create the authentication details
//     // If btoa is not available on your target browser there is a polyfill:
//     // https://github.com/davidchambers/Base64.js
//     return btoa(username + ':' + password);
//   };

//   // Store a copy of the original Backbone.sync
//   var originalSync = Backbone.sync;

//   // Override Backbone.sync for all future requests.
//   // If a token is present, set the Basic Auth header
//   // before the sync is performed.
//   Backbone.sync = function(method, model, options) {
//     if (typeof token !== "undefined" && token !== null) {
//       options.headers = options.headers || {};
//       _.extend(options.headers, { 'Authorization': 'Basic ' + token });
//     }
//     return originalSync.call(model, method, model, options);
//   };

//   Backbone.BasicAuth = {
//     // Setup Basic Authentication for all future requests
//     set: function(username, password) {
//       token = encode(username, password);
//     },

//     // Clear Basic Authentication for all future requests
//     clear: function() {
//       token = null;
//     }
//   };

// })(this);

//
// With additions by Maciej Adwent http://github.com/Maciek416
// If token name and value are not supplied, this code Requires jQuery
//
// Adapted from:
// http://www.ngauthier.com/2011/02/backbone-and-rails-forgery-protection.html
// Nick Gauthier @ngauthier
//

var BackboneRailsAuthTokenAdapter = {

  //
  // Given an instance of Backbone, route its sync() function so that
  // it executes through this one first, which mixes in the CSRF 
  // authenticity token that Rails 3 needs to protect requests from
  // forgery. Optionally, the token's name and value can be supplied
  // by the caller.
  //
  fixSync: function(Backbone, paramName /*optional*/, paramValue /*optional*/){

    if(typeof(paramName)=='string' && typeof(paramValue)=='string'){
      // Use paramName and paramValue as supplied
    } else {
      // Assume we've rendered meta tags with erb
      paramName = $("meta[name='csrf-param']").attr('content');
      paramValue = $("meta[name='csrf-token']").attr('content');
    }

    // alias away the sync method
    Backbone._sync = Backbone.sync;

    // define a new sync method
    Backbone.sync = function(method, model, success, error) {

      // only need a token for non-get requests
      if (method == 'create' || method == 'update' || method == 'delete') {

        // grab the token from the meta tag rails embeds
        var auth_options = {};
        auth_options[paramName] = paramValue;

        // set it as a model attribute without triggering events
        model.set(auth_options, {silent: true});
      }

      // proxy the call to the old sync method
      return Backbone._sync(method, model, success, error);
    };
  },


  // change Backbone's sync function back to the original one
  restoreSync: function(Backbone){
    Backbone.sync = Backbone._sync;
  }
};

(function($) {

  Array.max = function( array ){
      return Math.max.apply( Math, array );
  };

  $.easing.__Slide = function (x, t, b, c, d) {
    return c * Math.sqrt(1 - (t=t/d-1)*t) + b;
  };

  $.simplemasonry = function(element, options) {

        var defaults = {
          'animate': false,
          'easing': '__Slide',
          'timeout': 800
        };
        var settings = $.extend({}, defaults, options);         
    var $element = $(element);    
    var _sm = this;

    $.extend(_sm, {

      refresh: function() {

            var $images = $('img', element);
            var numImages = $images.length;
            var imgLoadCount = 0;

            if ( $images.length > 0 )
              $element.addClass('sm-images-waiting').removeClass('sm-images-loaded');

        $images.on('load', function(i) {
          imgLoadCount++;
          
          if ( imgLoadCount == numImages ) {
            _sm.resize();
            $element.removeClass('sm-images-waiting').addClass('sm-images-loaded');
          }           
        });

        _sm.resize();
      },

      resize: function() {
        var $children = $element.children();      
        var childInfo = childElementInfo($children[0]);
        var width = childInfo['width'];
        var columns = childInfo['num'];
        var column_matrix = initialRange(columns);
        
        var renderChild = function(i) {
          var height = $(this).outerHeight();
          var col = 0;
          var addToCol = minIndex(column_matrix);
          var leftPos = Math.round((addToCol * width) * 10) / 10;
          var positionProps = { 
            'left'     : leftPos + '%',
            'top'      : column_matrix[addToCol] + 'px'
          };

          $(this)
            .css({
              'position' : 'absolute'
            })
            .stop();

          if ( settings['animate'] )
            $(this).animate(positionProps, settings['timeout'], settings['easing']);
          else
            $(this).css(positionProps);

          column_matrix[addToCol] += height;
        };

        $children
          .css({ 'overflow': 'hidden', 'zoom': '1' })
          .each(renderChild);

        $element.css({ 
          'position': 'relative',
          'height'  : Array.max(column_matrix) + 'px'
        });
      }

    });

    $(window).resize(_sm.resize);
    $element.addClass('sm-loaded');
    _sm.refresh();
  };

  function minIndex(arry) {
    var minValue = Math.min.apply(Math, arry);
    return $.inArray(minValue,arry);
  }

  function initialRange(num) {
    var arry = [];
    for ( var i=0; i < num; i++ )
      arry.push(0);
    return arry;
  }

  function childElementInfo(elem) {
    var width = $(elem).outerWidth();
    var parentWidth = $(elem).offsetParent().width();
    return {
      'width' : 100 * width / parentWidth,
      'num'   : Math.floor(parentWidth / width)
    };
  }

    $.fn.simplemasonry = function(options) {
    if ( typeof options == 'string') {
      var instance = $(this).data('simplemasonry');
      var args = Array.prototype.slice.call(arguments, 1);
      if ( instance[options] )
        return instance[options].apply(instance, args);
      return;
    } else {
      return this.each(function() {
        if (undefined == $(this).data('simplemasonry')) {
          var plugin = new $.simplemasonry(this, options);
          $(this).data('simplemasonry', plugin);
        }
      });
    }
    }

})(jQuery);

function remove_flash() {
    if($('#flash').length > 0) {
        $('#flash').css({
            top: '+=50'
        });
        setTimeout(function(){
            $('#flash').css({
                top: '-=70',
                opacity: 0
            });
            setTimeout(function(){
                $('#flash').remove();
            }, 500);
        }, 9000);
    };
}

function close_dialog() {
  $('#new_issue').html('')
}

/*! http://mths.be/placeholder v2.0.7 by @mathias */
;(function(f,h,$){var a='placeholder' in h.createElement('input'),d='placeholder' in h.createElement('textarea'),i=$.fn,c=$.valHooks,k,j;if(a&&d){j=i.placeholder=function(){return this};j.input=j.textarea=true}else{j=i.placeholder=function(){var l=this;l.filter((a?'textarea':':input')+'[placeholder]').not('.placeholder').bind({'focus.placeholder':b,'blur.placeholder':e}).data('placeholder-enabled',true).trigger('blur.placeholder');return l};j.input=a;j.textarea=d;k={get:function(m){var l=$(m);return l.data('placeholder-enabled')&&l.hasClass('placeholder')?'':m.value},set:function(m,n){var l=$(m);if(!l.data('placeholder-enabled')){return m.value=n}if(n==''){m.value=n;if(m!=h.activeElement){e.call(m)}}else{if(l.hasClass('placeholder')){b.call(m,true,n)||(m.value=n)}else{m.value=n}}return l}};a||(c.input=k);d||(c.textarea=k);$(function(){$(h).delegate('form','submit.placeholder',function(){var l=$('.placeholder',this).each(b);setTimeout(function(){l.each(e)},10)})});$(f).bind('beforeunload.placeholder',function(){$('.placeholder').each(function(){this.value=''})})}function g(m){var l={},n=/^jQuery\d+$/;$.each(m.attributes,function(p,o){if(o.specified&&!n.test(o.name)){l[o.name]=o.value}});return l}function b(m,n){var l=this,o=$(l);if(l.value==o.attr('placeholder')&&o.hasClass('placeholder')){if(o.data('placeholder-password')){o=o.hide().next().show().attr('id',o.removeAttr('id').data('placeholder-id'));if(m===true){return o[0].value=n}o.focus()}else{l.value='';o.removeClass('placeholder');l==h.activeElement&&l.select()}}}function e(){var q,l=this,p=$(l),m=p,o=this.id;if(l.value==''){if(l.type=='password'){if(!p.data('placeholder-textinput')){try{q=p.clone().attr({type:'text'})}catch(n){q=$('<input>').attr($.extend(g(this),{type:'text'}))}q.removeAttr('name').data({'placeholder-password':true,'placeholder-id':o}).bind('focus.placeholder',b);p.data({'placeholder-textinput':q,'placeholder-id':o}).before(q)}p=p.removeAttr('id').hide().prev().attr('id',o).show()}p.addClass('placeholder');p[0].value=p.attr('placeholder')}else{p.removeClass('placeholder')}}}(this,document,jQuery));

/*!
 * jQuery Cookie Plugin v1.3.1
 * https://github.com/carhartl/jquery-cookie
 *
 * Copyright 2013 Klaus Hartl
 * Released under the MIT license
 */
(function (factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD. Register as anonymous module.
    define(['jquery'], factory);
  } else {
    // Browser globals.
    factory(jQuery);
  }
}(function ($) {

  var pluses = /\+/g;

  function decode(s) {
    if (config.raw) {
      return s;
    }
    return decodeURIComponent(s.replace(pluses, ' '));
  }

  function decodeAndParse(s) {
    if (s.indexOf('"') === 0) {
      // This is a quoted cookie as according to RFC2068, unescape...
      s = s.slice(1, -1).replace(/\\"/g, '"').replace(/\\\\/g, '\\');
    }

    s = decode(s);

    try {
      return config.json ? JSON.parse(s) : s;
    } catch(e) {}
  }

  var config = $.cookie = function (key, value, options) {

    // Write
    if (value !== undefined) {
      options = $.extend({}, config.defaults, options);

      if (typeof options.expires === 'number') {
        var days = options.expires, t = options.expires = new Date();
        t.setDate(t.getDate() + days);
      }

      value = config.json ? JSON.stringify(value) : String(value);

      return (document.cookie = [
        config.raw ? key : encodeURIComponent(key),
        '=',
        config.raw ? value : encodeURIComponent(value),
        options.expires ? '; expires=' + options.expires.toUTCString() : '', // use expires attribute, max-age is not supported by IE
        options.path    ? '; path=' + options.path : '',
        options.domain  ? '; domain=' + options.domain : '',
        options.secure  ? '; secure' : ''
      ].join(''));
    }

    // Read
    var cookies = document.cookie.split('; ');
    var result = key ? undefined : {};
    for (var i = 0, l = cookies.length; i < l; i++) {
      var parts = cookies[i].split('=');
      var name = decode(parts.shift());
      var cookie = parts.join('=');

      if (key && key === name) {
        result = decodeAndParse(cookie);
        break;
      }

      if (!key) {
        result[name] = decodeAndParse(cookie);
      }
    }

    return result;
  };

  config.defaults = {};

  $.removeCookie = function (key, options) {
    if ($.cookie(key) !== undefined) {
      // Must not alter options, thus extending a fresh object...
      $.cookie(key, '', $.extend({}, options, { expires: -1 }));
      return true;
    }
    return false;
  };

}));