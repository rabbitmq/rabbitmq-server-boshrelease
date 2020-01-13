import uuid

from command_args import get_optional_arg, get_mandatory_arg, get_optional_arg_validated


class CommonConfiguration:

    def __init__(self, args):
        self.run_id = str(uuid.uuid4())
        self.tags = get_mandatory_arg(args, "--tags", "")
        self.mode = get_optional_arg_validated(args, "--mode", "", ["benchmark", "model"], "benchmark")
        self.playlist_file = get_mandatory_arg(args, "--playlist-file", "")
        self.background_policies_file = get_optional_arg(args, "--bg-policies-file", "", "none")
        self.background_topology_file = get_optional_arg(args, "--bg-topology-file", "", "none")
        self.background_delay = int(get_optional_arg(args, "--bg-delay", "", "0"))
        self.background_step_seconds = int(get_optional_arg(args, "--bg-step-seconds", "", "0"))
        self.background_step_repeat = int(get_optional_arg(args, "--bg-step-repeat", "", "0"))
        self.gap_seconds = int(get_mandatory_arg(args, "--gap-seconds", ""))
        self.repeat_count = int(get_optional_arg(args, "--repeat", "", "1000000"))
        self.override_step_seconds = int(get_optional_arg(args, "--override-step-seconds", "", "0"))
        self.override_step_repeat = int(get_optional_arg(args, "--override-step-repeat", "", "0"))
        self.override_step_msg_limit = int(get_optional_arg(args, "--override-step-msg-limit", "", "0"))
        self.broker_hosts = get_mandatory_arg(args, "--broker-hosts", "").split(',')
        self.username = get_mandatory_arg(args, "--username", "")
        self.password = get_mandatory_arg(args, "--password", "")
        self.postgres_url = get_optional_arg(args, "--postgres-jdbc-url", "", "")
        self.postgres_user = get_optional_arg(args, "--postgres-user", "", "")
        self.postgres_pwd = get_optional_arg(args, "--postgres-password", "", "")
        self.node_counter = 1
        self.hosting = "bosh"
        self.log_level = get_optional_arg(args, "--log-level", "", "info")
