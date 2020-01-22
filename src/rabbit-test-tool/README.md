# run-playlist.py

A playlist runner for bosh deployed RabbitMQ. For use with playlists
like
<https://github.com/Vanlightly/RabbitTestTool/tree/master/orchestration/run/playlists>

Configure your deployment manifest like so:

```yaml
...
    jobs:
    - name: rabbitmq-perf-test
      release: rabbitmq-server
      properties:
        rabbitmq-perf-test:
          executable: /var/vcap/jobs/rabbitmq-perf-test/bin/run-playlist
          options: '--playlist-file playlists/qq-point-to-point-safe.json --gap-seconds 30 --postgres-jdbc-url jdbc:postgresql://some.db.elephantsql.com:5432/user --postgres-user user --postgres-password password --config-tag a-tag-for-this-config'
          connect_to_nodes: 'all'
          broker_version: ((rmq_server_release))
          broker_vm_type: ((rmq_vm_type))
          broker_disk_type: ((rmq_persistent_disk_type))
          broker_filesystem: ext4
          broker_vm_core_count: 1
          broker_vm_threads_per_core: 2
...
```

## Postgres Benchmark Logging

Expects a table that looks like:

```shell
                            Table "public.benchmark"
      Column      |            Type             | Collation | Nullable | Default
------------------+-----------------------------+-----------+----------+---------
 benchmark_id     | uuid                        |           | not null |
 run_id           | character varying(100)      |           | not null |
 topology_name    | character varying(200)      |           | not null |
 benchmark_type   | character varying(20)       |           | not null |
 dimensions       | character varying(1000)     |           | not null |
 description      | character varying(1000)     |           | not null |
 run_tag          | character varying(10)       |           | not null |
 config_tag       | character varying(50)       |           | not null |
 node             | character varying(50)       |           | not null |
 technology       | character varying(100)      |           | not null |
 broker_version   | character varying(50)       |           | not null |
 instance         | character varying(100)      |           | not null |
 volume           | character varying(100)      |           | not null |
 filesystem       | character varying(10)       |           | not null |
 tenancy          | character varying(50)       |           | not null |
 core_count       | smallint                    |           | not null |
 threads_per_core | smallint                    |           | not null |
 hosting          | character varying(50)       |           | not null |
 start_time       | timestamp without time zone |           | not null |
 start_ms         | bigint                      |           | not null |
 end_time         | timestamp without time zone |           |          |
 end_ms           | bigint                      |           |          |
 topology         | json                        |           |          |
 run_ordinal      | integer                     |           |          |
 policies         | json                        |           |          |
 tags             | character varying(1000)     |           |          |
 arguments        | character varying           |           |          |
Indexes:
    "benchmark_pk1" PRIMARY KEY, btree (benchmark_id)
```
