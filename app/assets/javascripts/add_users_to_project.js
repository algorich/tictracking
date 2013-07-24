$(document).ready(function() {
    var $selector = $("#add_user_to_project");

    $selector.change(function() {
        var id = this.value
        $.ajax($(this).data('url'), {
            data: {user_id: id},
            type: 'POST'
        });
        $(this).select2('val', '');
    });
});