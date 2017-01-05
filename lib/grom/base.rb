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
      ttl_data = get_ttl_data(endpoint_url)
      self.object_single_maker(ttl_data)
    end

    def self.all(*options)
      endpoint_url = "#{all_base_url_builder(self.name, *options)}.ttl"
      ttl_data = get_ttl_data(endpoint_url)

      self.object_array_maker(ttl_data)
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
      endpoint_url = associations_url_builder(owner_object, self.name, {optional: options})
      ttl_data = get_ttl_data(endpoint_url)
      self.object_array_maker(ttl_data)
    end

    def self.has_one_query(owner_object, *options)
      endpoint_url = associations_url_builder(owner_object, self.name, {optional: options, single: true})
      ttl_data = get_ttl_data(endpoint_url)
      self.object_single_maker(ttl_data)
    end

    def self.property_getter_setter(property_name)
      self.class_eval("def #{property_name}=(value); @#{property_name} = value; end")
      self.class_eval("def #{property_name}; @#{property_name}; end")
    end

    def self.object_array_maker(ttl_data)
      create_hash_from_ttl(ttl_data).map do |hash|
        self.new(hash)
      end
    end

    def self.object_single_maker(ttl_data)
      self.object_array_maker(ttl_data).first
    end

    def self.object_with_array_maker(associated_hashes, owner_object_hashes)
      owner_object_array = []
      owner_object_hashes.each do |owner_hash|
        object = self.new(owner_hash)
        associated_hashes.select { |h| h[:connect].include?(object.id) }.each do |associated_hash|
          associated_object_name = get_id(associated_hash[:type])
          object.send((create_property_name(associated_object_name) + '=').to_sym, associated_object_name.constantize.new(associated_hash))
        end
        owner_object_array << object
      end
      owner_object_array
    end

    def self.has_many_through_query(owner_object, through_class, *options)
      through_property_plural = create_plural_property_name(through_class)
      endpoint_url = associations_url_builder(owner_object, self.name, {optional: options})
      self.property_getter_setter(through_property_plural)
      ttl_data = get_ttl_data(endpoint_url)
      self.map_hashes_to_objects(through_split_graph(ttl_data), through_property_plural)
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

    def self.eager_all(*options)
      endpoint_url = "#{all_base_url_builder(self.name, *options)}.ttl"
      ttl_data = get_ttl_data(endpoint_url)
      all_hashes = eager_all_statements_mapper(ttl_data)

      owner_object_hashes, associated_hashes = all_hashes.partition do |h|
        get_id(h[:type]) == self.name.to_s
      end

      types_array = associated_hashes.map { |h| create_property_name(get_id(h[:type])) }.uniq
      types_array.each do |property|
        self.property_getter_setter(property)
      end

      object_with_array_maker(associated_hashes, owner_object_hashes)
    end

    def self.eager_find(id)
      endpoint_url = "#{find_base_url_builder(self.name, id)}.ttl"
      ttl_data = get_ttl_data(endpoint_url)
      hash, through_hashes = eager_find_statements_mapper(ttl_data)
      all_hashes = hash.values
      owner_object_hash, associated_hashes = all_hashes.partition do |h|
        get_id(h[:type]) == self.name.to_s
      end

      owner_object = self.new(owner_object_hash.first)

      array_property_setter(associated_hashes, owner_object)
      array_property_setter(through_hashes.values, owner_object)

      associated_hashes.each do |hash|
        associated_object_name = get_id(hash[:type])
        owner_object.send(create_plural_property_name(associated_object_name.to_sym)) << associated_object_name.constantize.new(hash)
      end

      through_hashes.values.each do |hash|
        through_object_name = get_id(hash[:type])
        through_object = through_object_name.constantize.new(hash)
        owner_object.send(create_plural_property_name(through_object_name.to_sym)) << through_object
        associated_hashes.select { |h| hash[:connect].include?(h[:id]) }.each do |associated_hash|
          through_object.class.property_getter_setter(create_property_name(get_id(associated_hash[:type])))
          associated_object = get_id(associated_hash[:type]).constantize.new(associated_hash)
          through_object.send((create_property_name(get_id(associated_hash[:type])) + '=').to_sym, associated_object)
        end
      end
      owner_object
    end

    def self.array_property_setter(hashes, owner_object)
      hashes.map { |h| create_plural_property_name(get_id(h[:type])) }.uniq.each do |property|
        owner_object.class.property_getter_setter(property)
        owner_object.send((property + "=").to_sym, [])
      end
    end

  end
end