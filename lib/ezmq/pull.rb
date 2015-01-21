require_relative 'socket'

# Syntactic sugar for 0MQ, because Ruby shouldn't feel like C.
module EZMQ
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
