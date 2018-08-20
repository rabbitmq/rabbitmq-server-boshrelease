This job makes [RabbitMQ Perf Test](https://github.com/rabbitmq/rabbitmq-perf-test) available on the command line:

```sh
bosh -d rmq ssh client/apps/18bef44e-693a-4201-9bc5-1c5d47f982af

sudo -i

perftest -v
RabbitMQ Perf Test 2.2.0.RC1 (92cc998c181bce6f9e83139a5c1253469cdc7bf8; 2018-08-01T13:28:23Z)
RabbitMQ AMQP Client version: 5.3.0
Java version: 1.8.0_181, vendor: Oracle Corporation
Java home: /var/vcap/data/packages/java-jre-1.8/3898cec0bf6461fecc7fef679c88d45a9fc5e049
Default locale: en_US, platform encoding: UTF-8
OS name: Linux, version: 4.4.0-116-generic, arch: amd64
```

To run a benchmark against all RabbitMQ nodes in the cluster, run e.g.:

```sh
bosh -d rmq ssh client/apps/18bef44e-693a-4201-9bc5-1c5d47f982af

sudo -i

perftest --consumer-latency 600000 \
  --consumers 1000 \
  --heartbeat-sender-threads 10 \
  --interval 30 \
  --size 500 \
  --nio-thread-pool 20 \
  --nio-threads 10 \
  --procer-random-start-delay 60 \
  --producer-scheduler-threads 50 \
  --producers 1000 \
  --publishing-interval 60 \
  --queue-pattern 'nondurable%d' \
  --queue-pattern-from 1 \
  --queue-pattern-to 1000 \
  --uris 'amqp://USER:PASS@10.0.1.4:5672/%2F,amqp://USER:PASS@10.0.1.5:5672/%2F,amqp://USER:PASS@10.0.1.6:5672/%2F'
```

It might be helpful to co-locate tmux from [tmux-boshrelease](https://github.com/emalm/tmux-boshrelease).

## Why not just `cf push` ?

For a long time, we did the easiest thing which was to just [push RabbitMQ PerfTest to CloudFoundry](https://github.com/rabbitmq/rabbitmq-perf-test-for-cf).
We've soon learned that it was easy for a few PerfTest instances to start contending for CPU and/or network which would skew the benchmark results.
Even though [CloudFoundry isolation segments](https://docs.cloudfoundry.org/adminguide/isolation-segments.html) can mitigate against this,
we've learned that measuring message latency with PerfTest running within a container was producing unreliable measurements due to the way TCP/IP packets are routed, using iptables.
Even though this was reflecting the CloudFoundry reality,
it wasn't a fair representation for RabbitMQ or PerfTest. For more context, see [rabbitmq/workloads/low-latency](https://github.com/rabbitmq/workloads/tree/8c1b35585ac94c773f2e5afc3e5cbf9a887e7a69/low-latency).

Lastly, we've come across environments where we don't have access to CloudFoundry, only a BOSH Director.
This was the tipping point which made it obvious that we need isolated PerfTest environments,
sitting as close as possible to the broker, but not interfering with anything else.
