context 'Pullers' do
  setup do
    @context = EZMQ::Context.new
    options = { transport: :inproc, address: 'test', context: @context }
    @pusher = EZMQ::Pusher.new options
    @puller = EZMQ::Puller.new options
    Thread.new do
      @pusher.send 'message'
    end
  end

  should 'return the contents of messages they receive' do
    assert_equal 'message', @puller.receive
  end
end
