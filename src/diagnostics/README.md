# Diagnostics

Suite of tests that verify RabbitMQ is running correctly. These suite of tests are automatically run we deploy a release. Additionally, we run manually them.

## How to add tests

1. Add a test file with the name `{mytestname}_test.bash`, e.g. `aliveness_test.bash` under `src/diagnostics`.
2. Use [aliveness_test.bash](test/aliveness_test.bash) as a starting point


## How to run them

To run them from within a RabbitMQ node:
```
# diagnostics
```

To run them across all RabbitMQ nodes, just invoke the following from the root folder of this bosh release and follow the steps:
```
gmake diagnostics
```

Or run the following command instead with the deployment you want to run the diagnostics:
```
CONFIG=deployment_configurations/rmq-20180724.yml gmake diagnostics
```

In either case, we expect a output similar to this one. The output below corresponds to a **failed** diagnostic (See `gmake: *** [Makefile:194: diagnostics] Error 2`) with `2` one test case `T_OnlyConfiguredPluginsAreRunning` failing in both nodes.
```
Running diagnostics on rmq-160929335 ...
Check out output at /tmp/rmq-160929335-2018-10-16T14:16:52Z.log
Running tests on rmq/0 ...
PASS T_CanAccessManagementAPI
PASS T_CanAccessManagementUI
PASS T_CanDeclareQueueAndUseItToPublishAndConsume
PASS T_ConfiguredErlangVersionIsRunning
PASS T_ConfiguredRabbitMQVersionIsRunning
FAIL T_OnlyConfiguredPluginsAreRunning

Running tests on rmq/1 ...
PASS T_CanAccessManagementAPI
PASS T_CanAccessManagementUI
PASS T_CanDeclareQueueAndUseItToPublishAndConsume
PASS T_ConfiguredErlangVersionIsRunning
PASS T_ConfiguredRabbitMQVersionIsRunning
FAIL T_OnlyConfiguredPluginsAreRunning

gmake: *** [Makefile:194: diagnostics] Error 2
```

We open `/tmp/rmq-160929335-2018-10-16T14:16:52Z.log` to find out what we went wrong:
```
...
rmq/d5172e3b-7a61-4f4f-bf6f-c87d84951fad: stdout | --- FAIL T_OnlyConfiguredPluginsAreRunning (0s)
rmq/d5172e3b-7a61-4f4f-bf6f-c87d84951fad: stdout |     /var/vcap/jobs/diagnostics/packages/diagnostics/configuration_test.bash:34: Not implemented yet
rmq/d5172e3b-7a61-4f4f-bf6f-c87d84951fad: stdout |
...
```
We can see that the failing test cases is not implemented yet.
