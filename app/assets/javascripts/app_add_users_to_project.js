$(document).ready(function() {
    var $selector = $("#add_user_to_project");
    var $add_button = $("#app_add_user_to_project");

    $add_button.click(function() {
        var id = $selector.val();

        $.ajax($(this).data('url'), {
            data: {user_id: id},
            type: 'POST'
        });
        $selector.select2('val', '');
    });
});