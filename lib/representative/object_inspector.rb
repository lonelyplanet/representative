# frozen_string_literal: true

module Representative
  class ObjectInspector
    def get_value(object, attribute_name)
      object.send(attribute_name)
    end

    def get_metadata(_object, _attribute_name)
      {}
    end
  end
end
