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

    def self.all_with(*options, with)
      # first loop
      endpoint_url = "#{all_base_url_builder(self.name, *options)}.ttl"
      ttl_data = get_ttl_data(endpoint_url)
      hash = {}
      RDF::Turtle::Reader.new(ttl_data) do |reader|
        reader.each_statement do |statement|
          subject = get_id(statement.subject)
          hash[subject] ||= {:id => subject}
          predicate = get_id(statement.predicate)
          if(predicate == "connect")
            (hash[subject][predicate.to_sym] ||= []) << get_id(statement.object.to_s)
          else
            hash[subject][predicate.to_sym] = statement.object.to_s
          end
        end
      end
      all_hashes = hash.values
      # all_hashes = create_hash_from_ttl(ttl_data)

      with.each do |property|
        self.property_getter_setter(property)
      end

      # second loop
      owner_object_hashes, associated_hashes = all_hashes.partition do |h|
        get_id(h[:type]) == self.name.to_s
      end

      # third loop
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

      # fourth loop
      # owner_object_array.each do |object|
      #   associated_hashes.select { |h| h[:connect].include?(object.id) }.each do |associated_hash|
      #     associated_object_name = get_id(associated_hash[:type])
      #     object.send((create_property_name(associated_object_name) + '=').to_sym, associated_object_name.constantize.new(associated_hash))
      #   end
      # end

    end

    def self.find_with(id, with)
      endpoint_url = "#{find_base_url_builder(self.name, id)}.ttl"
      ttl_data = get_ttl_data(endpoint_url)
      hash = {}
      sub_sub_hash = {}
      RDF::Turtle::Reader.new(ttl_data) do |reader|
        reader.each_statement do |statement|
          if (statement.subject.to_s =~ URI::regexp) == 0
            subject = get_id(statement.subject)
            hash[subject] ||= {:id => subject}
            predicate = get_id(statement.predicate)
            hash[subject][predicate.to_sym] = statement.object.to_s
          else
            sub_sub_hash[subject] ||= {:id => subject}
            predicate = get_id(statement.predicate)
            if(predicate == "connect")
              (sub_sub_hash[subject][predicate.to_sym] ||= []) << get_id(statement.object.to_s)
            else
              sub_sub_hash[subject][predicate.to_sym] = statement.object.to_s
            end
          end
        end
      end
      all_hashes = hash.values
      owner_object_hashes, associated_hashes = all_hashes.partition do |h|
        get_id(h[:type]) == self.name.to_s
      end

      owner_object = self.new(owner_object_hashes.first)

      with.each do |k|
        associated_type = k.keys.first
        self.property_getter_setter(create_plural_property_name(associated_type))
        associated_array = []
        associated_type_class = create_class_name(associated_type)
        associated_hashes.select { |h| get_id(h[:type]) == associated_type_class }.each do |associated_hash|
          associated_array << associated_type_class.constantize.new(associated_hash)
        end
        owner_object.send((create_property_name(create_plural_property_name(associated_type)) + '=').to_sym, associated_array)
        associated_sub_type = k.values.first
        owner_object.send(create_property_name(create_plural_property_name(associated_type))).each do |associated_object|
          associated_object.class.property_getter_setter(create_plural_property_name(associated_sub_type))
          sub_sub_array = []
          associated_sub_type_class = create_class_name(associated_sub_type)
          sub_sub_hash.values.select { |h| h[:connect].include?(associated_object.id) }.each do |h|
            sub_sub_array << associated_sub_type_class.constantize.new(h)
          end
          associated_object.send((create_plural_property_name(associated_sub_type) + '=').to_sym, sub_sub_array)
        end
      end
      owner_object
    end

  end
end