module ActiveForm
  module ViewHelpers

    def link_to_remove_association(*args, &block)
      if block_given?
        f            = args.first
        html_options = args.second || {}
        name         = capture(&block)
        link_to_remove_association(name, f, html_options)
      else
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

    def link_to_add_association(*args, &block)
      if block_given?
        f            = args[0]
        association  = args[1]
        html_options = args[2] || {}
        link_to_add_association(capture(&block), f, association, html_options)
      else
        name         = args[0]
        f            = args[1]
        association  = args[2]
        html_options = args[3] || {}

        render_options   = html_options.delete(:render_options)
        render_options ||= {}
        override_partial = html_options.delete(:partial)
        wrap_object = html_options.delete(:wrap_object)
        force_non_association_create = html_options.delete(:force_non_association_create) || false
        form_parameter_name = html_options.delete(:form_name) || 'f'
        count = html_options.delete(:count).to_i

        html_options[:class] = [html_options[:class], "add_fields"].compact.join(' ')
        html_options[:'data-association'] = association.to_s.singularize
        html_options[:'data-associations'] = association.to_s.pluralize

        new_object = create_object(f, association, force_non_association_create)
        new_object = wrap_object.call(new_object) if wrap_object.respond_to?(:call)

        html_options[:'data-association-insertion-template'] = CGI.escapeHTML(render_association(association, f, new_object, form_parameter_name, render_options, override_partial).to_str).html_safe

        html_options[:'data-count'] = count if count > 0
        
        link_to(name, '#', html_options)
      end
    end
    
    def create_object(f, association, force_non_association_create=false)
      f.object.get_model(association)
    end

    def get_partial_path(partial, association)
      partial ? partial : association.to_s.singularize + "_fields"
    end

    private

    def create_object_on_non_association(f, association)
      builder_method = %W{build_#{association} build_#{association.to_s.singularize}}.select { |m| f.object.respond_to?(m) }.first
      return f.object.send(builder_method) if builder_method
      raise "Association #{association} doesn't exist on #{f.object.class}"
    end

    def create_object_on_association(f, association, instance, force_non_association_create)
      if instance.class.name == "Mongoid::Relations::Metadata" || force_non_association_create
        create_object_with_conditions(instance)
      else
        assoc_obj = nil

        # assume ActiveRecord or compatible
        if instance.collection?
          assoc_obj = f.object.send(association).build
          f.object.send(association).delete(assoc_obj)
        else
          assoc_obj = f.object.send("build_#{association}")
          f.object.send(association).delete
        end

        assoc_obj = assoc_obj.dup if assoc_obj.frozen?

        assoc_obj
      end
    end

    def create_object_with_conditions(instance)
      # in rails 4, an association is defined with a proc
      # and I did not find how to extract the conditions from a scope
      # except building from the scope, but then why not just build from the
      # association???
      conditions = instance.respond_to?(:conditions) ? instance.conditions.flatten : []
      instance.klass.new(*conditions)
    end
  end
end