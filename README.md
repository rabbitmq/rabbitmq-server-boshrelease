## Q & A

### How do I use this BOSH release?

All actions are captured in the `./script` dir.

To configure all required dependencies on your system, run `./script/setup`

To create a new manifest, run `./script/create-manifest`. This will write the deployment configuration to a `deployment` file and the BOSH manifest to `manifest.yml` file.

To deploy an existing configuration, run `./script/deploy`

To delete a deployment, run `./script/delete-deployment`

To print a deployment information, run `./script/which-deployment`

To create a new dev release, run `./script/create-dev-release` and then `./script/deploy`. You will need to set the release version to `latest` (we default to final release version) when creating the manifest.

When the time comes to cut a new final release, `./script/create-final-release` will do most of the heavy lifting. You will still need to create a git tag and update the `CHANGELOG.md`. It's a small price to pay for the excitement that shipping a final release brings.

To monitor a deployment, you can clone [the DataDog dashboard](https://app.datadoghq.com/dash/272837/rmq-deployment-example?live=true&page=0&is_auto=false&from_ts=1491812266751&to_ts=1491815866751&tile_size=m) and edit the `deployment` variable.

### How can I make this BOSH release better?

You're a champ for just thinking it! Making things better is deeply rewarding, we already like you very much : )

When you're making local changes and want to test the release, you can use `./script/create-dev-release` and then `./script/deploy`. Remember to set the release version to `latest` when creating the manifest with `./script/create-manifest`.

Any problems that you come across are bugs and should preferably be raised as Github pull requests. Github issues are OK as well, but they will take longer to action. Every little helps, we welcome all forms of contribution.

### Isn't `cf-rabbitmq-release` the official RabbitMQ BOSH release?

Yes it is, and we don't expect it to change anytime soon. This BOSH release must remain private and restricted to PCF RabbitMQ & RabbitMQ Core teams only. Do not share with Pivotal Support or Sales and definitely do not mention it to any of our customers or external collaborators.

We created this BOSH release to make it easier for the RabbitMQ Core team to deploy long-running RabbitMQ environments, and ad-hoc testing environments.

We also wanted to explore what it would look like to create a RabbitMQ BOSH release from scratch, with all the learnings from [cf-rabbitmq-release](https://github.com/pivotal-cf/cf-rabbitmq-release).

For all we know, this release is just a stepping stone towards improving cf-rabbitmq-release.

It is also possible that this BOSH release will one day become an official one, maintained by the RabbitMQ Core team and consumed by PCF RabbitMQ. After all, it's easier for us to learn BOSH than PCF RabbitMQ to learn the many sharp edges that both RabbitMQ and Erlang have. We are already creating RabbitMQ packages for every major OS and Linux distribution, it's only logical that we take ownership of the BOSH release as well.



## Learnings

### Compiling Erlang from source

[github.com/erlang/otp](https://github.com/erlang/otp/releases) is the official place for downloading Erlang patch releases, such as 19.3.4

Patch releases are not available from [erlang.org](http://www.erlang.org/downloads)

### Pick Your Erlang - PYE&#8482;

This release ships with multiple Erlang versions, all used in production. Take a look in `packages/erlang-*`

The Erlang version that will be used to run RabbitMQ can be selected via `./script/create-manifest`

### Leverage remote RabbitMQ Generic UNIX artefacts

We need to be able to deploy any RabbitMQ version, even dev releases produced by our CI.

When `./script/create-manifest` asks you which RabbitMQ package you want to deploy, feel free to provide any `rabbitmq-server-generic-unix-*`, either from [GitHub releases](https://github.com/rabbitmq/rabbitmq-server/releases) or [Bintray](https://dl.bintray.com/just-testing/all-dev/rabbitmq-server/).

RabbitMQ v3.5 generic-unix packages are not fully supported. Even though cluster formation will succeed,without the rabbitmq_clusterer plugin, arbitrary node restarts will fail. Since there is little interest in RabbitMQ v3.5, we do not plan to address this shortcoming.

### Limitations when configuring system user limits

The correct way of setting system user limits in Linux is through `/etc/security/limits.d`. It might also be necessary to modify `/etc/pam.d/common_session`, depending on the Linux distribution.

Since we are running rabbitmq-server via `start-stop-daemon`, configuring system user limits through `/etc/security/limits.d` is not going to work. Executing `ulimits -n` just before running `start-stop-daemon` works just fine.

### Template a single env file, never template scripts

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

### Leverage RabbitMQ environment variables, be aware of their limitations

RabbitMQ recognises many environment natively. We tried using `RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS` &amp; `RABBITMQ_CTL_ERL_ARGS` to configure the Erlang cookie, [but we have come across some limitations](https://github.com/rabbitmq/rabbitmq-server/issues/1206).

### Always guard against missing shell variables

The first time you use an environment variable in a script, ensure that it has been defined. It's as simple as `${FOO:?must be defined}`. Don't worry about the repetition, it will save you many frustrating debugging sessions.

### Prefer configuring RabbitMQ via commands

This is most likely to stay consistent across versions. For example, RabbitMQ v3.7 will have a new configuration file format. The old one will still work, but we want to promote the new one as much as possible.

Be aware of commands that take multiple arguments, such as `rabbitmq-plugins enable PLUGIN-A [PLUGIN-B...]`. They can speed things up considerably.

If a command fails, it will be more obvious what failed and should even hint how to fix the failure. The new configuration format in RabbitMQ v3.7 will help things, for sure.
