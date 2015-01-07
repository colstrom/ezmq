[EZMQ (Effortless ZeroMQ)](https://colstrom.github.io/ezmq/)
========================

Overview
--------

EZMQ is a wrapper around the wonderful `ffi-rzmq` gem, which (as the name suggests) uses FFI, and exposes a fairly raw C-like interface. As elegant as 0MQ is, C doesn't feel like Ruby, and FFI bindings feel like C. EZMQ makes some reasonable assumptions to help you focus on what makes your code special, and not worry about setting up 0MQ.

Any of the magical hand-wavey bits (contexts, sockets, etc) are still exposed for tinkering, EZMQ just starts you off with some sane defaults.

Examples
========

Most of these examples are trivial, because ZMQ is just the fabric of your networked application(s).

Echo Server
-----------
Waits for a request, replies with the same request.

```
require 'ezmq'

server = EZMQ::Server.new
server.listen
```

Synchronous Client Request
--------------------------
Sends a message, prints the reply when it arrives.

```
require 'ezmq'

client = EZMQ::Client.new
puts client.request 'test'
```

JSON Echo Server
----------------
Waits for JSON message, decodes it, re-encodes it, and sends it back.

```
require 'ezmq'
require 'json'

server = EZMQ::Server.new encode: -> m { JSON.dump m }, decode: -> m { JSON.load m }
server.listen
```

JSON Synchronous Client Request
-------------------------------
Encodes a message in JSON, sends it twice, prints the first one raw, and decodes the second.

```
require 'ezmq'
require 'json'

client = EZMQ::Client.new encode: -> m { JSON.dump m }
puts client.request 'test'
client.decode = -> m { JSON.load m }
puts client.request 'test'
```

'foorever' Publisher
--------------------
Publishes an endless stream of 'foo's with a topic of 'foorever'.

```
require 'ezmq'

publisher = EZMQ.Publisher.new topic: 'foorever'

loop do
  publisher.send 'foo'
end
```

'foorever' Subscriber
---------------------
Subscribes to topic 'foorever', prints any messages it receives.

```
require 'ezmq'

subscriber = EZMQ.Subscriber.new topic: 'foorever'
subscriber.listen
````

Operating System Notes
======================

As this relies on [ffi-rzmq](https://github.com/chuckremes/ffi-rzmq), you will need to have the zeromq libraries available.

For OSX, [Homebrew](http://brew.sh/) is probably the easiest way to handle this:

```brew install zeromq```

For Ubuntu, [Chris Lea's PPA](https://launchpad.net/~chris-lea/+archive/ubuntu/zeromq) is a good choice:

```
sudo add-apt-repository ppa:chris-lea/zeromq
sudo aptitude update
sudo aptitude install libzmq3-dev
```

For Windows, you should really consult the [ØMQ documentation](http://zeromq.org/docs:windows-installations).
