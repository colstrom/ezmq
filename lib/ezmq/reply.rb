require_relative 'socket'

# Syntactic sugar for 0MQ, because Ruby shouldn't feel like C.
module EZMQ
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
end
