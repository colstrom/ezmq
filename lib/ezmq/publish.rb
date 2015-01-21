require_relative 'socket'

# Syntactic sugar for 0MQ, because Ruby shouldn't feel like C.
module EZMQ
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
end
