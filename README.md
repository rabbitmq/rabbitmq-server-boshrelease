## Deployment

This bosh release is supposed to be used with CF internal `tarantino` bosh director.
Defualt parameters for manifest, specified in `rabbitmq-server.yml` use tarantino
director UUID and cloud foundry cloud controller settings.

### Targeting director

You need to install [bosh CLI](https://bosh.io/docs/bosh-cli.html) first.

Credentials for the director are stored in lastpass.
To retrieve them you can use `lpass ls | grep bosh-env-tarantino`
to get credentials ID and `lpass show <ID>` to get credentials.

To target the director:

```
# target the director
bosh target https://tarantino.directors.cf-app.com:25555 tarantino
# login with credentials from lastpass
bosh login <user> <pass>
```

Bosh CLI will save current target and credentials in users home directory
configuration file.

### Creating deployment

To create a new bosh deployment manifest, you should copy `rabbitmq-server-vars-example.yml`
to `rabbitmq-server-vars.yml` and modify `deployment_name` and `server_host`.
`server_host` should point to a subdomain of `tarantino.directors.cf-app.com`.

Manifest will be created by merfing `rabbitmq-server-vars.yml` and
`rabbitmq-server.yml` files and deployed to the director when you run
`script/deploy` script.

### Accessing deployment.

After deployment, rabbitmq management console will be available on `server_host`
url.

To connect clients to deployment, you should get a private IP for deployed servers
using `bosh vms <deployment_name>` and configure clients to use this IP as an amqp host.

The release will start a datadog agent for a deployment, so you can configure
a datadog dashboard by cloning RMQ 3.6 private dashboard and changing `from` fields
for all the graphs.

## Q & A

### How do I use this BOSH release?

All actions are captured in the `./script` dir, and are meant to be self-contained and descriptive. `./script/setup` is a good first step. `./script/deploy` is the most useful action by far.

To create a new dev release, run `./script/dev`. When the time comes to cut a new final release, `./script/final` will do most of the heavy lifting. You will still need to create a git tag and update the `CHANGELOG.md`. It's a small price to pay for the excitement that shipping a final release brings.

### How can I make this BOSH release better?

You're a champ for just thinking it. Making things better is deeply rewarding, we already like you very much.

Any problems that you come across are bugs and should preferably be raised as Github pull requests. Github issues are OK as well, but they will take longer to action. Every little helps, we welcome all forms of contribution.

### Isn't `cf-rabbitmq-release` the official RabbitMQ BOSH release?

Yes it is, and we don't expect it to change anytime soon. This BOSH release must remain private and restricted to PCF RabbitMQ & RabbitMQ Core teams only. Do not share with Pivotal Support or Sales and definitely do not mention it to any of our customers or external collaborators.

We created this BOSH release to make it easier for the RabbitMQ Core team to deploy long-running RabbitMQ environments, and ad-hoc testing environments.

We also wanted to explore what it would look like to create a RabbitMQ BOSH release from scratch, with all the learnings from [cf-rabbitmq-release](https://github.com/pivotal-cf/cf-rabbitmq-release).

For all we know, this release is just a stepping stone towards improving cf-rabbitmq-release.

It is also possible that this BOSH release will become the new official one, maintained by the RabbitMQ Core team and consumed by PCF RabbitMQ. After all, it's easier for us to learn BOSH than PCF RabbitMQ to learn the many sharp edges that both RabbitMQ and Erlang have. We are already creating RabbitMQ packages for every major OS and Linux distribution, why not the BOSH release?



## Learnings

### Compiling Erlang from source

[github.com/erlang/otp](https://github.com/erlang/otp/releases) is the official place for downloading Erlang patch releases such as 19.2.3.

Patch releases are not available from [erlang.org](http://www.erlang.org/downloads).

### Pick Your Erlang - PYE&#8482;

The Erlang version used by RabbitMQ can be defined in the deployment manifest, e.g.:

```yaml
instance_groups:
- name: rmq
  jobs:
  - name: rabbitmq-server
    release: rabbitmq-server
    properties:
      erlang:
        version: 19.2.3
```

This release ships with Erlang 19.2.3, the version that we recommend for production deployments.

19.3 (latest stable) has a JSON regression, we are waiting for the first 19.3 patch release before reconsidering our Erlang version recommendation.

Erlang 18.3.4.5 is also acceptable for production deployments, we are thinking of adding it as the second supported Erlang version.

### Leverage remote RabbitMQ Generic UNIX artefacts

We need to be able to deploy any RabbitMQ version, even dev releases produced by our CI.

The easiest way of achieving this is to define the RabbitMQ generic UNIX archive as a manifest property, e.g.:

```yaml
instance_groups:
- name: rmq
  jobs:
  - name: rabbitmq-server
    release: rabbitmq-server
    properties:
      rabbitmq-server:
        generic-unix-url: https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_7_0_milestone14/rabbitmq-server-generic-unix-3.7.500.14.tar.xz
```

Even though RabbitMQ v3.5 will apparently cluster natively, without the rabbitmq_clusterer plugin, arbitrary node restarts will fail. Since we don't expect anymore v3.5 releases, we won't be spending time on this.

### Limitations when configuring system user limits

The correct way of setting system user limits in Linux is through `/etc/security/limits.d`. It might also be necessary to modify `/etc/pam.d/common_session`, depending on the distribution.

Since we are running rabbitmq-server via `start-stop-daemon`, configuring system user limits through `/etc/security/limits.d` is not going to work. Executing `ulimits -n` just before `start-stop-daemon` works just fine.

### Template a single env file, never template scripts

Most BOSH releases end up templating files left, right & center. It's most unfortunate when shell scripts get templated since this breaks [shellcheck](https://www.shellcheck.net/).

> I cannot emphasise enough how important it is to run shellcheck against your shell scripts, preferably on every file save.

It works really well if there is a single env file, most likely templated by BOSH, that contains all environment variables required by your release scripts. It makes it really easy to integrate your release executables with `bosh ssh`.

### Limit job scripts to BOSH lifecycles only

All BOSH jobs will only contain scripts that correspond to BOSH lifecycles:

* pre-start
* start
* post-start
* post-deploy
* drain
* stop

Using a single script to both stop and start a BOSH job is guaranteed to cause more trouble than it's worth. The Single Responsibility Principle comes to mind.

Respect the idempotency of all BOSH lifecycle events, be aware of their limitations and you are guaranteed the best BOSH experience. As all products, BOSH has its sharp edges, so don't make your life harder by ignoring this hard-earned advice.

### Leverage RabbitMQ environment variables, be aware of their limitations

RabbitMQ recognises many environment natively. We tried using `RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS` &amp; `RABBITMQ_CTL_ERL_ARGS` to configure the Erlang cookie, [but we have come across some limitations](https://github.com/rabbitmq/rabbitmq-server-boshrelease/commit/fb3a5fd4a9cd1ce9aad5a28a0e7ca125a3fc0071).

### Always guard against missing shell variables

The first time you use an environment variable in a script, ensure that it has been defined. It's as simple as `${FOO:?must be defined}`. Don't worry about the repetition, it will save you many frustrating debugging sessions. We all know how fun it is to debug shell scripts in production.

### Prefer configuring RabbitMQ via commands

This is most likely to stay consistent across versions. For example, 3.7 will have a new configuration file format. The old one will still work, but we want to promote the new one as much as possible.

Be aware of commands that take multiple arguments, such as `rabbitmq-plugins enable PLUGIN-A [PLUGIN-B...]`. They can speed things up considerably.

If a command fails, it will be more obvious what failed and should even hint how to fix the failure. The new configuration format in 3.7 will help things, for sure.
