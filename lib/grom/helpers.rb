require 'grom'

module Grom
  module Helpers

    def url_builder(owner_object, associated_class_name, options={})
      id = owner_object.id
      associated_class_name = options[:single].nil? ? create_plural_property_name(associated_class_name) : create_property_name(associated_class_name)
      endpoint = "#{base_url_builder(owner_object.class.name, id)}/#{associated_class_name}"
      endpoint += options[:optional].nil? ? '.ttl' : "/#{options[:optional]}.ttl"
    end

    def base_url_builder(class_name, id=nil)
      endpoint = "#{API_ENDPOINT}/#{create_plural_property_name(class_name)}"
      endpoint += id.nil? ? "" : "/#{id}"
    end

    def create_class_name(plural_name)
      ActiveSupport::Inflector.camelize(ActiveSupport::Inflector.singularize(plural_name.to_s).capitalize)
    end

    def create_plural_property_name(class_name)
      ActiveSupport::Inflector.pluralize(create_property_name(class_name))
    end

    def create_property_name(class_name)
      ActiveSupport::Inflector.underscore(class_name).downcase
    end
  end
end