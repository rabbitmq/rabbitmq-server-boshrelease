Thank you for using RabbitMQ with BOSH and for taking the time to contribute to the project.
This document has two main parts:

 * when and how to file GitHub issues for RabbitMQ projects
 * how to submit pull requests

They intend to save you and RabbitMQ maintainers some time, so please
take a moment to read through them.

## Overview

### GitHub issues

The RabbitMQ team uses GitHub issues for _specific actionable items_ that
engineers can work on. This assumes the following:

* GitHub issues are not used for questions, investigations, root cause
  analysis, discussions of potential issues, etc (as defined by this team)
* Enough information is provided by the reporter for maintainers to work with

The team receives many questions through various venues every single
day. Frequently, these questions do not include the necessary details
the team needs to begin useful work. GitHub issues can very quickly
turn into a something impossible to navigate and make sense
of. Because of this, questions, investigations, root cause analysis,
and discussions of potential features are all considered to be
[mailing list][rmq-users] material. If you are unsure where to begin,
the [RabbitMQ users mailing list][rmq-users] is the right place.

### Pull Requests

RabbitMQ projects use pull requests to discuss, collaborate on and accept code contributions.
Pull requests is the primary place of discussing code changes.

Here's the recommended workflow:

* [Fork the repository][github-fork]
* Create a branch with a descriptive name
* Make your changes, test them by confirming that a `bosh deploy` & `bosh delete-deployment` succeed, commit with a [descriptive message][git-commit-msgs], push to your fork
* Submit pull requests with an explanation what has been changed and **why**
* Submit a filled out and signed [Contributor Agreement][ca-agreement] if needed (see below)
* Be patient. We will get to your pull request eventually

If what you are going to work on is a substantial change, please first
ask the core team for their opinion on the [RabbitMQ users mailing list][rmq-users].

## Code of Conduct

See [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md).

## Contributor Agreement

If you want to contribute a non-trivial change, please submit a signed
copy of our [Contributor Agreement][ca-agreement] around the time you
submit your pull request. This will make it much easier (in some
cases, possible) for the RabbitMQ team at Pivotal to merge your
contribution.

## Where to Ask Questions

If something isn't clear, feel free to ask on our [mailing list][rmq-users].

[git-commit-msgs]: https://chris.beams.io/posts/git-commit/
[rmq-users]: https://groups.google.com/forum/#!forum/rabbitmq-users
[ca-agreement]: https://cla.pivotal.io/sign/rabbitmq
[github-fork]: https://help.github.com/articles/fork-a-repo/
