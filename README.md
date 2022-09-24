# protohackers

attempts (& sometimes solutions) to https://protohackers.com/ problems

done using elixir, attempting to use minimal libs

currently using:
- [Jason](https://hexdocs.pm/jason/readme.html), for handling encoding / decoding JSON into maps
- [`gen_tcp`](https://www.erlang.org/doc/man/gen_tcp.html) for handling TCP connections
- misc. otp-related Elixir things (Application, Supervisor, GenServer, Task, etc.)

## 0: Smoke Test (`lib/server/echo.ex`)

Status: Complete! (157th on leaderboard)

Attempted to do this without `mix` at first, realized quickly I was going to need OTP primitives to better handle multiple clients at the same time, therefore reached for mix.

Didn't take too long (mostly because the example on the Elixir docs for how to use `gen_tcp` show how to make an echo server .-.)

Spent some time writing tests for this to ensure it could handle all the spec, mostly as a testing ground since after checking 'Prime time', I knew I wanted to learn how to test without having to poke at stuff using `telnet` each time.

## 1: Prime Time (`lib/server/prime.ex`)

Status: Complete! (102nd on leaderboard)

Took much longer, since I wanted a proper testing setting setup, and did end up bringing in a library to take care of JSON parsing for me.

Thought I had done it, and made it far through the tests, until I hit into a snag with a long test input.
Took some time but eventually figured out it was https://en.wikipedia.org/wiki/Maximum_segment_size related.

Fixed it up by making my own chunk impl., and tada!

## 2: Means to an End (`lib/server/means.ex`)

Status: In Progress
