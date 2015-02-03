%i(inproc ipc tcp pgm epgm).each do |transport|
  %i(bind connect).each do |mode|
    context "Sockets with #{ transport } transport in #{ mode } mode" do
      setup do
        options = { transport: transport }
        opposing_mode = %i(bind connect).reject { |m| m == mode }.first
        @unimportant = EZMQ::Socket.new opposing_mode, ZMQ::PAIR, options
        @socket = EZMQ::Socket.new mode, ZMQ::PAIR, options
      end

      should 'instantiate properly' do
        assert_kind_of EZMQ::Socket, @socket
      end

      should 'expose their contexts' do
        assert_kind_of EZMQ::Context, @socket.context
      end

      should 'have a bind method' do
        assert @socket.respond_to? :bind
      end

      should 'have a connect method' do
        assert @socket.respond_to? :connect
      end

      should 'have a send method' do
        assert @socket.respond_to? :send
      end

      should 'have a receive method' do
        assert @socket.respond_to? :receive
      end

      should 'have an encode method' do
        assert @socket.respond_to? :encode
      end

      should 'have a decode method' do
        assert @socket.respond_to? :decode
      end
    end
  end
end
