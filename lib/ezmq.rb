require 'ffi-rzmq'

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

  # Request socket that sends messages and receives replies.
  class Client < EZMQ::Socket
    # Creates a new Client socket.
    #
    # @param [Hash] options optional parameters.
    # @see EZMQ::Socket EZMQ::Socket for optional parameters.
    #
    # @return [Client] a new instance of Client.
    #
    def initialize(**options)
      super :connect, ZMQ::REQ, options
    end

    # Sends a message and waits to receive a response.
    #
    # @param [String] message the message to send.
    # @param [Hash] options optional parameters.
    # @option options [lambda] encode how to encode the message.
    # @option options [lambda] decode how to decode the message.
    #
    # @return [void] the decoded response message.
    #
    def request(message = '', **options)
      send message, options
      if block_given?
        yield receive options
      else
        receive options
      end
    end
  end

  # Reply socket that listens for and replies to requests.
  class Server < EZMQ::Socket
    # Creates a new Server socket.
    #
    # @param [Hash] options optional parameters
    #
    # @see EZMQ::Socket EZMQ::Socket for optional parameters.
    #
    # @return [Server] a new instance of Server
    #
    def initialize(**options)
      super :bind, ZMQ::REP, options
    end

    # Listens for a request, and responds to it.
    #
    # If no block is given, responds with the request message.
    #
    # @yield message passes the message received to the block.
    # @yieldparam [String] message the message received.
    # @yieldreturn [void] the message to reply with.
    #
    # @return [void] the return from handler.
    #
    def listen
      loop do
        if block_given?
          send yield receive
        else
          send receive
        end
      end
    end
  end

  # Publish socket that broadcasts messages with an optional topic.
  class Publisher < EZMQ::Socket
    # Creates a new Publisher socket.
    #
    # @param [Hash] options optional parameters.
    # @see EZMQ::Socket EZMQ::Socket for optional parameters.
    #
    # @return [Publisher] a new instance of Publisher.
    #
    def initialize(**options)
      super :bind, ZMQ::PUB, options
    end

    # Sends a message on the socket, with an optional topic.
    #
    # @param [String] message the message to send.
    # @param [String] topic an optional topic for the message.
    # @param [Hash] options optional parameters.
    # @option options [lambda] encode how to encode the message.
    #
    # @return [Fixnum] the size of the message.
    #
    def send(message = '', topic: '', **options)
      @socket.send_string "#{ topic } #{ (options[:encode] || @encode).call message }"
    end
  end

  # Subscribe socket that listens for messages with an optional topic.
  class Subscriber < EZMQ::Socket
    attr_accessor :action

    # Creates a new Subscriber socket.
    #
    # @note The default behaviour is to output and messages received to STDOUT.
    #
    # @param [Hash] options optional parameters.
    # @option options [String] topic a topic to subscribe to.
    # @see EZMQ::Socket EZMQ::Socket for optional parameters.
    #
    # @return [Publisher] a new instance of Publisher.
    #
    def initialize(**options)
      super :connect, ZMQ::SUB, options
      subscribe options[:topic] if options[:topic]
    end

    # Establishes a new message filter on the socket.
    #
    # @note By default, a Subscriber filters all incoming messages. Without
    # calling subscribe at least once, no messages will be accepted. If topic
    # was provided, #initialize calls #subscribe automatically.
    #
    # @param [String] topic a topic to subscribe to. Messages matching this
    # prefix will be accepted.
    #
    # @return [Boolean] was subscription successful?
    #
    def subscribe(topic)
      @socket.setsockopt(ZMQ::SUBSCRIBE, topic) == 0
    end

    # Removes a message filter (as set with subscribe) from the socket.
    #
    # @param [String] topic the topic to unsubscribe from. If multiple filters
    #   with the same topic are set, this will only remove one.
    #
    # @return [Boolean] was unsubscription successful?
    #
    def unsubscribe(topic)
      @socket.setsockopt(ZMQ::UNSUBSCRIBE, topic) == 0
    end
  end

  # Push socket that sends messages but does not receive them.
  class Pusher < EZMQ::Socket
    # Creates a new Pusher socket.
    #
    # @param [:bind, :connect] mode a mode for the socket.
    # @param [Hash] options optional parameters.
    # @see EZMQ::Socket EZMQ::Socket for optional parameters.
    #
    # @return [Pusher] a new instance of Pusher.
    #
    def initialize(mode = :connect, **options)
      super mode, ZMQ::PUSH, options
    end
  end

  # Pull socket that receives messages but does not send them.
  class Puller < EZMQ::Socket
    # Creates a new Puller socket.
    #
    # @param [:bind, :connect] mode a mode for the socket.
    # @param [Hash] options optional parameters.
    # @see EZMQ::Socket EZMQ::Socket for optional parameters.
    #
    # @return [Puller] a new instance of Puller.
    #
    def initialize(mode = :bind, **options)
      super mode, ZMQ::PULL, options
    end
  end
end
