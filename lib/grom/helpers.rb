require 'grom'

module Grom
  module Helpers

    def associations_url_builder(owner_object, associated_class_name, options={})
      id = owner_object.id
      associated_class_name = options[:single].nil? ? create_plural_property_name(associated_class_name) : create_property_name(associated_class_name)
      endpoint = "#{find_base_url_builder(owner_object.class.name, id)}/#{associated_class_name}"
      endpoint += options[:optional].nil? ? '.ttl' : "/#{options[:optional]}.ttl"
    end

    def find_base_url_builder(class_name, id)
      "#{API_ENDPOINT}/#{create_plural_property_name(class_name)}/#{id}"
    end

    def all_base_url_builder(class_name, *options)
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

    def collective_graph(objects)
      collective_graph = RDF::Graph.new
      objects.each do |o|
        collective_graph << o.graph
      end
      collective_graph
    end

    def collective_has_many_graph(owner, association)
      owner.graph << collective_graph(association)
    end

    def collective_through_graph(owner, association, through_property)
      graph = owner.graph
      association.each do |associated_object|
        graph << associated_object.graph
        associated_object.send(through_property).each do |through_object|
          graph << through_object.graph
        end
      end
      graph
    end

    def order_list(arr, *parameters)
      arr.sort_by do |obj|
        parameters.map{ |param| obj.send(param) }
      end
    end
  end
end