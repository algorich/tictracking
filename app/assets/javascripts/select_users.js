$(document).ready(function() {
    var $selector = $("#select_users_by_select2");

    $selector.select2({
        placeholder: "Make your choise"
    });

    $selector.change(function() {
        var id = this.value
        $.ajax($(this).data('url'), {
            data: {user_id: id},
            type: 'POST'
        });
        $(this).select2('val', '');
    });
});