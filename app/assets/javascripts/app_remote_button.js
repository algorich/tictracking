$(document).ready(function() {
    $('#app-content').on('click', '.app-remote-button', function  () {
        var $button = $(this);

        $.ajax($button.data('url'), {
            type: 'PUT'
        });
    });
});