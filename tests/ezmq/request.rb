context 'Clients' do
  setup do
    @context = EZMQ::Context.new
    options = { transport: :inproc, address: 'test', context: @context }
    @server = EZMQ::Server.new options
    @client = EZMQ::Client.new options
    Thread.new do
      @server.listen
    end
  end

  should 'return the length of messages they send' do
    assert_equal 7, @client.send('message')
  end

  should 'return the contents of messages they receive' do
    @client.send 'message'
    assert_equal 'message', @client.receive
  end

  should 'return the reply from a request they send' do
    assert_equal 'message', @client.request('message')
  end

  should 'yield the contents of reply, if given a block' do
    assert_equal 'message', @client.request('message') { |m| m }
  end

  should 'pass Hash messages to the encode method' do
    @client.encode = -> m { assert_equal({message: 'test'}, m) }
    @client.request message: 'test'
  end
end
