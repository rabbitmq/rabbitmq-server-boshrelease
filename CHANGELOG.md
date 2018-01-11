## v0.12.0 - 2018-01-11

* Add a single point of entry to all scripts: `make` (GNU preferred)
* Default RabbitMQ to 3.7.2
* Add support for RabbitMQ versions that do not handle multiple plugin dirs
* Capture BOSH release version when rabbitmq-server job starts/stops
* Increase the max wait time for downloading generic unix packages
* Fail rabbitmq-server job if `install_generic_unix_package` fails
* Fix file descriptor limit increase
* Ensure releases dirs exist, otherwise deploy might fail
* Add new Erlang versions
  * **20.1.7** - default
  * 19.3.6.4
  * 18.3.4.7
  * 17.5.6.9
  * R16B03
* Remove superseded Erlang versions
  * 20.1.1
  * 20.1
  * 19.3.6.2
  * 18.3.4.5


## v0.11.0 - 2017-10-11

* Allow deployment configurations to be deployed directly, e.g. `./script/deploy-configuration deployment_configurations/rmq-lg.yml`
* Expose [all RabbitMQ configurations](https://github.com/rabbitmq/rabbitmq-server/blob/stable/docs/rabbitmq.config.example) via rabbitmq-server job properties
* Add [rabbitmq-support-tools](https://github.com/rabbitmq/support-tools), various support tools not yet ready to be included in the RabbitMQ distribution
* Install [RabbitMQ man pages](https://github.com/rabbitmq/rabbitmq-server/tree/master/docs), e.g. `man rabbitmqctl`
* Add [looking_glass](https://github.com/rabbitmq/looking_glass), an Erlang/Elixir/BEAM profiler tool developed by @essen for RabbitMQ
* Add [netdata](https://github.com/firehol/netdata) &amp; integrate with RabbitMQ - available at `https://[INDEX]-netdata-[DEPLOYMENT].[CF_APPS_DOMAIN]`
* Update [rabbitmq_random_exchange](https://github.com/rabbitmq/rabbitmq-random-exchange) plugin to 0.10.0
* Add Erlang 20.1.1
* Add Erlang 20.1
* Remove Erlang 20.0.5
* Remove Erlang 20.0.4
* Remove Erlang 19.3.6.1
* Add tmux to all deployments
* Make all VMs preemptible (saves about ~70% on cost)

## v0.10.0 - 2017-09-11

* Make release bosh cli v2 compatible
* Anyone with a BOSH v2 Director can now deploy custom RMQ clusters using this release - just run `./script/deploy`
* Add rabbitmq-collect-env script
* Add rabbitmq_random_exchange v0.9.0 plugin
* Fix enabling all plugins on RabbitMQ 3.7 - `rabbitmq-plugins list` command returns a non-0 exit status on RabbitMQ 3.7
* Add Erlang 19.6.3.1
* Add Erlang 19.3.6.2
* Add Erlang 20.0.4
* Remove all unused Erlang versions - they were pre-compiled using Docker and were not as useful anymore

## v0.9.0 - 2017-07-27

* Add Erlang 20.0.2
* Make RABBITMQ_DISTRIBUTION_BUFFER_SIZE configurable

## v0.8.0 - 2017-07-12

* Add Erlang 20.0.1
* Always resolve hostnames & update Erlang cookie
* Add option to define scheduler bind type
* Add Erlang 19.2.2
* Package start-stop-daemon
* Wait for mnesia tables before setting the cluster name
* Change ownership recursively

## v0.7.0 - 2017.06.22

* Add Erlang 20.0

## v0.6.0 - 2017.06.08

* Add Erlang 19.3.6

## v0.5.0 - 2017.06.08

* Add option to deploy with Erlang 19.3.5
* Default nodes to t2.small

## v0.4.0 - 2017.06.06

* Use timestamp in ERL_CRASH_DUMP files, store them in log dir
* Fix dir permissions - erl_crash.dump could not be written
* Erlang VM will not ignore `kill` signals
* Default vm_memory_high_watermark to `0.5`, safest for production
* Default disk_free_limit to `{ mem_relative, 2.0 }`, safest for production
* Add option to deploy with Erlang 19.3
* Default RabbitMQ package to 3.6.10, latest stable
* Update to latest stemcell, AWS Xen-HVM 3421.4
* Update datadog-agent to 5.8.5.5

## v0.3.0 - 2017.05.08

* add option to deploy with Erlang 18.3.4.4
* [best-practice RabbitMQ stop](https://docs.google.com/document/d/1zz6USVo-VyNeDOd8Ux1USyHsSJe8EcMef59bVq_V0vM)
* run management commands only on the bootstrap node
* address long names quirks ([fixed since RabbitMQ 3.6.6](https://github.com/rabbitmq/rabbitmq-server/issues/890))
* simplify joining nodes across multiple deployments
* automate new manifest creation, sensible defaults &amp; great choices
* automate dev release testing
* automate setup on OS X
* delete deployment command

## v0.2.0 - 2017.03.23

* deploy any RabbitMQ v3.7 version
* support gz generic UNIX artefacts
* deploy any RabbitMQ v3.5 version - cluster will form but arbitrary node restarts will fail

## v0.1.0 - 2017.03.21

* deploy any RabbitMQ v3.6 version, via generic UNIX xz artefact URL
* Erlang 19.2.3
* rabbitmq-server only
* single tenant, ODB friendly
