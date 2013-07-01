// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require select2
//= require_tree .
//= require_self


$(function () {
    var $projectNameWrapper = $('#app-project-name-wrapper');
    var $projectName = $projectNameWrapper.find('h1');

    $projectNameWrapper.on('click', 'h1', function() {
        $projectNameWrapper.html('<input type="text" value="'+ $projectName.text() +'" />');
        $projectNameWrapper.find('input').focus();
    });

    function updateProjectWrapper () {
        $projectNameWrapper.html($projectName.get(0))
    }

    $projectNameWrapper.on('keyup', 'input', function(event) {
        if(event.keyCode === 27) { // esc key
            updateProjectWrapper();
        }
        else if(event.keyCode === 13) { // return key
            var newProjectName = $projectNameWrapper.find('input').val()

            $.ajax({
                url: $projectNameWrapper.data('url'),
                type: 'PUT',
                data: { project: { name: newProjectName } },
                success: function () {
                    $projectName.text(newProjectName);
                    updateProjectWrapper();
                },
                error: function(response) {
                    alert('name ' + response.responseJSON.name[0])
                }
            })
        }
    });
});