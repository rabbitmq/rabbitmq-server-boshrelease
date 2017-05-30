## 0.3.0 - 2017.05.08

* add option to deploy with Erlang 18.3.4.4
* [best-practice RabbitMQ stop](https://docs.google.com/document/d/1zz6USVo-VyNeDOd8Ux1USyHsSJe8EcMef59bVq_V0vM)
* run management commands only on the bootstrap node
* address long names quirks ([fixed since RabbitMQ 3.6.6](https://github.com/rabbitmq/rabbitmq-server/issues/890))
* simplify joining nodes across multiple deployments
* automate new manifest creation, sensible defaults &amp; great choices
* automate dev release testing
* automate setup on OS X
* delete deployment command

## 0.2.0 - 2017.03.23

* deploy any RabbitMQ v3.7 version
* support gz generic UNIX artefacts
* deploy any RabbitMQ v3.5 version - cluster will form but arbitrary node restarts will fail

## 0.1.0 - 2017.03.21

* deploy any RabbitMQ v3.6 version, via generic UNIX xz artefact URL
* Erlang 19.2.3
* rabbitmq-server only
* single tenant, ODB friendly
