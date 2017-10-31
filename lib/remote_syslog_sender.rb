require 'socket'
require 'syslog_protocol-5424'

module RemoteSyslogSender
  VERSION = '0.1.0'

  class Sender
    def initialize(remote_hostname, remote_port, options = {})
      @remote_hostname = remote_hostname
      @remote_port     = remote_port
      @whinyerrors     = options[:whinyerrors]
      @protocol        = options[:protocol] || 'udp'
      
      if @protocol == 'tcp'
        begin
          @socket = TCPSocket.new(@remote_hostname, @remote_port)
        rescue
          $stderr.puts "#{self.class} error: #{$!.class}: #{$!}\nSyslog forwarding disabled!"
          @socket = open('/dev/null', 'w')
        end
      else
        @socket = UDPSocket.new
      end

      @packet = SyslogProtocol5424::Packet.new

      local_hostname   = options[:local_hostname] || (Socket.gethostname rescue `hostname`.chomp)
      local_hostname   = 'localhost' if local_hostname.nil? || local_hostname.empty?
      @packet.hostname = local_hostname

      @packet.facility = options[:facility] || 'user'
      @packet.severity = options[:severity] || 'notice'
      @packet.tag      = options[:program]  || "#{File.basename($0)}[#{$$}]"
      @debug           = options[:debug]    || false
    end
    
    def transmit(message, time)
      message.split(/\r?\n/).each do |line|
        begin
          next if line =~ /^\s*$/
          packet = @packet.dup
          packet.content = line
          packet.time = time
          data = packet.assemble(65500)  # max_size for UDP
          puts(data) if @debug
          if @protocol == 'tcp'
            retry_cnt = 0
            begin
              if retry_cnt < 3           # retry 3 times
                @socket.puts(data)
              end
            rescue                       # try to reopen socket
              @socket = TCPSocket.new(@remote_hostname, @remote_port)
              retry_cnt += 1
              retry
            end
          else
            @socket.send(data, 0, @remote_hostname, @remote_port)
          end
        rescue
          $stderr.puts "#{self.class} error: #{$!.class}: #{$!}\nOriginal message: #{line}"
          raise if @whinyerrors
        end
      end
    end
    
    # Make this act a little bit like an `IO` object
    alias_method :write, :transmit
    
    def close
      @socket.close
    end
  end

end