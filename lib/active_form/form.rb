module ActiveForm
  class Form
    include ActiveModel::Validations

    attr_reader :association_name, :parent, :model, :forms, :proc

    def initialize(assoc_name, parent, proc, model=nil)
      @association_name = assoc_name
      @parent = parent
      @model = assign_model(model)
      @forms = []
      @proc = proc
      class_eval &proc
      enable_autosave
      populate_forms
    end

    def submit(params)
      params.each do |key, value|
        if nested_params?(value)
          fill_association_with_attributes(key, value)
        else
          model.send("#{key}=", value)
        end
      end
    end

    def get_model(assoc_name)
      if form = find_form_by_assoc_name(assoc_name)
        form.get_model(assoc_name)
      else  
        Form.new(association_name, parent, proc)
      end
    end

    def delete
      model.mark_for_destruction
    end

    def valid?
      super
      model.valid?

      collect_errors_from(model)
      aggregate_form_errors
      
      errors.empty?
    end

    def id
      model.id
    end

    def _destroy
      model.marked_for_destruction?
    end

    def persisted?
      model.persisted?
    end

    def represents?(assoc_name)
      association_name.to_s == assoc_name.to_s
    end
    
    class << self
      attr_reader :forms

      def attributes(*names)
        options = names.pop if names.last.is_a?(Hash)

        if options && options[:required]
          validates_presence_of *names
        end
        
        names.each do |attribute|
          delegate attribute, to: :model
          delegate "#{attribute}=", to: :model
        end
      end

      alias_method :attribute, :attributes

      def association(name, options={}, &block)
        if is_plural?(name)
          declare_form_collection(name, options, &block)
        else  
          declare_form(name, &block)
        end
      end

      def reflect_on_association(association)
        ProjectTag.reflect_on_association(association)
      end

      def declare_form_collection(name, options={}, &block)
        Form.instance_variable_set(:@forms, forms)
        Form.forms << FormDefinition.new({assoc_name: name, records: options[:records], proc: block})
        self.class_eval("def #{name}; @#{name}.models; end")
        define_method("#{name}_attributes=") {}
      end

      def declare_form(name, &block)
        Form.instance_variable_set(:@forms, forms)
        Form.forms << FormDefinition.new({assoc_name: name, proc: block})
        attr_reader name
        define_method("#{name}_attributes=") {}
      end

      def forms
        @forms ||= []
      end

      def is_plural?(str)
        str = str.to_s
        str.pluralize == str
      end
    end

    private

    ATTRIBUTES_KEY_REGEXP = /^(.+)_attributes$/

    def enable_autosave
      reflection = association_reflection
      reflection.autosave = true
    end

    def fill_association_with_attributes(association, attributes)
      assoc_name = find_association_name_in(association).to_sym
      form = find_form_by_assoc_name(assoc_name)
      
      form.submit(attributes)
    end

    def find_form_by_assoc_name(assoc_name)
      forms.each do |form|
        return form if form.represents?(assoc_name)
      end
    end

    def nested_params?(value)
      value.is_a?(Hash)
    end

    def find_association_name_in(key)
      ATTRIBUTES_KEY_REGEXP.match(key)[1]
    end

    def populate_forms
      self.class.forms.each do |definition|
        definition.parent = model
        form = definition.to_form
        return unless form
        forms << form
        name = definition.assoc_name
        instance_variable_set("@#{name}", form)
      end
    end

    def association_reflection
      parent.class.reflect_on_association(association_name)
    end

    def build_model
      macro = association_reflection.macro

      case macro
      when :has_one
        fetch_or_initialize_model
      when :has_many
        parent.send(association_name).build
      end
    end

    def fetch_or_initialize_model
      if parent.send("#{association_name}")
        parent.send("#{association_name}")
      else
        parent.send("build_#{association_name}")
      end
    end

    def assign_model(model)
      if model
        model
      else
        build_model
      end
    end

    def aggregate_form_errors
      forms.each do |form|
        form.valid?
        collect_errors_from(form)
      end
    end

    def collect_errors_from(validatable_object)
      validatable_object.errors.each do |attribute, error|
        errors.add(attribute, error)
      end
    end
  end

end