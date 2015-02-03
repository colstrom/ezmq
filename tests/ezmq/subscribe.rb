context 'Subscribers' do
  setup do
    @context = EZMQ::Context.new
    options = { transport: :inproc, address: 'test', context: @context }
    @publisher = EZMQ::Publisher.new options
    @subscriber = EZMQ::Subscriber.new options
    Thread.new do
      loop do
        @publisher.send 'message'
        @publisher.send 'message', topic: 'bad'
        @publisher.send 'message', topic: 'good'
      end
    end
  end

  should 'receive messages' do
    messages, topics = [], []
    @subscriber.subscribe ''
    1000.times do
      message, topic = @subscriber.receive
      messages << message
      topics << topic
    end
    assert_equal 1000, messages.select { |m| m == 'message' }.size
    assert topics.include? ''
    assert topics.include? 'bad'
    assert topics.include? 'good'
  end

  should 'subscribe to a topic' do
    assert @subscriber.subscribe 'good'
  end

  should 'unsubscribe from a topic' do
    assert @subscriber.subscribe 'bad'
    assert @subscriber.subscribe 'good'
    assert @subscriber.unsubscribe 'bad'
    topics = []
    1000.times do
      _, topic = @subscriber.receive
      topics << topic
    end
    assert_equal false, topics.include?('bad')
  end

  should 'yield the message body and topic, if given a block' do
    @subscriber.subscribe 'good'
    @subscriber.receive do |message, topic|
      assert_equal 'good', topic
      assert_equal 'message', message
      break
    end
  end

  should 'yield the message body and topic, if given a block and listening' do
    @subscriber.subscribe 'good'
    assert_nothing_raised do
      Timeout.timeout(0.1) do
        @subscriber.listen do |message, topic|
          assert_equal 'good', topic
          assert_equal 'message', message
          break
        end
      end
    end
  end

  should 'not receive messages with topics other than those subscribed to' do
    topics = []
    @subscriber.subscribe 'good'
    1000.times do
      _, topic = @subscriber.receive
      topics << topic
    end
    assert topics.include? 'good'
    assert_equal false, topics.include?('bad')
  end

  should 'return the contents of a message with a subscribed topic' do
    # assert
  end
end
