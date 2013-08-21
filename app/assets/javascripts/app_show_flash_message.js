function app_show_flash_message (type, text) {
  clean_up();
  var element = $('.alert')[0];
  var $alert = $(element);
  $alert.addClass('alert-' + type);
  $alert.children('span').text(text);
  $alert.removeClass('hide');
}

function clean_up () {
  var element = $('.alert')[0];
  var $alert = $(element);
  $alert.removeClass('alert-success alert-error')
  $alert.addClass('hide');
  $alert.children('span').text('');
};

