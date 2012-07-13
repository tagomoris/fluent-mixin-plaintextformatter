require 'fluent/load'
require 'fluent/mixin/plaintextformatter'

module Fluent
  class TestAOutput < Fluent::BufferedOutput
    config_set_default :buffer_type, 'memory'

    include Fluent::Mixin::PlainTextFormatter

    config_set_default :output_include_time, true
    config_set_default :output_include_tag, true
    config_set_default :output_data_type, 'json'
    config_set_default :field_separator, "\t"
    config_set_default :add_newline, true
    config_set_default :remove_prefix, nil
    config_set_default :default_tag, 'test.a'

    def configure(conf)
      super
    end
  end
end
