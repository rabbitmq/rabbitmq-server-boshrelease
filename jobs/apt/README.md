You should co-locate this job when you want to:

* Fix `apt update` on Ubuntu Xenial stemcells
* Remove expired apt signing keys
* Install packages with apt (ships with decent sysadmin-centric utilities)
* Install kernel-specific packages, such as `linux-tools-KERNEL_VERSION` &amp; [perf](http://www.brendangregg.com/perf.html)

Co-locating this job implies that the stemcell is Debian-based, Ubuntu Xenial
ideally, but it is likely to work with other Debian-based stemcell - Your
Mileage May Vary.

Even though this job goes against everything that BOSH stands for, we needed a
quick and easy - albeit wrong - solution to the above issues with Ubuntu Xenial
stemcells on GCP.  For more context, see
[cloudfoundry/bosh-linux-stemcell-builder#39](https://github.com/cloudfoundry/bosh-linux-stemcell-builder/issues/39#issuecomment-418136627)
&amp;
[emalm/tmux-boshrelease#3](https://github.com/emalm/tmux-boshrelease/issues/3).
