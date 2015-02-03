context 'Servers' do
  setup do
    @context = EZMQ::Context.new
    options = { transport: :inproc, address: 'test', context: @context }
    @server = EZMQ::Server.new options
    @client = EZMQ::Client.new options
    Thread.new do
      @client.request 'message'
    end
  end

  should 'yield the contents of a request, if given a block' do
    assert_nothing_raised do
      Timeout.timeout(0.1) do
        @server.listen do |request|
          assert_equal request, 'message'
          break
        end
      end
    end
  end

  should 'return the length of messages they send' do
    @server.receive
    assert_equal 7, @server.send('message')
  end

  should 'return the contents of a request they receive' do
    assert_equal 'message', @server.receive
  end

  should 'yield the contents of reply, if given a block' do
    assert_equal 'message', @server.receive { |m| m }
  end
end
