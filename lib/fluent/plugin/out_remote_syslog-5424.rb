require "fluent/mixin/config_placeholders"
require "fluent/mixin/plaintextformatter"
require 'fluent/mixin/rewrite_tag_name'

module Fluent
  class RemoteSyslogOutput < Fluent::Output
    Fluent::Plugin.register_output("remote_syslog-5424", self)

    config_param :hostname, :string, :default => ""

    include Fluent::Mixin::PlainTextFormatter
    include Fluent::Mixin::ConfigPlaceholders
    include Fluent::HandleTagNameMixin
    include Fluent::Mixin::RewriteTagName

    config_param :host, :string
    config_param :port, :integer, :default => 514

    config_param :facility, :string, :default => "user"
    config_param :severity, :string, :default => "notice"
    config_param :tag, :string, :default => "fluentd"

    config_param :protocol, :string, :default => "udp"
    config_param :parse_tag, :bool, :default => false
    config_param :output_include_time, :bool, :default => false
    config_param :output_include_tag, :bool, :default => false
    config_param :debug_output, :bool, :default => false

    def initialize
      super
      require "remote_syslog_sender"
      @loggers = {}
    end

    def shutdown
      super
      @loggers.values.each(&:close)
    end

    def emit(tag, es, chain)
      chain.next
      es.each do |time, record|
	host_name = @hostname
        record.each_pair do |k, v|
          if v.is_a?(String)
            v.force_encoding("utf-8")
          end
          if k=="hostname"
            host_name = v
	  end
        end
		
        record.tap{ |h| h.delete("hostname") }

        tag = rewrite_tag!(tag.dup)

        if @parse_tag
          parts = tag.split('.', 3)
          severity = parts[0]
          facility = parts[1]
          program  = parts[2]
        else
          facility = @facility
          severity = @severity
          program  = tag
        end

        @loggers[tag] ||= RemoteSyslogSender::Sender.new(@host, @port,
          protocol: @protocol,
          facility: facility,
          severity: severity,
          program: program,
          local_hostname: host_name,
          debug: @debug_output)

        @loggers[tag].transmit format(tag, time, record), Time.at(time)
      end
    end
  end
end
