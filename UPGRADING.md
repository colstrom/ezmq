Upgrading from 0.3.x to 0.4+
----------------------------

#listen on EZMQ::Socket and EZMQ::Subscriber now requires a block, previously it was optional.

options[:protocol] has been renamed to options[:transport], to be correct.

options[:transport] is expected to be a :symbol, not a 'string'.

Upgrading from 0.1.x to 0.2+
----------------------------

Initializing a socket now allows `protocol`, `address`, and `port` as optional parameters.

If you were passing `address` in as a string containing all three, this is no longer required, and will fail.

`provides` and `action` removed from `Server` and `Subscriber` respectively. `handler` removed from #listen.

Server#listen and Subscriber#listen now yield received messages to a block, if given. The return of the block will be send as the response.

Client#request now yields the response message to the block.
