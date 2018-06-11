# Singularity-Util

A [Docker](https://github.com/docker/docker) based container that acts as a multi-purpose wrapper for [Singularity](https://github.com/singularityware/singularity). It is ideal for integrating into Docker centric build systems or for
use platforms (OSX/Windows) where Singularity cannot be directly installed.

---

## Usage

The `singularity-util` container will accept the majority of Singularity commands with the caveat that all paths
**MUST** be relative to the `/target` directory within the container. `/target` acts as the current working directory
for all the Singularity based commands.


```bash
docker pull arcts/singularity-util
docker run --rm --privileged -v $(pwd):/target:rw arcts/singularity-util <command> <args>
```


Supported Singularity commands include `bootstrap`, `copy`, `create`, `expand`, `exec`, `export`, `import`, `run`, 
`shell`, and `test`. For the Singularity specific usage commands, please see their 
[command reference documentation](http://singularity.lbl.gov/docs-usage).

Non-Singularity commands include `build` and `debug`.
* `build` accepts `rpm`, `deb` or nothing for both as parameters and will build packages via the provided packaging
  system, then drop them in the `/target` directory.
* `debug` Executes an arbitrary command within the `singularity-util` container and is useful for troubleshooting. 
  To drop to a bash shell simply execute: `debug bash`.

## Examples:

**Building Packages**

```bash
$ docker run --rm -v $(pwd):/target arcts/singularity-util build deb
   ...
$ ls *.rpm
  singularity-2.2-0.1.x86_64.rpm		singularity-devel-2.2-0.1.x86_64.rpm
```

**Building a CentOS 6 Singularity Container**

```bash
$ docker run --rm --privileged -v $(pwd):/target arcts/singularity-util create centos6.img
  Creating a new image with a maximum size of 768MiB...
  Executing image create helper
  Formatting image with ext3 file system
  Done
$ docker run --rm --privileged -v $(pwd):/target arcts/singularity-util import centos6.img docker://centos:6
  library/centos:6
  Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
  Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
  Downloading layer: sha256:32c4f4fef1c65e47e41704aabeb99e984f1c01e3541e48354b09300fa5b2d068
  Downloading layer: sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
  Adding Docker CMD as Singularity runscript...
  Bootstrap initialization
  No bootstrap definition passed, updating container
  Executing Prebootstrap module
  Executing Postbootstrap module
  Done.
$ docker run -it --rm --privileged -v $(pwd):/target arcts/singularity-util exec centos6.img cat /etc/system-release
  CentOS release 6.8 (Final)
```

**Expanding an Image**
```bash
$ docker run --rm --privileged -v $(pwd):/target arcts/singularity-util expand --size 512 centos6.img
  Expanding existing image with a size of 512MiB...
  Executing image expand helper
  Checking image (/sbin/mkfs.ext3)
  e2fsck 1.42.13 (17-May-2015)
  Growing file system
  resize2fs 1.42.13 (17-May-2015)
  Done.
```

## Building Alternate Versions
Alternate versions of Singularity can be baked into the `singularity-util` container by supplying the Docker build
argument `SINGULARITY_VERSION`. This should correlate to a git tag, branch or commit id within the
[Singularity Github repo](https://github.com/singularityware/singularity). This build argument will update the image
label `Singularity.Version`.
