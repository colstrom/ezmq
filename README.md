EZMQ (Effortless ZeroMQ)
========================

EZMQ is a wrapper around the wonderful `ffi-rzmq` gem, which (as the name suggests) uses FFI, and exposes a fairly raw C-like interface. As elegant as 0MQ is, C doesn't feel like Ruby, and FFI bindings feel like C. EZMQ makes some reasonable assumptions to help you focus on what makes your code special, and not worry about setting up 0MQ.

Any of the magical hand-wavey bits (contexts, sockets, etc) are still exposed for tinkering, EZMQ just starts you off with some sane defaults.

Operating System Notes
----------------------

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
