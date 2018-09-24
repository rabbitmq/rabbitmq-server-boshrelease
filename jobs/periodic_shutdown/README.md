We did this so that we can test RabbitMQ's behaviour with many connections &
queues being re-created as nodes go away. This was done part of
https://github.com/rabbitmq/rabbitmq-server/pull/1526

This jobs does exactly what it says:
it shuts down RabbitMQ nodes on an interval, 600 seconds (10 minutes) by default.

When the job starts, it does the following:

* it waits for the interval to expire
* it shuts down the first node
* it waits for the interval to expire
* it shuts down the second node

It continues this cycle until it reaches the last node in the cluster,
and then it starts all over again.

If this job is restarted, the cycle starts from the first node.
