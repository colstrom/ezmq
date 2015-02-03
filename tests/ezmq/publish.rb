context 'Publishers' do
  setup do
    @context = EZMQ::Context.new
    options = { transport: :inproc, address: 'test', context: @context }
    @publisher = EZMQ::Publisher.new options
    @subscriber = EZMQ::Subscriber.new options
    Thread.new do
      socket.receive
    end
  end

  should 'return the length of messages they send (without a topic)' do
    assert_equal 8, @publisher.send('message')
  end

  should 'return the length of messages they send (with a topic)' do
    assert_equal 8, @publisher.send('message')
  end
end
