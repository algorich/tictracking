jQuery(function() {
    $('.team').on('change', '.set_admin', function() {
        var id = this.value;
        var that = $(this);
        var project_id = that.data('project');
        var $alert = $('.alert-error');

        $.ajax($(this).data('url'), {
            data: { admin_id: id },
            type: 'POST'
        }).done(function(data) {
            if (data.success === false) {
                $(that).prop('checked', true);
                $alert.text(data.message);
                $alert.removeClass('hide');
            } else {
                $alert.text('');
                $alert.addClass('hide');
            };
        });
    });
});