require_relative 'socket'

# Syntactic sugar for 0MQ, because Ruby shouldn't feel like C.
module EZMQ
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
end
