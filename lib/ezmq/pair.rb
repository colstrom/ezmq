require_relative 'context'
require_relative 'socket'

# Syntactic sugar for 0MQ, because Ruby shouldn't feel like C.
module EZMQ
  # Pair sockets are meant to operate in pairs, as the name implies. They are
  #   bi-directional, with a one-to-one relationship between endpoints. Either
  #   end can send or receive messages.
  class Pair < EZMQ::Socket
    # Creates a new Pair socket.
    #
    # @param [:bind, :connect] mode a mode for the socket.
    # @param [Hash] options optional parameters.
    # @see EZMQ::Socket EZMQ::Socket for optional parameters.
    #
    # @return [Pair] a new instance of Pair.
    #
    def initialize(mode, **options)
      fail ArgumentError unless %i(bind connect).include? mode
      super mode, ZMQ::PAIR, options
    end
  end

  # Returns a pair of EZMQ::Pair sockets connected to each other.
  # 
  # @param [Hash] options optional parameters.
  # @see EZMQ::Socket EZMQ::Socket for optional parameters.
  # 
  # @return [Array<EZMQ::Pair>]
  #
  def self.create_linked_pair(**options)
    options[:context] ||= EZMQ::Context.new
    options[:transport] ||= 'inproc'
    options[:address] ||= options[:context].context.address
    %i(bind connect).map do |mode|
      EZMQ::Pair.new mode, options
    end
  end
end
