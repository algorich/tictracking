jQuery(function() {
    $('.team').on('change', '.set_admin', function() {
        var $that = $(this);
        var id = $that.data('user-id');

        $.ajax({
            url: $that.data('url'),
            data: { admin_id: id },
            type: 'POST'
        }).done(function(data) {
            if (data.success === false) {
                $that.prop('checked', true);
                app_show_flash_message('error', data.message)
            } else {
                $('.alert').addClass('hide');
            };
        });
    });
});