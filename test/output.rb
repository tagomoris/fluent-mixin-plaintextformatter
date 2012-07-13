require 'fluent/mixin/plaintextformatter'

module Fluent
  class TestAOutput < Fluent::BufferedOutput
    Fluent::Plugin.register_output('testa', self)

    config_set_default :buffer_type, 'memory'

    include Fluent::Mixin::PlainTextFormatter

    config_set_default :output_include_time, true
    config_set_default :output_include_tag, true
    config_set_default :output_data_type, 'json'
    config_set_default :field_separator, "\t"
    config_set_default :add_newline, true
    config_set_default :remove_prefix, nil
    config_set_default :default_tag, 'tag.blank'

    def configure(conf)
      super
    end
  end

  class TestBOutput < Fluent::BufferedOutput
    Fluent::Plugin.register_output('testa', self)

    config_set_default :buffer_type, 'memory'

    include Fluent::Mixin::PlainTextFormatter

    config_set_default :output_include_time, true
    config_set_default :output_include_tag, true
    config_set_default :output_data_type, 'json'
    config_set_default :field_separator, "COMMA"
    config_set_default :add_newline, false
    config_set_default :remove_prefix, nil
    config_set_default :default_tag, 'tag.blank'

    def configure(conf)
      super
    end
  end

  class TestCOutput < Fluent::BufferedOutput
    Fluent::Plugin.register_output('testc', self)

    config_set_default :buffer_type, 'memory'

    include Fluent::Mixin::PlainTextFormatter

    config_set_default :output_include_time, false
    config_set_default :output_include_tag, false
    config_set_default :output_data_type, 'json'
    config_set_default :field_separator, "\t"
    config_set_default :add_newline, true
    config_set_default :remove_prefix, nil
    config_set_default :default_tag, 'tag.blank'

    def configure(conf)
      super
    end
  end

end
