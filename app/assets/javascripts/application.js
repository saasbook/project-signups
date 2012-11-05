// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

var hideFlashTimeout;

function showFlashMessage(message, type) {
  if (type == 'notice') {
    $('.flash-messages .notice').text(message).show();
    $('.flash-messages .error').text('').hide();
  } else if (type == 'error') {
    $('.flash-messages .error').text(message).show();
    $('.flash-messages .notice').text('').hide();
  }
  $('.flash-messages').slideDown();
  clearTimeout(hideFlashTimeout);
  hideFlashTimeout = setTimeout(function() {
    $('.flash-messages').slideUp();
  }, 5000);
}


$('.flash-messages').live('click', function(e) {
  clearTimeout(hideFlashTimeout);
  $(this).slideUp();
});

var Colors = {
  scoreToRgba: function(score, min, max, alpha) {
    var mid         = Math.floor((min+max)/2),
        redValue,
        greenValue,
        blueValue;
    if (score <= mid) {
      redValue    = parseInt(38/5*score + 205),
      greenValue  = parseInt(194/5*score + 38),
      blueValue   = parseInt(104/5*score + 38);
    } else {
      redValue    = parseInt(-167/5*score + 410),
      greenValue  = parseInt(-45/5*score + 266),
      blueValue   = parseInt(-119/5*score + 261);
    }
    return 'rgba('+redValue+', '+greenValue+', '+blueValue+', '+alpha+')';
  }
};
