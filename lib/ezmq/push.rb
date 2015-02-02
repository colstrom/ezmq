require_relative 'socket'

# Syntactic sugar for 0MQ, because Ruby shouldn't feel like C.
module EZMQ
  # Push socket that sends messages but does not receive them. It can connect to
  #   multiple Pull sockets, and will load-balance requests to available
  #   destinations.
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
end
