require_relative '../lib/grom/graph_mapper'
require_relative '../lib/grom/base'
require_relative '../lib/grom/helpers'

module Grom
  VERSION = '0.1.0'

    def self.root
      File.dirname __dir__
    end
end
