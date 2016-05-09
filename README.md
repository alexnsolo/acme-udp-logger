#### Your Mission
In your (clandestine) consulting work for ACME Spy Corporation, you've been tasked with the following:

- Listen for [UDP](https://en.wikipedia.org/wiki/User_Datagram_Protocol) packets on port 21337
- Parse said messages according to the specification
- Log the message contents for later review

The specification of each message is as follows:

```
Message Header, 30 bytes
Message Body, 45 bytes
  - Priority Code, 1 byte, string
  - Agent Number, 4 bytes, unsigned integer
  - Message, 40 bytes, string
```

Bytes are in _little-endian_ format.

#### Let's Get Started
Make a new project with Mix:

```
mix new acme_udp_logger
cd acme_udp_logger
```

Implement the [Application and Supervisor](http://elixir-lang.org/getting-started/mix-otp/supervisor-and-application.html) patterns in the `AcmeUdpLogger` module. This will allow us to supervise the code that will handle the UDP packets. If that code crashes, we can restart it atomically (a great feature of Elixir, by the way).

<script src="https://gist.github.com/civilframe/b704c2d1c1f8eee11332089be1645271.js"></script>

You will also have to add your application to the `mix.exs` file, within the `application/0` function.


#### Listening for UDP Packets

Elixir makes it very easy to start listening for UPD packets. In order to receive UDP packets, you'll need to use the `:gen_udp` Erlang module.

First we will need a module that will handle this task for us. Let's call it `MessageReceiver`. This module should implement [GenServer](http://elixir-lang.org/getting-started/mix-otp/genserver.html), so it can be supervised by the application and [run on its own process](http://elixir-lang.org/getting-started/processes.html).

<script src="https://gist.github.com/civilframe/212cfd60ea467a68732f8af528102320.js"></script>

Don't forget to add this module to the list of supervised children in `AcmeUdpLogger` (line 7):

<script src="https://gist.github.com/civilframe/00edd2bf0bb57f27a133be9125f98d39.js"></script>

At this point, you can test to see if everything is setup correctly:
1) Add a `IO.puts inspect(data)` on line 14 of the `MessageReceiver`
1) Start your application with `mix run --no-halt`
2) In a separate terminal session, use [netcat](https://en.wikipedia.org/wiki/Netcat) to send UPD packets to localhost, port 21337 `nc -u 127.0.0.1 21337`. After you run this command, netcat will allow you to send messages via UDP by simply typing some text and hitting Enter. You should see the logged message appearing in your first terminal session (running `mix run`).

#### Parsing UDP with Binary Pattern Matching

Okay, here's the good stuff. In the first `handle_info/2` function of `MessageReceiver`, we will parse the UPD binary data using pattern matching, and log it to the console using `Logger`:

<script src="https://gist.github.com/civilframe/8686f652cfe1008bba393b6cee9cd223.js"></script>

Here is what a test for the above would look like: [message\_receiver\_test.exs](https://gist.github.com/civilframe/5e6937df39266b0bbbcc8799ffafc11c).

In the binary pattern matching block (<< >> ), the left side is the variables I am assigning from values on the right side. The order of each expression corresponds to the order of the bytes in the message. You can see how nicely this lines up with the specification at the beginning of this post. For more on bitstring/binary pattern matching syntax, check the Elixir documentation [here](http://elixir-lang.org/docs/stable/elixir/Kernel.SpecialForms.html#::/2)
