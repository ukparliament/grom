require_relative '../lib/grom/graph_mapper'
require_relative '../lib/grom/base'
require_relative '../lib/grom/helpers'
require 'active_support/core_ext/string/inflections'

module Grom
  VERSION = '0.1.1'

    def self.root
      File.dirname __dir__
    end
end
