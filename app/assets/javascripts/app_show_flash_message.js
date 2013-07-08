function app_show_flash_message (type, text) {
  clean_up();
  var $flash = $('.alert-' + type);
  $flash.children('span').text(text);
  $flash.removeClass('hide');
}

function clean_up () {
  $('.alert').addClass('hide');
  $('.alert span').text('');
};