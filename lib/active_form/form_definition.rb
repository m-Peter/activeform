module ActiveForm
  class FormDefinition
    attr_accessor :assoc_name, :proc, :parent, :records
    
    def initialize(args={})
      assign_arguments(args)
    end

    def to_form
      if !association_reflection
        return nil
      end
      
      macro = association_reflection.macro

      case macro
      when :has_one
        Form.new(assoc_name, parent, proc)
      when :has_many
        FormCollection.new(assoc_name, parent, proc, {records: records})
      end
    end

    private

    def assign_arguments(args={})
      args.each do |key, value|
        send("#{key}=", value) if respond_to?(key)
      end
    end

    def association_reflection
      parent.class.reflect_on_association(@assoc_name)
    end
  end

end