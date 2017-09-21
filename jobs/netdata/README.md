This is an atypical BOSH job.
It pulls down a script from my-netdata.io which installs a statically linked, 64bit Linux binary.
netdata will be installed in /opt/netdata, and supervised via /etc/systemd if available, otherwise /etc/init.d.

I hear your BOSH screams: WHY????

System metrics should always be up and available, regardless what BOSH is doing.
I mean, system logging via rsyslog is always up, so why not system metrics?

I know, running scripts downloaded from the internetz is a bad thing.
So what do we do if it happens to be the easiest thing?
We choose bad and easy over correct and hard.
It's all about learning, and only adding layers of complexity when they prove necessary, not a moment earlier.

Kaizen.
