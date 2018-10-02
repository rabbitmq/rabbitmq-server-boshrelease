# Why do we need RabTap?

Fast and colourful Swiss army knife for RabbitMQ. Tap/Pub/Sub messages, create/delete/bind queues and exchanges, inspect broker.

The most relevant feature is tracing messages being sent to exchanges using RabbitMQ exchange-to-exchange bindings without affecting actual message delivery (aka tapping).


# How to use it

```
rabtap - RabbitMQ wire tap.

Usage:
  rabtap -h|--help
  rabtap tap EXCHANGES [--uri URI] [--saveto=DIR] [-jknv]
  rabtap (tap --uri URI EXCHANGES)... [--saveto=DIR] [-jknv]
  rabtap info [--api APIURI] [--consumers] [--stats]
              [--filter EXPR]
              [--omit-empty] [--show-default] [-knv]
  rabtap pub [--uri URI] EXCHANGE [FILE] [--routingkey=KEY] [-jkv]
  rabtap sub QUEUE [--uri URI] [--saveto=DIR] [-jkvn]
  rabtap exchange create EXCHANGE [--uri URI] [--type TYPE] [-adkv]
  rabtap exchange rm EXCHANGE [--uri URI] [-kv]
  rabtap queue create QUEUE [--uri URI] [-adkv]
  rabtap queue bind QUEUE to EXCHANGE --bindingkey=KEY [--uri URI] [-kv]
  rabtap queue rm QUEUE [--uri URI] [-kv]
  rabtap conn close CONNECTION [--reason=REASON] [--api APIURI] [-kv]
  rabtap --version
```

We don't need to pass `--uri URI` because this job declares the following `rabtap` environment variables when we log in as root (i.e. `sudo -i`): `RABTAP_AMQPURI` and `RABTAP_APIURI`.

# How to use RabTap to trace messages

This is an example of how to trace all messages being published to a direct exchange called `amqp.direct`:
```
rabtap tap amqp.direct:myqueue
```

Examples for binding keys used in tap command:

- `#` on an exchange of type `topic` will make the tap receive all messages on the exchange.
- a valid queue name for an exchange of type `direct` binds exactly to messages destined for this queue
- an empty binding key for exchanges of type `fanout` or type `headers` will receive all messages published to these exchanges

More examples:
- `$ rabtap tap my-topic-exchange:#`
- `$ rabtap tap my-fanout-exchange:`
- `$ rabtap tap my-headers-exchange:`
- `$ rabtap tap my-direct-exchange:binding-key`
