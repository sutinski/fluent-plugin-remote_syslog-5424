require "test_helper"
require "fluent/plugin/out_remote_syslog-5424"

class RemoteSyslogOutputTest < MiniTest::Test
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf = CONFIG, tag = "info.kern.tag")
    Fluent::Test::OutputTestDriver.new(Fluent::RemoteSyslogOutput, tag) {}.configure(conf)
  end

  def test_configure
    d = create_driver %[
      type remote_syslog-5424
      hostname foo.com
      host example.com
      port 5566
      protocol tcp
      severity err
      tag minitest
      # debug_output true
    ]

    d.run do
      d.emit(message: "foo")
    end

    loggers = d.instance.instance_variable_get(:@loggers)
    refute_empty loggers

    logger = loggers.values.first

    assert_equal "example.com", logger.instance_variable_get(:@remote_hostname)
    assert_equal 5566, logger.instance_variable_get(:@remote_port)

    p = logger.instance_variable_get(:@packet)
    assert_equal "foo.com", p.hostname
    assert_equal 1, p.facility
    assert_equal "minitest", p.tag
    assert_equal 3, p.severity
  end

  def test_rewrite_tag
    d = create_driver %[
      type remote_syslog-5424
      hostname foo.com
      host example.com
      port 5566
      severity info
      # debug_output true
      tag rewrited.${tag_parts[1]}
    ]

    d.run do
      d.emit(message: "bar")
    end

    loggers = d.instance.instance_variable_get(:@loggers)
    logger = loggers.values.first

    p = logger.instance_variable_get(:@packet)
    assert_equal "rewrited.kern", p.tag
  end

  def test_long_tag
    d = create_driver %[
      type remote_syslog-5424
      hostname foo.com
      host example.com
      port 5566
      severity info
      # debug_output true
      tag 012345678901234567890123456789012345678901234567890123456789
    ]

    d.run do
      d.emit(message: "test_long_tag")
    end

    loggers = d.instance.instance_variable_get(:@loggers)
    logger = loggers.values.first

    p = logger.instance_variable_get(:@packet)
    assert_equal "012345678901234567890123456789012345678901234567", p.tag
  end

  def test_parse_tag
    d = create_driver %[
      type remote_syslog-5424
      hostname foo.com
      host example.com
      port 5566
      # debug_output true
      parse_tag true
      tag ${tag}
    ]

    d.run do
      d.emit(message: "test_parse_tag")
    end

    loggers = d.instance.instance_variable_get(:@loggers)
    logger = loggers.values.first

    p = logger.instance_variable_get(:@packet)
    assert_equal 6, p.severity
    assert_equal 0, p.facility
    assert_equal "tag", p.tag
  end

end
