require 'grom'
require 'uri'
require_relative '../../lib/grom/helpers'

module Grom
  class Base
    extend Grom::GraphMapper
    extend Grom::Helpers

    def initialize(attributes)
      attributes.each do |k, v|
        translated_key = self.class.property_translator[k]
        v = self.class.create_property_name(self.class.get_id(v)) if (v =~ URI::regexp) == 0
        unless v.nil? || translated_key.nil?
          instance_variable_set("@#{translated_key}", v)
          self.class.send(:attr_reader, translated_key)
        end
      end
    end

    def self.find(id)
      endpoint_url = "#{find_base_url_builder(self.name, id)}.ttl"
      graph_data = get_graph_data(endpoint_url)
      self.object_single_maker(graph_data)
    end

    def self.all(*options)
      endpoint_url = "#{all_base_url_builder(self.name, *options)}.ttl"
      graph_data = get_graph_data(endpoint_url)
      self.object_array_maker(graph_data)
    end

    def self.has_many(association)
      self.class_eval("def #{association}(*options); #{create_class_name(association)}.has_many_query(self, *options); end")
    end

    def self.has_many_through(association, through_association)
      self.has_many(through_association[:via])
      self.class_eval("def #{association}(*options); #{create_class_name(association)}.has_many_through_query(self, #{create_class_name(through_association[:via])}.new({}).class.name, *options); end")
    end

    def self.has_one(association)
      self.class_eval("def #{association}(*options); #{create_class_name(association)}.has_one_query(self, *options); end")
    end

    def self.has_many_query(owner_object, *options)
      endpoint_url = associations_url_builder(owner_object, self.name, {optional: options })
      graph_data = get_graph_data(endpoint_url)
      self.object_array_maker(graph_data)
    end

    def self.has_one_query(owner_object, *options)
      endpoint_url = associations_url_builder(owner_object, self.name, {optional: options, single: true })
      graph_data = get_graph_data(endpoint_url)
      self.object_single_maker(graph_data)
    end

    def self.through_getter_setter(through_property_plural)
      self.class_eval("def #{through_property_plural}=(array); @#{through_property_plural} = array; end")
      self.class_eval("def #{through_property_plural}; @#{through_property_plural}; end")
    end

    def self.object_array_maker(graph_data)
      self.statements_mapper(graph_data).map do |data|
        self.new(data)
      end
    end

    def self.object_single_maker(graph_data)
      self.object_array_maker(graph_data).first
    end

    def self.has_many_through_query(owner_object, through_class, *options)
      through_property_plural = create_plural_property_name(through_class)
      endpoint_url = associations_url_builder(owner_object, self.name, {optional: options })
      self.through_getter_setter(through_property_plural)
      graph = get_graph_data(endpoint_url)
      self.map_hashes_to_objects(through_split_graph(graph), through_property_plural)
    end

    def self.map_hashes_to_objects(hashes, through_property_plural)
      through_array = hashes[:through_class_hash].values
      hashes[:associated_class_hash].values.map do |hash|
        associated_object = self.new(hash)
        through_obj_array, through_array = through_array.partition do |t_hash|
          t_hash[:associated_object_id] == associated_object.id
        end
        associated_object.send((through_property_plural + '=').to_sym, through_obj_array)
        associated_object
      end
    end
  end
end