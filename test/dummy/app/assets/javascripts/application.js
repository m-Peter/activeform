// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require_tree .

(function($) {
  $(document).on('click', '.remove_fields.dynamic, .remove_fields.existing', function(e) {
    var $this = $(this), 
        node_to_delete = $this.closest('.nested-fields');

    e.preventDefault();

    if ($this.hasClass('dynamic')) {
        node_to_delete.remove();
    } else {
        $this.prev("input[type=hidden]").val("1");
        node_to_delete.hide();
    }
  });

  $(document).on('click', '.add_fields', function(e) {
    e.preventDefault();
    
    var $this = $(this),
      association = $this.data('association'),
      content = $this.data('association-insertion-template');

    var new_id = new Date().getTime();
    var regex = new RegExp("new_" + association, "g");
    $this.before(content.replace(regex, new_id));
  });
})(jQuery);