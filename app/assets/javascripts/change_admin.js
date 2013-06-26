$(document).ready(function()
{
    $('.set_admin').change(function() {
        var id = this.value;
        var that = $(this);
        var project_id = that.data('project');
        var url = '/projects/' + project_id + '/change_admin?admin_id=' + id;
        var $alert = $('.alert');

        $.post(url, function(data) {
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