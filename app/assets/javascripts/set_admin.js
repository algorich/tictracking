$(document).ready(function() 
{
    $('.set_admin').change(function() {
        var id = this.value;
        var project_id = $(this).data('project')
        $.post('/projects/' + project_id + '/change_admin?admin_id=' + id);
    });
});