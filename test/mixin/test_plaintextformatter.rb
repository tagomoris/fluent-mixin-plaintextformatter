require 'helper'

class PlainTextFormatterTest < Test::Unit::TestCase
  def create_plugin_instance(type, conf = CONFIG, tag='test')
    Fluent::Test::BufferedOutputTestDriver.new(type, tag).configure(conf).instance
  end

  def test_first_value
    p = create_plugin_instance(Fluent::TestAOutput, "type testa\n")
    assert_equal nil, p.first_value()
    assert_equal nil, p.first_value(nil, nil)
    assert_equal 'hoge', p.first_value(nil, nil, 'hoge')
    assert_equal 'bar', p.first_value(nil, 'bar', 'hoge')
    assert_equal 'foo', p.first_value('foo', 'bar', 'hoge')
    assert_equal 'foo', p.first_value('foo', nil, 'hoge')
    assert_equal 'foo', p.first_value('foo', 'bar', nil)
    assert_equal 'foo', p.first_value('foo', nil, nil)
  end

  def test_default_with_time_tag
    p = create_plugin_instance(Fluent::TestAOutput, "type testa\n")
    r = {'foo' => 'foo foo baz', 'bar' => 10000}
    # stringify
    assert_equal r, JSON.parse(p.stringify_record(r))

    line = p.format('test.a', 1342163105, r)
    # add_newline true
    assert_equal line[0..-2], line.chomp
    # output_include_time true, output_include_tag true
    assert_equal ['2012-07-13T07:05:05Z', 'test.a'], line.chomp.split(/\t/)[0..1]
    # output_data_type json
    assert_equal r, JSON.parse(line.chomp.split(/\t/)[2])
  end

  def test_field_separator_newline_json
    p = create_plugin_instance(Fluent::TestBOutput, "type testb\nlocaltime\n")
    r = {'foo' => 'foo foo baz', 'bar' => 10000}
    # stringify
    assert_equal r, JSON.parse(p.stringify_record(r))

    line = p.format('test.b', 1342163105, r)
    # add_newline false
    assert_equal line[0..-1], line.chomp
    # output_include_time true, output_include_tag true, localtime, separator COMMA
    assert_equal ['2012-07-13T16:05:05+09:00', 'test.b'], line.chomp.split(/,/, 3)[0..1]
    # output_data_type json
    assert_equal r, JSON.parse(line.chomp.split(/,/, 3)[2])
  end

  def test_time_format
    p = create_plugin_instance(Fluent::TestBOutput, %[
type testb
localtime
time_format %Y/%m/%d %H:%M:%S
])
    r = {'foo' => 'foo foo baz', 'bar' => 10000}
    # stringify
    assert_equal r, JSON.parse(p.stringify_record(r))

    line = p.format('test.b', 1342163105, r)
    # add_newline false
    assert_equal line[0..-1], line.chomp
    # output_include_time true, output_include_tag true, localtime, separator COMMA
    assert_equal ['2012/07/13 16:05:05', 'test.b'], line.chomp.split(/,/, 3)[0..1]
    # output_data_type json
    assert_equal r, JSON.parse(line.chomp.split(/,/, 3)[2])
  end
  def test_separator_space_remove_prefix
    p = create_plugin_instance(Fluent::TestBOutput, %[
type testb
localtime
time_format %Y/%m/%d:%H:%M:%S
field_separator space
remove_prefix test
])
    r = {'foo' => 'foo foo baz', 'bar' => 10000}
    # stringify
    assert_equal r, JSON.parse(p.stringify_record(r))

    line = p.format('test.b', 1342163105, r)
    # add_newline false
    assert_equal line[0..-1], line.chomp
    # output_include_time true, output_include_tag true, localtime, separator COMMA
    assert_equal ['2012/07/13:16:05:05', 'b'], line.chomp.split(/ /, 3)[0..1]
    # output_data_type json
    assert_equal r, JSON.parse(line.chomp.split(/ /, 3)[2])
  end
  def test_separator_soh_remove_prefix
    p = create_plugin_instance(Fluent::TestBOutput, %[
type testb
localtime
time_format %Y/%m/%d:%H:%M:%S
field_separator soh
remove_prefix test
])
    r = {'foo' => 'foo foo baz', 'bar' => 10000}
    # stringify
    assert_equal r, JSON.parse(p.stringify_record(r))

    line = p.format('test.b', 1342163105, r)
    # add_newline false
    assert_equal line[0..-1], line.chomp
    # output_include_time true, output_include_tag true, localtime, separator SOH
    assert_equal ['2012/07/13:16:05:05', 'b'], line.chomp.split(/\001/, 3)[0..1]
    # output_data_type json
    assert_equal r, JSON.parse(line.chomp.split(/\001/, 3)[2])
  end
  
  def test_default_without_time_tag
    p = create_plugin_instance(Fluent::TestCOutput, "type testc\n")
    r = {'foo' => 'foo foo baz', 'bar' => 10000}
    # stringify
    assert_equal r, JSON.parse(p.stringify_record(r))

    line = p.format('test.c', 1342163105, r)
    # add_newline
    assert_equal line[0..-2], line.chomp
    # output_include_time false, output_include_tag false
    assert_equal 1, line.chomp.split(/\t/).size
    # output_data_type json
    assert_equal r, JSON.parse(line.chomp.split(/\t/).first)
  end

  def test_format_single_attribute
    p = create_plugin_instance(Fluent::TestAOutput, %[
type testa
output_include_time true
output_include_tag true
output_data_type attr:foo
])
    r = {'foo' => 'foo foo baz', 'bar' => 10000}
    # stringify
    assert_equal 'foo foo baz', p.stringify_record(r)
    # format
    assert_equal "2012-07-13T07:05:05Z\ttest.a\tfoo foo baz\n", p.format('test.a', 1342163105, r)

    p = create_plugin_instance(Fluent::TestAOutput, %[
type testa
output_include_time false
output_include_tag false
output_data_type attr:bar
])
    r = {'foo' => 'foo foo baz', 'bar' => 10000}
    # stringify
    assert_equal '10000', p.stringify_record(r)
    # format
    assert_equal "10000\n", p.format('test.a', 1342163105, r)
  end

  def test_format_multi_attribute
    p = create_plugin_instance(Fluent::TestAOutput, %[
type testa
output_include_time true
output_include_tag true
output_data_type attr:foo,bar
])
    r = {'foo' => 'foo foo baz', 'bar' => 10000}
    # stringify
    assert_equal "foo foo baz\t10000", p.stringify_record(r)
    # format
    assert_equal "2012-07-13T07:05:05Z\ttest.a\tfoo foo baz\t10000\n", p.format('test.a', 1342163105, r)

    p = create_plugin_instance(Fluent::TestAOutput, %[
type testa
output_include_time false
output_include_tag false
output_data_type attr:bar,foo
field_separator comma
])
    r = {'foo' => 'foo foo baz', 'bar' => 10000}
    # stringify
    assert_equal "10000,foo foo baz", p.stringify_record(r)
    # format
    assert_equal "10000,foo foo baz\n", p.format('test.a', 1342163105, r)
  end

  def test_field_separator_newline_ltsv
    p = create_plugin_instance(Fluent::TestDOutput, "type testd\nlocaltime\n")
    r = {'foo' => 'foo foo baz', 'bar' => 10000}
    rs = {:foo => 'foo foo baz', :bar => "10000"}
    # stringify
    assert_equal rs, LTSV.parse(p.stringify_record(r))

    line = p.format('test.d', 1342163105, r)
    # output_include_time true, output_include_tag true, localtime, separator COMMA
    assert_equal ['2012-07-13T16:05:05+09:00', 'test.d'], line.chomp.split(/\t/, 3)[0..1]
    # output_data_type json
    assert_equal rs, LTSV.parse(line.chomp.split(/\t/, 3)[2])
  end
end
