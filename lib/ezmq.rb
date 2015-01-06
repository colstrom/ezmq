require 'ffi-rzmq'

# Syntactic sugar for 0MQ, because Ruby shouldn't feel like C.
module EZMQ
  # Wrapper class to simplify 0MQ sockets.
  class Socket
    attr_accessor :context, :socket, :encode, :decode

    # Creates a 0MQ socket.
    #
    # @param [Symbol] mode the mode of the socket. `:bind` or `:connect`
    # @param [Object] type the type of socket to use.
    # @param [Hash] options optional parameters.
    #
    # @option options [ZMQ::Context] context a context to use for this socket
    #   (one will be created if not provided).
    # @option options [lambda] encode how to encode messages. Default unaltered.
    # @option options [lambda] decode how to decode messages. Default unaltered.
    # @option options [String] address specifies protocol, address and port (if
    #   needed). Default is 'tcp://127.0.0.1:5555'
    #
    # @return [Socket] a new instance of Socket.
    #
    def initialize(mode, type, **options)
      fail ArgumentError unless [:bind, :connect].include? mode
      @context = options[:context] || ZMQ::Context.new
      @socket = @context.socket type
      @encode = options[:encode] || -> m { m }
      @decode = options[:decode] || -> m { m }
      method(mode).call address: options[:address] || 'tcp://127.0.0.1:5555'
    end

    # Receive a message from the socket.
    #
    # @note This method blocks until a message arrives.
    #
    # @param [lambda] decode how to decode the message.
    #
    # @return [void] the decoded message.
    #
    def receive(decode: @decode)
      message = ''
      @socket.recv_string message
      decode.call message
    end

    # Sends a message on the socket.
    #
    # @note If `message` is not a String, `encode` must convert it to one.
    #
    # @param [String] message the message to send.
    # @param [lambda] encode how to encode the message.
    #
    # @return [Fixnum] the size of the message.
    #
    def send(message = '', encode: @encode)
      @socket.send_string encode.call message
    end

    # Binds the socket to the given address.
    #
    # @note 'localhost' does not always work as expected. Prefer '127.0.0.1'
    #
    # @param [String] address specifies protocol, address and port (if needed).
    #   Default is 'tcp://127.0.0.1:5555'
    #
    # @return [Boolean] was binding successful?
    #
    def bind(address: 'tcp://127.0.0.1:5555')
      @socket.bind(address) == 0 ? true : false
    end

    # Connects the socket to the given address.
    #
    # @param [String] address specifies protocol, address and port (if needed).
    #   Default is 'tcp://127.0.0.1:5555'
    #
    # @return [Boolean] was connection successful?
    #
    def connect(address: 'tcp://127.0.0.1:5555')
      @socket.connect(address) == 0 ? true : false
    end
  end

  # Reply socket that listens for and replies to requests.
  class Server < EZMQ::Socket
    attr_accessor :provides

    # Creates a new Server socket.
    #
    # @param [lambda] provides the service provided by this server.
    # @param [Hash] options optional parameters
    #
    # @see EZMQ::Socket EZMQ::Socket for a list of optional parameters.
    #
    # @return [Server] a new instance of Server
    #
    def initialize(provides: -> m { m }, **options)
      @provides = provides
      super :bind, ZMQ::REP, options
    end

    # By default, waits to receive a message, calls @action with it, replies
    # with the result, then loops.
    #
    # @param [lambda] handler how requests are handled.
    #
    # @return [void] the return from handler.
    #
    def listen(handler: -> { send @provides.call(receive) })
      loop { handler.call }
    end
  end

  # Request socket that sends messages and receives replies.
  class Client < EZMQ::Socket
    # Creates a new Client socket.
    #
    # @param [Hash] options optional parameters
    #
    # @see EZMQ::Socket EZMQ::Socket for a list of optional parameters.
    #
    # @return [Client] a new instance of Client.
    #
    def initialize(**options)
      super :connect, ZMQ::REQ, options
    end

    # Sends a message and waits to receive a response.
    #
    # @param [String] message the message to send.
    # @param [lambda] encode how to encode the message.
    # @param [lambda] decode how to decode the message.
    #
    # @return [void] the decoded response message.
    #
    def request(message = '', encode: @encode, decode: @decode)
      send message, encode: encode
      receive decode: decode
    end
  end

  # Publish socket that broadcasts messages with an optional topic.
  class Publisher < EZMQ::Socket
    # Creates a new Publisher socket.
    #
    # @param [Hash] options optional parameters
    #
    # @see EZMQ::Socket EZMQ::Socket for a list of optional parameters.
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
    # @param [lambda] encode how to encode the message.
    #
    # @return [Fixnum] the size of the message.
    #
    def send(message = '', topic: '', encode: @encode)
      @socket.send_string "#{ topic } #{ encode.call message }"
    end
  end

  # Subscribe socket that listens for messages with an optional topic.
  class Subscriber < EZMQ::Socket
    attr_accessor :action

    # Creates a new Subscriber socket.
    # 
    # @note The default behaviour is to output and messages received to STDOUT.
    #
    # @param [lambda] action the action to perform when a message is received.
    # @param [Hash] options optional parameters
    #
    # @option options [String] topic a topic to subscribe to.
    #
    # @see EZMQ::Socket EZMQ::Socket for a list of optional parameters.
    #
    # @return [Publisher] a new instance of Publisher.
    #
    def initialize(action: -> m { puts m }, **options)
      @action = action
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
      @socket.setsockopt(ZMQ::SUBSCRIBE, topic) == 0 ? true : false
    end

    # Removes a message filter (as set with subscribe) from the socket.
    #
    # @param [String] topic the topic to unsubscribe from. If multiple filters
    #   with the same topic are set, this will only remove one.
    #
    # @return [Boolean] was unsubscription successful?
    #
    def unsubscribe(topic)
      @socket.setsockopt(ZMQ::UNSUBSCRIBE, topic) == 0 ? true : false
    end

    # By default, waits for a message and calls @action with the message.
    #
    # @param [lambda] handler how requests are handled.
    #
    # @return [void] the return from handler.
    #
    def listen(handler: -> { @action.call(receive) })
      loop { handler.call }
    end
  end
end
