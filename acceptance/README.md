# Acceptance Test Suite

Suite of tests aimed to be run in order to validate a release. Useful for
instance when we add a new Erlang version and we want to validate that everything
works.

## How to add tests

1. Create a test file under `test` folder with the name `{mytestname}_test.bash`, e.g. `aliveness_test.bash`
2. Use [aliveness_test.bash](test/aliveness_test.bash) as a starting point


## How to run them

Run the following command to run the run the tests against a Bosh deployment. It will prompt you to choose the deployment.
```
gmake verify
```

Or run the following command instead with the deployment you want to verify:
```
CONFIG=deployment_configurations/rmq-20180724.yml gmake verify
```

In either case, we expect a output similar to this one. It first prints out the deployment information and then runs the tests against the deployment.
```
Loading rmq-mrosales-20180925 deployment info ...
+------------------------+--------------------------------------------------------------------------------------+
| RMQ MANAGEMENT URL     | https://rmq-mrosales-20180925.rabbitmq.pivotal.io/#/login/admin/DE6t9wch0oAjPIOaywkS |
+------------------------+--------------------------------------------------------------------------------------+
| RMQ AMQP URL           | amqp://admin:DE6t9wch0oAjPIOaywkS@10.0.1.0:5672/%2F                                  |
| RMQ AMQP URL           | amqp://admin:DE6t9wch0oAjPIOaywkS@10.0.1.1:5672/%2F                                  |
+------------------------+--------------------------------------------------------------------------------------+
| RMQ NETDATA URL        | https://0-netdata-rmq-mrosales-20180925.rabbitmq.pivotal.io                          |
| RMQ NETDATA URL        | https://1-netdata-rmq-mrosales-20180925.rabbitmq.pivotal.io                          |
+------------------------+--------------------------------------------------------------------------------------+
| RMQ VERSION            | 3.7.8                                                                                |
| ERLANG VERSION         | 21.1                                                                                 |
+------------------------+--------------------------------------------------------------------------------------+
| RMQ VM                 | medium + preemptible + 50GB_ephemeral_disk                                           |
| RMQ VM PERSISTENT DISK | 50GB                                                                                 |
+------------------------+--------------------------------------------------------------------------------------+
| BOSH DEPLOYMENT        | rmq-mrosales-20180925                                                                |
| BOSH RELEASE VERSION   | 0.16.0+dev.1538038184                                                                |
+------------------------+--------------------------------------------------------------------------------------+
=== RUN T_CanAccessManagementAPI
--- PASS T_CanAccessManagementAPI (1s)
=== RUN T_CanAccessManagementUI
--- PASS T_CanAccessManagementUI (0s)
=== RUN T_CanDeclareQueueAndUseItToPublishAndConsume
--- PASS T_CanDeclareQueueAndUseItToPublishAndConsume (0s)

Ran 3 tests.
```

If we want to enable Bash debugging we run it as follows:
```
DEBUG=true gmake verify 
```
