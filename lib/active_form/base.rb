module ActiveForm
  class Base
    include ActiveModel::Model
    extend ActiveModel::Callbacks

    define_model_callbacks :save, only: [:after]

    after_save :update_form_models
    
    attr_reader :model, :forms

    def initialize(model)
      @model = model
      @forms = []
      populate_forms
    end
    
    def submit(params)
      params.each do |key, value|
        if nested_params?(value)
          fill_association_with_attributes(key, value)
        else
          send("#{key}=", value)
        end
      end
    end

    def get_model(assoc_name)
      form = find_form_by_assoc_name(assoc_name)
      form.get_model(assoc_name)
    end

    def save
      if valid?
        run_callbacks :save do
          ActiveRecord::Base.transaction do
              model.save
            end
        end
      else
        false
      end
    end

    def valid?
      super
      model.valid?

      collect_errors_from(model)
      aggregate_form_errors
      
      errors.empty?
    end

    def persisted?
      model.persisted?
    end

    def to_key
      model.to_key
    end

    def to_param
      model.to_param
    end

    def to_partial_path
      model.to_partial_path
    end

    def to_model
      model
    end

    class << self
      attr_accessor :model_class

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
        model_class.reflect_on_association(association)
      end

      def declare_form_collection(name, options={}, &block)
        forms << FormDefinition.new({assoc_name: name, records: options[:records], proc: block})
        self.class_eval("def #{name}; @#{name}.models; end")
        define_method("#{name}_attributes=") {}
      end

      def declare_form(name, &block)
        forms << FormDefinition.new({assoc_name: name, proc: block})
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

    def update_form_models
      forms.each do |form|
        form.update_models
      end
    end

    def populate_forms
      self.class.forms.each do |definition|
        definition.parent = model
        form = definition.to_form
        forms << form
        name = definition.assoc_name
        instance_variable_set("@#{name}", form)
      end
      self.class.model_class = model.class
    end

    def nested_params?(value)
      value.is_a?(Hash)
    end

    ATTRIBUTES_KEY_REGEXP = /^(.+)_attributes$/

    def find_association_name_in(key)
      ATTRIBUTES_KEY_REGEXP.match(key)[1]
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