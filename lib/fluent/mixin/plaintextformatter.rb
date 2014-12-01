require 'fluent/config'
require 'ltsv'

module Fluent
  module Mixin
    module PlainTextFormatter
      attr_accessor :output_include_time, :output_include_tag, :output_data_type
      attr_accessor :add_newline, :field_separator
      attr_accessor :remove_prefix, :default_tag
      attr_accessor :null_value

      attr_accessor :suppress_log_broken_string

      attr_accessor :f_separator

      def first_value(*args)
        args.reduce{|a,b| (not a.nil?) ? a : b}
      end

      def configure(conf)
        super

        @output_include_time = first_value(
          conf.has_key?('output_include_time') ? Fluent::Config.bool_value(conf['output_include_time']) : nil,
          @output_include_time,
          true
        )
        @output_include_tag = first_value(
          conf.has_key?('output_include_tag') ? Fluent::Config.bool_value(conf['output_include_tag']) : nil,
          @output_include_tag,
          true
        )

        @output_data_type = first_value( conf['output_data_type'], @output_data_type, 'json' )

        @field_separator = first_value( conf['field_separator'], @field_separator, 'TAB' )
        @f_separator = case @field_separator
                       when /SPACE/i then ' '
                       when /COMMA/i then ','
                       when /SOH/i then "\x01"
                       when /PIPE/i then '|'
                       else "\t"
                       end

        @add_newline = first_value(
          conf.has_key?('add_newline') ? Fluent::Config.bool_value(conf['add_newline']) : nil,
          @add_newline,
          true
        )

        @remove_prefix = conf['remove_prefix']
        if @remove_prefix
          @removed_prefix_string = @remove_prefix + '.'
          @removed_length = @removed_prefix_string.length
        end
        if @output_include_tag and @remove_prefix and @remove_prefix.length > 0
          @default_tag = first_value( conf['default_tag'], @default_tag, nil )
          if @default_tag.nil? or @default_tag.length < 1
            raise Fluent::ConfigError, "Missing 'default_tag' with output_include_tag and remove_prefix."
          end
        end

        @null_value = first_value( conf['null_value'], @null_value, 'NULL' )

        # default timezone: utc
        if not conf.has_key?('localtime') and not conf.has_key?('utc')
          @localtime = false
        elsif conf.has_key?('localtime')
          @localtime = true
        elsif conf.has_key?('utc')
          @localtime = false
        end
        # mix-in default time formatter (or you can overwrite @timef on your own configure)
        @time_format = first_value( conf['time_format'], @time_format, nil )
        @timef = @output_include_time ? Fluent::TimeFormatter.new(@time_format, @localtime) : nil

        @custom_attributes = if @output_data_type == 'json'
                               nil
                             elsif @output_data_type == 'ltsv'
                               nil
                             elsif @output_data_type =~ /^attr:(.+)$/
                               $1.split(',').map(&:strip).reject(&:empty?)
                             else
                               raise Fluent::ConfigError, "invalid output_data_type:'#{@output_data_type}'"
                             end

        @suppress_log_broken_string = first_value(
          conf.has_key?('suppress_log_broken_string') ? Fluent::Config.bool_value(conf['suppress_log_broken_string']) : nil,
          @suppress_log_broken_string,
          false
        )
      end

      def stringify_record(record)
        if @custom_attributes.nil?
          case @output_data_type
          when 'json'
            record.to_json
          when 'ltsv'
            LTSV.dump(record)
          end
        else
          @custom_attributes.map{|attr|
            record[attr].nil? ? @null_value : record[attr].to_s
          }.join(@f_separator)
        end
      end

      def format(tag, time, record)
        if @remove_prefix
          if tag.start_with?(@removed_prefix_string) and tag.length > @removed_length
            tag = tag[@removed_length..-1]
          elsif tag == @remove_prefix
            tag = @default_tag
          end
        end
        time_str = if @output_include_time
                     @timef.format(time) + @f_separator
                   else
                     ''
                   end
        tag_str = if @output_include_tag
                    tag + @f_separator
                  else
                    ''
                  end
        begin
          time_str + tag_str + stringify_record(record) + (@add_newline ? "\n" : '')
        rescue JSON::GeneratorError => e
          # partial character in source, but hit end
          # source sequence is illegal/malformed utf-8
          unless @suppress_log_broken_string
            if self.respond_to?(:log)
              log.warn e.message + ", ignored", :error_class => e.class, :tag => tag, :record => record.inspect # quote explicitly
            else
              $log.warn e.message + ", ignored", :error_class => e.class, :tag => tag, :record => record.inspect # quote explicitly
            end
          end
          ''
        rescue ArgumentError => e
          raise unless e.message == 'invalid byte sequence in UTF-8'
          unless @suppress_log_broken_string
            if self.respond_to?(:log)
              log.warn e.message + ", ignored", :error_class => e.class, :tag => tag, :record => record.inspect # quote explicitly
            else
              $log.warn e.message + ", ignored", :error_class => e.class, :tag => tag, :record => record.inspect # quote explicitly
            end
          end
          ''
        end
      end
    end
  end
end
