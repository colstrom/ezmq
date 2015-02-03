require 'ffi-rzmq'

# Syntactic sugar for 0MQ, because Ruby shouldn't feel like C.
module EZMQ
  # Wrapper class to simplify 0MQ sockets.
  class Context < ZMQ::Context
    # Creates a 0MQ context.
    #
    # Contexts are essentially resource containers or sandboxes for 0MQ. They
    #   allow multiple sockets to share access to system resources, and an
    #   entire context can be terminated, closing all sockets within it.
    #
    # Contexts are useful when dealing with the 'inproc' transport.
    #   Any sockets that need to communicate in-process must share a context.
    #
    # @return [Context] a new instance of Context.
    #
    def initialize
      super
    end
  end
end
