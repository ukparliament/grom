require 'grom'
require 'uri'
require 'active_support/all'
require_relative '../../lib/grom/helpers'

module Grom
  class Base
    extend Grom::GraphMapper
    extend Grom::Helpers
    extend ActiveSupport::Inflector

    def initialize(attributes)
      p attributes
      ttl_graph = self.class.convert_to_ttl(attributes[:graph])
      self.class.class_eval("def graph;  self.class.create_graph_from_ttl('#{ttl_graph}') ; end")
      attributes.delete(:graph)
      attributes.each do |k, v|
        translated_key = self.class.property_translator[k]
        v = self.class.create_property_name(self.class.get_id(v)) if (v =~ URI::regexp) == 0
        instance_variable_set("@#{translated_key}", v) unless v.nil?
        self.class.send(:attr_reader, translated_key)
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
      self.class_eval("def #{association}(optional=nil); #{create_class_name(association)}.has_many_query(self, optional); end")
    end

    def self.has_many_through(association, through_association)
      self.has_many(through_association[:via])
      self.class_eval("def #{association}(optional=nil); #{create_class_name(association)}.has_many_through_query(self, #{create_class_name(through_association[:via])}.new({}).class.name, optional); end")
    end

    def self.has_one(association)
      self.class_eval("def #{association}(optional=nil); #{create_class_name(association)}.has_one_query(self, optional); end")
    end

    def self.has_many_query(owner_object, optional=nil)
      endpoint_url = associations_url_builder(owner_object, self.name, {optional: optional })
      graph_data = get_graph_data(endpoint_url)
      self.object_array_maker(graph_data)
    end

    def self.has_one_query(owner_object, optional=nil)
      endpoint_url = associations_url_builder(owner_object, self.name, {optional: optional, single: true })
      graph_data = get_graph_data(endpoint_url)
      self.object_single_maker(graph_data)
    end

    def self.has_many_through_query(owner_object, through_class, optional=nil)
      endpoint_url = associations_url_builder(owner_object, self.name, {optional: optional })
      graph_data = get_graph_data(endpoint_url)
      separated_graphs = split_by_subject(graph_data, self.name)
      associated_objects_array = self.object_array_maker(separated_graphs[:associated_class_graph])
      through_property_plural = create_plural_property_name(through_class)
      self.through_getter_setter(through_property_plural)
      associated_objects_array.each do |associated_object|
        through_class_array = get_through_graphs(separated_graphs[:through_graph], associated_object.id).map do |graph|
          through_class.constantize.object_single_maker(graph)
        end
        associated_object.send((through_property_plural + '=').to_sym, through_class_array)
      end
    end

    def self.through_getter_setter(through_property_plural)
      self.class_eval("def #{through_property_plural}=(array); @#{through_property_plural} = array; end")
      self.class_eval("def #{through_property_plural}; @#{through_property_plural}; end")
    end

    def self.object_array_maker(graph_data)
      self.statements_mapper_by_subject(graph_data).map do |data|
        p data
        p '....'
        self.new(data)
      end
    end

    def self.object_single_maker(graph_data)
      p graph_data
      p '****'
      self.object_array_maker(graph_data).first
    end

    def extract_graph
      self.send(:remove_instance_variable, :@graph)
    end

    def self.extract_collective_graph(objects)
      collective_graph = RDF::Graph.new
      objects.each do |o|
        collective_graph << o.extract_graph
      end
      collective_graph
    end

  end
end