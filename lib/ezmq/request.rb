require_relative 'socket'

# Syntactic sugar for 0MQ, because Ruby shouldn't feel like C.
module EZMQ
  # Request socket that sends messages and receives replies.
  class Client < EZMQ::Socket
    # Creates a new Client socket.
    #
    # @param [:bind, :connect] mode (:connect) a mode for the socket.
    # @param [Hash] options optional parameters.
    # @see EZMQ::Socket EZMQ::Socket for optional parameters.
    #
    # @return [Client] a new instance of Client.
    #
    def initialize(mode = :connect, **options)
      super mode, ZMQ::REQ, options
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
    def request(message, **options)
      send message, options
      if block_given?
        yield receive options
      else
        receive options
      end
    end
  end
end
