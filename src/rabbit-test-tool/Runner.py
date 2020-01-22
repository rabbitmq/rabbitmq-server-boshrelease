import subprocess

from printer import console_out


class Runner:
    def __init__(self):
        self._benchmark_status = dict()
        self.actor = "RUNNER"

    def get_benchmark_statuses(self):
        return self._benchmark_status

    def get_benchmark_status(self, status_id):
        return self._benchmark_status[status_id]

    def run_benchmark(self, unique_conf, common_conf, playlist_entry, policies, run_ordinal):
        status_id = unique_conf.technology + unique_conf.node_number

        nodes = ""
        for x in range(int(unique_conf.cluster_size)):
            comma = ","
            if x == 0:
                comma = ""

            node_number = int(unique_conf.node_number) + x
            nodes = f"{nodes}{comma}rabbit@rabbitmq{node_number}"

        self._benchmark_status[status_id] = "started"
        exit_code = subprocess.call(["bash", "rabbit-test-tool",
                                "--mode", common_conf.mode,
                                "--topology", playlist_entry.topology,
                                "--policies", policies,
                                "--run-id", common_conf.run_id,
                                "--technology", unique_conf.technology,
                                "--nodes", nodes,
                                "--version", unique_conf.broker_version,
                                "--hosting", common_conf.hosting,
                                "--instance", unique_conf.instance,
                                "--volume", unique_conf.volume,
                                "--filesystem", unique_conf.filesystem,
                                "--tenancy", unique_conf.tenancy,
                                "--core-count", str(unique_conf.core_count),
                                "--threads-per-core", str(unique_conf.threads_per_core),
                                "--tcp-no-delay", unique_conf.no_tcp_delay,
                                "--broker-hosts", ','.join(common_conf.broker_hosts),
                                "--broker-mgmt-port", str(15672),
                                "--broker-user", common_conf.username,
                                "--broker-password", common_conf.password,
                                "--run-tag", common_conf.run_tag,
                                *(["--postgres-jdbc-url", common_conf.postgres_url] if common_conf.postgres_url else []),
                                *(["--postgres-user", common_conf.postgres_user] if common_conf.postgres_user else []),
                                *(["--postgres-pwd", common_conf.postgres_pwd] if common_conf.postgres_pwd else []),
                                *(["--config-tag", unique_conf.config_tag] if unique_conf.config_tag else []),
                                "--override-step-seconds", str(common_conf.override_step_seconds),
                                "--override-step-repeat", str(common_conf.override_step_repeat),
                                "--override-step-msg-limit", str(common_conf.override_step_msg_limit),
                                "--pub-connect-to-node", unique_conf.pub_connect_to_node,
                                "--con-connect-to-node", unique_conf.con_connect_to_node,
                                "--grace-periond-sec", str(playlist_entry.grace_period_sec),
                                "--run-ordinal", str(run_ordinal),
                                "--benchmark-tags",
                                common_conf.tags,
                                playlist_entry.get_topology_variables(),
                                playlist_entry.get_policy_variables()])

        if exit_code != 0:
            console_out(self.actor, f"Benchmark {unique_conf.node_number} failed")
            self._benchmark_status[status_id] = "failed"
        else:
            self._benchmark_status[status_id] = "success"
