# Fluent::Mixin::PlainTextFormatter

Fluent::Mixin::PlainTextFormatter is a mix-in module, that provides '#format' instance method and its configurations to Fluentd BufferedOutput Plugin and TimeSlicedOutput Plugin, to output plain text data (to file, REST storages, KVSs ...).

This module provides features to:

* format whole data as serialized JSON, single attribute or separated multi attributes
* include time as line header (formatted by time_format in UTC(default) or localtime), or not
* include tag as line header (remove_prefix available), or not
* change field separator (TAB(default), SPACE, COMMA, SOH(\\001) or PIPE)
* add new line as termination, or not

## Usage

To use this module in your fluentd plugin, include this module like below:

    class FooOutput < BufferedOutput
      Fluent::Plugin.register_output('foo', self)
      
      config_set_default :buffer_type, 'memory'
      
      include Fluent::Mixin::PlainTextFormatter
      
      config_param :foo_config_x, :string, :default => nil

      # and other your plugin's configuration parameters...

      def configure(conf)
        super
        
        # ....
      end
      
      def start
        # ...
      end
      
      def shutdown
        # ....
      end
      
      # def format(tag, time, record)
      #   # do not define 'format'
      # end
      
      def write(chunk)
        # ....
      end
    end

And you can overwrite default formatting configurations on your plugin (values below are default of mix-in):

    class FooOutput < BufferedOutput
      # ...
      
      config_set_default :output_include_time, true
      config_set_default :output_include_tag, true
      config_set_default :output_data_type, 'json'
      config_set_default :field_separator, 'TAB'
      config_set_default :add_newline, true
      config_set_default :time_format, nil   # nil means ISO8601 '2012-07-13T19:29:49+09:00'
      config_set_default :remove_prefix, nil
      config_set_default :default_tag, nil
      config_set_default :null_value, 'NULL'
      
      # ...
    end

Provided configurations are below:

* output\_include\_time [yes/no]
* output\_include\_tag [yes/no]
* output\_data\_type
  * 'json': output by JSON
  * 'ltsv': output by LTSV, see: http://ltsv.org/
  * 'attr:key1,key2,key3': values of 'key1' and 'key2' and ..., with separator specified by 'field_separator'
* field\_separator [TAB/SPACE/COMMA/SOH/PIPE]
* add_newline [yes/no]
* time_format
  * format string like '%Y-%m-%d %H:%M:%S' or you want
* remove_prefix
  * input tag 'test.foo' with 'remove_prefix test', output tag is 'foo'.
  * 'default\_tag' configuration is used when input tag is completely equal to 'remove\_prefix'
* null_value
  * output value if value is null(nil). default is 'NULL'.

## AUTHOR / CONTRIBUTORS

* AUTHOR
  * TAGOMORI Satoshi <tagomoris@gmail.com>
* CONTRIBUTORS
  * wolfg1969 https://github.com/wolfg1969
  * Shinya Okano <tokibito@gmail.com>

## LICENSE

* Copyright: Copyright (c) 2012- tagomoris
* License: Apache License, Version 2.0
