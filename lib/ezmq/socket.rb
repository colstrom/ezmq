# Syntactic sugar for 0MQ, because Ruby shouldn't feel like C.
module EZMQ
  # Wrapper class to simplify 0MQ sockets.
  class Socket
    attr_accessor :context, :socket, :encode, :decode

    # Creates a 0MQ socket.
    #
    # @param [:bind, :connect] mode the mode of the socket.
    # @param [Object] type the type of socket to use.
    # @param [Hash] options optional parameters.
    #
    # @option options [ZMQ::Context] context a context to use for this socket
    #   (one will be created if not provided).
    # @option options [lambda] encode how to encode messages.
    # @option options [lambda] decode how to decode messages.
    # @option options [String] protocol ('tcp') protocol for transport.
    # @option options [String] address ('127.0.0.1') address for endpoint.
    # @option options [Fixnum] port (5555) port for endpoint.
    # @note port is ignored unless protocol is either 'tcp' or 'udp'.
    #
    # @return [Socket] a new instance of Socket.
    #
    def initialize(mode, type, **options)
      fail ArgumentError unless [:bind, :connect].include? mode
      @context = options[:context] || ZMQ::Context.new
      @socket = @context.socket type
      @encode = options[:encode] || -> m { m }
      @decode = options[:decode] || -> m { m }
      endpoint = options.select { |k, _| [:protocol, :address, :port].include? k }
      method(mode).call endpoint
    end

    # Sends a message to the socket.
    #
    # @note If message is not a String, #encode must convert it to one.
    #
    # @param [String] message the message to send.
    # @param [Hash] options optional parameters.
    # @option options [lambda] encode how to encode the message.
    #
    # @return [Fixnum] the size of the message.
    #
    def send(message = '', **options)
      encoded = (options[:encode] || @encode).call message
      @socket.send_string encoded
    end

    # Receive a message from the socket.
    #
    # @note This method blocks until a message arrives.
    #
    # @param [Hash] options optional parameters.
    # @option options [lambda] decode how to decode the message.
    #
    # @yield message passes the message received to the block.
    # @yieldparam [Object] message the message received (decoded).
    #
    # @return [Object] the message received (decoded).
    #
    def receive(**options)
      message = ''
      @socket.recv_string message
      decoded = (options[:decode] || @decode).call message
      if block_given?
        yield decoded
      else
        decoded
      end
    end

    # Binds the socket to the given address.
    #
    # @param [String] protocol ('tcp') protocol for transport.
    # @param [String] address ('127.0.0.1') address for endpoint.
    # @note An address of 'localhost' is not reliable on all platforms.
    #   Prefer '127.0.0.1' instead.
    # @param [Fixnum] port (5555) port for endpoint.
    # @note port is ignored unless protocol is either 'tcp' or 'udp'.
    #
    # @return [Boolean] was binding successful?
    #
    def bind(protocol: 'tcp', address: '127.0.0.1', port: 5555)
      endpoint = "#{ protocol }://#{ address }"
      endpoint = "#{ endpoint }:#{ port }" if %w(tcp udp).include? protocol
      @socket.bind(endpoint) == 0
    end

    # Connects the socket to the given address.
    #
    # @param [String] protocol ('tcp') protocol for transport.
    # @param [String] address ('127.0.0.1') address for endpoint.
    # @param [Fixnum] port (5555) port for endpoint.
    # @note port is ignored unless protocol is either 'tcp' or 'udp'.
    #
    # @return [Boolean] was connection successful?
    #
    def connect(protocol: 'tcp', address: '127.0.0.1', port: 5555)
      endpoint = "#{ protocol }://#{ address }"
      endpoint = "#{ endpoint }:#{ port }" if %w(tcp udp).include? protocol
      @socket.connect(endpoint) == 0
    end

    # By default, waits for a message and prints it to STDOUT.
    #
    # @yield message passes the message received to the block.
    # @yieldparam [String] message the message received.
    #
    # @return [void]
    #
    def listen
      loop do
        if block_given?
          yield receive
        else
          puts receive
        end
      end
    end
  end
end
