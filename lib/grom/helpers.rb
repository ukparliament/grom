require 'grom'

module Grom
  module Helpers

    def associations_url_builder(owner_object, associated_class_name, options={})
      id = owner_object.id
      associated_class_name = options[:single].nil? ? create_plural_property_name(associated_class_name) : create_property_name(associated_class_name)
      endpoint = "#{find_base_url_builder(owner_object.class.name, id)}/#{associated_class_name}"
      if options[:optional].nil?
        endpoint += '.ttl'
      else
        options[:optional].each do |option|
          endpoint += "/#{option}" unless option.nil?
        end
        endpoint += '.ttl'
      end
      endpoint
    end

    def find_base_url_builder(class_name, id, *options)
      endpoint = "#{API_ENDPOINT}/#{create_plural_property_name(class_name)}/#{id}"
      options.each do |option|
        endpoint += "/#{option}" unless option.nil?
      end
      endpoint
    end

    def base_url_builder(class_name, *options)
      endpoint = "#{API_ENDPOINT}/#{create_plural_property_name(class_name)}"
        options.each do |option|
          endpoint += "/#{option}" unless option.nil?
        end
      endpoint
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

    def order_list(arr, *parameters)
      rejected = []
      arr.delete_if{ |obj| rejected << obj if parameters.any?{ |param| obj.send(param).nil? } }
      sorted_arr = arr.sort_by do |obj|
        parameters.map{ |param| obj.send(param) }.select{ |p| not p.nil? }
      end
      rejected.concat(sorted_arr)
    end

    def order_list_by_through(arr, through_association, property)
      arr.map{ |obj| obj.send(through_association) }.flatten.sort{ |a, b| a[property] <=> b[property] }
    end

    def json_ld(data)
      data = [data] unless data.is_a?(Array)
      json_ld = {}
      json_ld["@context"] = data.first.class.context
      json_ld["@graph"] = data.map do |object|
        json_ld_object_mapper(object)
      end
      json_ld.to_json
    end

    def json_ld_object_mapper(object)
      hash = { "@type": object.class.type }
      object.instance_variables.each do |variable_name|
        getter = "#{variable_name}".tr('@', '')
        string_variable_name = variable_name.to_s
        if string_variable_name == "@id"
          hash[string_variable_name] = "#{object.class.id_prefix}#{(object.send(getter))}"
        else
          property_name = object.class.property_translator.key(getter)
          hash[property_name] = object.send(getter) unless property_name.nil?
        end
      end
      hash
    end

  end
end