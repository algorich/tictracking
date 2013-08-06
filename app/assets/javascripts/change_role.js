jQuery(function() {
    $('.team').on('change', '.set_admin', function() {
        $that = $(this);
        var id = $that.data('membership-id');
        var val = $that.val();

        $.ajax({
            url: $that.data('url'),
            data: { membership_id: id, role: val},
            type: 'POST'
        }).done(function(data) {
            if (data.success === false) {
                $that.val('admin');
                app_show_flash_message('error', data.message)
            } else {
                $('.alert').addClass('hide');
            };
        });
    });
});