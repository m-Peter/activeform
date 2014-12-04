module ActiveForm
  class AttributeWhitelist
    attr_reader :whitelisted_attrs

    def initialize(attrs)
      @whitelisted_attrs = attrs
      @whitelisted_attrs << :id
      @whitelisted_attrs << :_destroy
    end

    def allows?(attribute)
      @whitelisted_attrs.include?(attribute)
    end
  end
end