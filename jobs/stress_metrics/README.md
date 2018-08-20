The intent of this job is to put pressure on RabbitMQ's metrics system.
It does this by querying these metrics every 30s:

* overview
* node metrics
* connections
* channels
* vhosts
* exchanges for vhost '/'
* queues for vhost '/'

The interval is configurable, contributions are welcome for:

* multiple vhost support
* queried metrics
