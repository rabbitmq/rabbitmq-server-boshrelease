# A BOSH Release for Development, Troubleshooting and QA

## This is NOT the Official RabbitMQ BOSH Release

The official RabbitMQ BOSH release is [cf-rabbitmq-release](https://github.com/pivotal-cf/cf-rabbitmq-release)

This BOSH release is used by the RabbitMQ team to debug all things RabbitMQ &amp; Erlang on GCP, AWS &amp; vSphere.
This release is only meant to be used for debugging purposes. It comes with no guarantees or promises,
it just helps us ensure RabbitMQ is stable across different IaaS platforms, and is BOSH-friendly.

## Prerequisites

First, ensure the following are installed and available in `$PATH`:

* [bosh cli v2](https://bosh.io/docs/cli-v2.html)
* [jq](https://github.com/stedolan/jq)
* [yq](https://github.com/kislyuk/yq)
* [lpass cli](https://github.com/lastpass/lastpass-cli)

For the RabbitMQ Core team, ensure [rabbitmq/rabbitmq-credentials](https://github.com/rabbitmq/rabbitmq-credentials) is cloned alongside this repo, then `cd rabbitmq-server-boshrelease` & configure either `env.example` or `envrc.example` as a dotfile, then run `. .env` or `direnv allow`.

## Submodules

Don't forget to initialize this repository's submodules:

```
git submodule update --init
```

### Initial Deployment

To create a new deployment, run `deploy` . A successful deploy will store a deployment
configuration file in `deployment_configurations`.

### Upgrading

To update an existing deployment, run `deploy-configuration`

## How can I make this BOSH release better?

You're a champ for just thinking it! Making things better is deeply rewarding, we already like you very much : )

When you're making local changes and want to test the release, you can use `create-dev-release` and then `deploy` - remember to select the `LATEST` BOSH release version

To create a new BOSH dev release, run `create-dev-release` and then `deploy`. You will need to set the release version to `latest` (we default to final release version) when creating the manifest.

When the time comes to cut a new final release, `create-final-release` will do most of the heavy lifting. You will still need to create a git tag and update the `CHANGELOG.md`. It's a small price to pay for the excitement that shipping a final release brings.



## Provisioning Erlang/OTP and RAbbitMQ

### Compiling Erlang from source

[github.com/erlang/otp](https://github.com/erlang/otp/releases) is the official place for downloading Erlang patch releases, such as 19.3.4

Patch releases are not available from [erlang.org](http://www.erlang.org/downloads)

### Pick Your Erlang - PYE&#8482;

This release ships with multiple Erlang versions, all used in various production environments that we've come across, mostly via escalations or support cases. Take a look in `packages/erlang-*`

The Erlang version that will be used to run RabbitMQ can be selected when running `deploy`

### Using RabbitMQ Snapshot Releases

We need to be able to deploy any RabbitMQ version, even dev releases produced by our CI. To obtain a
GA version of RabbitMQ, see [RabbitMQ releases on GitHub](https://github.com/rabbitmq/rabbitmq-server/releases).
Snapshot builds are [available from Bintray](https://dl.bintray.com/just-testing/all-dev/rabbitmq-server/).

When `deploy` asks you which RabbitMQ Server release you want to deploy. Select `OTHER` if you need to provide
an arbitrary `rabbitmq-server-generic-unix-*` package URL, e.g. a snapshot build from the Bintray repo mentioned above.

RabbitMQ v3.5 generic-unix packages are not fully supported. Even though cluster formation will succeed,without the rabbitmq_clusterer plugin, arbitrary node restarts will fail. Since RabbitMQ 3.5.x is no longer under development,
we do not plan to address this shortcoming.

## Limitations and Recommended Practices

### OS/User Limit Configuration Limitations

The correct way of setting system user limits in Linux is through `/etc/security/limits.d`. It might also be necessary to modify `/etc/pam.d/common_session`, depending on the Linux distribution.

Since we are running rabbitmq-server via `start-stop-daemon`, configuring system user limits through `/etc/security/limits.d` is not going to work. Executing `ulimits -n` just before running `start-stop-daemon` works just fine.

### Templating

Template a single env file, never template scripts.

Most BOSH releases end up templating files left, right & center. It's most unfortunate when shell scripts get templated since this breaks [shellcheck](https://www.shellcheck.net/).

> I cannot emphasise enough how important it is to run shellcheck against your shell scripts, preferably on every file save.

[It works really well to have a single env file](https://github.com/rabbitmq/rabbitmq-server-boshrelease/blob/master/jobs/rabbitmq-server/templates/env.erb) templated by BOSH, that contains all environment variables required by your release scripts. This has the added benefit of making it really easy to integrate your release executables with `bosh ssh`.

### Limit job scripts to BOSH lifecycles only

[All BOSH jobs will only contain scripts that correspond to BOSH lifecycles](https://github.com/rabbitmq/rabbitmq-server-boshrelease/tree/master/jobs/rabbitmq-server/templates/bin):

* drain
* post-start
* pre-start
* start
* stop

Using a single script to both stop and start a BOSH job is guaranteed to cause more trouble than it's worth. Also, we would be violating the [Single Responsibility Principle](https://en.wikipedia.org/wiki/Single_responsibility_principle) at great cost.

Respect the idempotency of all BOSH lifecycle events, [be aware of their limitations](https://bosh.io/docs/pre-start.html) and you are guaranteed the best BOSH experience. As all products, BOSH has its sharp edges, so don't make your life harder by ignoring this hard-earned advice.

### Using RabbitMQ Environment Variables

RabbitMQ recognises many environment natively. We tried using `RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS` &amp; `RABBITMQ_CTL_ERL_ARGS` to configure the Erlang cookie, [but we have come across some limitations](https://github.com/rabbitmq/rabbitmq-server/issues/1206).

### Undefined Shell Variables

The first time you use an environment variable in a script, ensure that it has been defined. It's as simple as `${FOO:?must be defined}`. Don't worry about the repetition, it will save you many frustrating debugging sessions.

### Configuring RabbitMQ

This is most likely to stay consistent across versions. For example, RabbitMQ v3.7 will have a new configuration file format. The old one will still work, but we want to promote the new one as much as possible.

Be aware of commands that take multiple arguments, such as `rabbitmq-plugins enable PLUGIN-A [PLUGIN-B...]`. They can speed things up considerably.

If a command fails, it will be more obvious what failed and should even hint how to fix the failure. The new configuration format in RabbitMQ v3.7 will help things, for sure.
