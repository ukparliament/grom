require 'rdf'
require 'rdf/vocab'
require 'active_support/inflector'

require_relative 'grom/version'
require_relative 'grom/reader'
require_relative 'grom/node'
require_relative 'grom/helper'
require_relative 'grom/builder'
require_relative 'grom/labels'
require_relative 'grom/response'

require 'grom/naming_error'

# Namespace for graph object mapper that converts n-triple data to Ruby objects.
# @since 0.1.0
module Grom
end
