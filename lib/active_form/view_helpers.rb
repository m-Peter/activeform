module ActiveForm
  module ViewHelpers

    def link_to_remove_association(*args)
      name         = args[0]
      f            = args[1]
      html_options = args[2] || {}
      is_existing = f.object.persisted?

      classes = []
      classes << "remove_fields"
      classes << (is_existing ? 'existing' : 'dynamic')
      #classes << 'destroyed' if f.object.marked_for_destruction?
      html_options[:class] = [html_options[:class], classes.join(' ')].compact.join(' ')

      wrapper_class = html_options.delete(:wrapper_class)
      html_options[:'data-wrapper-class'] = wrapper_class if wrapper_class.present?

      if is_existing
        f.hidden_field(:_destroy) + link_to(name, '#', html_options)
      else
        link_to(name, '#', html_options)
      end
    end

    def render_association(association, f, new_object, form_name, render_options={}, custom_partial=nil)
      partial = get_partial_path(custom_partial, association)
      locals =  render_options.delete(:locals) || {}
      method_name = f.respond_to?(:semantic_fields_for) ? :semantic_fields_for : (f.respond_to?(:simple_fields_for) ? :simple_fields_for : :fields_for)
      
      f.send(method_name, association, new_object, {:child_index => "new_#{association}"}.merge(render_options)) do |builder|
        partial_options = {form_name.to_sym => builder, :dynamic => true}.merge(locals)
        render(partial, partial_options)
      end
    end

    def link_to_add_association(*args)
      name         = args[0]
      f            = args[1]
      association  = args[2]
      html_options = args[3] || {}

      render_options   = html_options.delete(:render_options)
      render_options ||= {}
      override_partial = html_options.delete(:partial)
      form_parameter_name = html_options.delete(:form_name) || 'f'
      count = html_options.delete(:count).to_i

      html_options[:class] = [html_options[:class], "add_fields"].compact.join(' ')
      html_options[:'data-association'] = association.to_s.singularize
      html_options[:'data-associations'] = association.to_s.pluralize

      new_object = create_object(f, association)

      html_options[:'data-association-insertion-template'] = CGI.escapeHTML(render_association(association, f, new_object, form_parameter_name, render_options, override_partial).to_str).html_safe

      html_options[:'data-count'] = count if count > 0
        
      link_to(name, '#', html_options)
    end
    
    def create_object(f, association)
      f.object.get_model(association)
    end

    def get_partial_path(partial, association)
      partial ? partial : association.to_s.singularize + "_fields"
    end
  end
end
