var $window = $(window),
    $stickyEl = $('#app_flash_message'),
    elTop = $stickyEl.offset().top,
    $old_alert = null;

// sticky functions
$window.scroll(function() {
    toggle_sticky_class($stickyEl);
});

function toggle_sticky_class (element) {
    element.toggleClass('sticky', $window.scrollTop() > elTop);
};

// show flash_message functions
function app_show_flash_message (type, text) {
  clean_up();
  if (text != '') {
    var element = $('.alert')[0];
    var $alert = $(element);
    $alert.addClass('alert-' + type);
    $alert.children('span').text(text);
    $alert.removeClass('hide');
  };
}

function clean_up () {
  $('.alert').addClass('hide');;
  if ($old_alert != null) {
    $('#app_flash_message_container').html($old_alert);

    // to be an sticky element
    $stickyEl = $old_alert
    toggle_sticky_class($stickyEl);
  };

  var $alert = $('#app_flash_message');
  $alert.removeClass('alert-success alert-error');
  $alert.children('span').text('');
  $old_alert = $alert.clone();
};