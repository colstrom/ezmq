context 'Pushers' do
  setup do
    @context = EZMQ::Context.new
    options = { transport: :inproc, address: 'test', context: @context }
    @pusher = EZMQ::Pusher.new options
    @puller = EZMQ::Puller.new options
  end

  should 'return the length of messages they send' do
    assert_equal 7, @pusher.send('message')
  end
end
