jQuery(function() {
    $('.team').on('change', '.set_admin', function() {
        var $that = $(this);
        var id = $that.data('user-id');
        var $alert = $('.alert-error');

        $.ajax({
            url: $that.data('url'),
            data: { admin_id: id },
            type: 'POST'
        }).done(function(data) {
            if (data.success === false) {
                $that.prop('checked', true);
                $alert.text(data.message);
                $alert.removeClass('hide');
            } else {
                $alert.text('');
                $alert.addClass('hide');
            };
        });
    });
});