(function($) {

  var create_new_id = function() {
    return new Date().getTime();
  }

  $(document).on('click', '.add_fields', function(e) {
    e.preventDefault();
    
    var $link = $(this);
    var assoc = $link.data('association');
    var content = $link.data('association-insertion-template');
    var insertionMethod = $link.data('association-insertion-method') || $link.data('association-insertion-position') || 'before';
    var insertionNode = $link.data('association-insertion-node');
    var insertionTraversal = $link.data('association-insertion-traversal');
    var new_id = create_new_id();
    var regex = new RegExp("new_" + assoc, "g");
    var new_content = content.replace(regex, new_id);

    if (insertionNode){
      if (insertionTraversal){
        insertionNode = $link[insertionTraversal](insertionNode);
      } else {
        insertionNode = insertionNode == "this" ? $link : $(insertionNode);
      }
    } else {
      insertionNode = $link.parent();
    }

    var contentNode = $(new_content);
    insertionNode.trigger('before-insert', [contentNode]);

    var addedContent = insertionNode[insertionMethod](contentNode);

    insertionNode.trigger('after-insert', [contentNode]);
  });

  $(document).on('click', '.remove_fields.dynamic, .remove_fields.existing', function(e) {
    e.preventDefault();

    var $link = $(this);
    var wrapper_class = $link.data('wrapper-class') || 'nested-fields';
    var node_to_delete = $link.closest('.' + wrapper_class);
    var trigger_node = node_to_delete.parent();

    trigger_node.trigger('before-remove', [node_to_delete]);

    var timeout = trigger_node.data('remove-timeout') || 0;

    setTimeout(function() {
      if ($link.hasClass('dynamic')) {
          node_to_delete.remove();
      } else {
          $link.prev("input[type=hidden]").val("1");
          node_to_delete.hide();
      }
      trigger_node.trigger('after-remove', [node_to_delete]);
    }, timeout);
  });

})(jQuery);