context 'Paired sockets' do
  setup do
    @bound, @connected = EZMQ.create_linked_pair
  end

  should 'initialize properly' do
    assert_kind_of EZMQ::Socket, @bound
    assert_kind_of EZMQ::Socket, @connected
  end

  should 'return the length of messages they send' do
    assert_equal 7, @connected.send('message')
  end

  should 'return the contents of messages they receive' do
    messages = ['message', {message: 'test'}]
    messages.each do |message|
      @connected.send message
      assert_equal message, @bound.receive
    end
  end

  should 'yield the contents of messages they receive, if given a block' do
    @bound.send 'message'
    assert_equal 'message', @connected.receive { |m| m }
  end

  should 'block if no message is present' do
    assert_raises Timeout::Error do
      Timeout.timeout(0.1) do
        @connected.receive
      end
    end
  end

  should 'receive multiple messages if listening' do
    3.times { @bound.send 'message' }
    messages = []
    begin
      Timeout.timeout(0.1) do
        @connected.listen do |message|
          messages << message
        end
      end
    rescue Timeout::Error
      assert_equal 3, messages.size
    end
  end
end

context 'Paired sockets with encoding/decoding' do
  setup do
    e = -> message { JSON.dump message }
    d = -> message { JSON.load message }
    @bound, @connected = EZMQ.create_linked_pair encoding: e, decoding: d
  end

  should 'return the length of messages they send' do
    assert_equal 7, @connected.send('message')
  end

  should 'return the contents of messages they receive' do
    @connected.send 'message'
    assert_equal 'message', @bound.receive
  end
end
