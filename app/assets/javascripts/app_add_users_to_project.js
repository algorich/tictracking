$(document).ready(function() {
    var $user_selector = $('#add_user_to_project');
    var $user_role_selector = $('#add_user_role_to_project')
    var $add_button = $('#app_add_user_to_project');

    $add_button.click(function() {
        var id = $user_selector.val();
        var role = $user_role_selector.val();

        $.ajax($(this).data('url'), {
            data: {user_id: id, user_role: role},
            type: 'POST'
        });
        $user_selector.select2('val', '');
    });
});