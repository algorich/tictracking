$(document).ready(function() {
  /* Activating Best In Place */
  $(".best_in_place")
    .best_in_place()
    .bind("ajax:success", function(){
      app_show_flash_message("success", "Updated with success");
    });
});

$( document ).ajaxError(function(event, jqxhr, settings, exception) {
  if ( jqxhr.status == 422 ) {
    var messages = get_messages(jqxhr.responseText);

    $.each(messages, function(index, message) {
      app_show_flash_message("error", message);
    });
  };
});

function get_messages (text) {
  var json_object = $.parseJSON(text);
  var messages = []
  $.each(json_object.errors, function(type, reason) {
    messages.push('"' + type.charAt(0).toUpperCase() + type.slice(1) + '" '  + reason);
  });
  return messages;
}