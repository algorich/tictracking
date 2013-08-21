$(function() {
    $('#app-content').on('click', 'a.app-btn-loading', function  () {
        $(this).button('loading');
    });
});