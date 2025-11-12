---
title: "hexops-graveyard/dockerfile: Dockerfile best-practices for writing production-worthy Docker images."
source: "https://github.com/hexops-graveyard/dockerfile?tab=readme-ov-file"
author:
  - "[[GitHub]]"
published:
created: 2025-06-13
description: "Dockerfile best-practices for writing production-worthy Docker images. - hexops-graveyard/dockerfile"
tags:
  - "clippings"
---
**[dockerfile](https://github.com/hexops-graveyard/dockerfile)** Public

Dockerfile best-practices for writing production-worthy Docker images.

Unknown and 2 other licenses found

[Open in github.dev](https://github.dev/) [Open in a new github.dev tab](https://github.dev/) [Open in codespace](https://github.com/codespaces/new/hexops-graveyard/dockerfile?resume=1)

<table><thead><tr><th colspan="2"><span>Name</span></th><th colspan="1"><span>Name</span></th><th><p><span>Last commit message</span></p></th><th colspan="1"><p><span>Last commit date</span></p></th></tr></thead><tbody><tr><td colspan="3"><p><span><a href="https://github.com/hexops-graveyard/dockerfile/commit/aed47f5b4c7a923510e57019d3e4f0ee80006d78">github: add Sponsors</a></span></p><p><span><a href="https://github.com/hexops-graveyard/dockerfile/commit/aed47f5b4c7a923510e57019d3e4f0ee80006d78">aed47f5</a> ·</span></p><p><a href="https://github.com/hexops-graveyard/dockerfile/commits/main/"><span><span><span>26 Commits</span></span></span></a></p></td></tr><tr><td colspan="2"><p><a href="https://github.com/hexops-graveyard/dockerfile/tree/main/.github">.github</a></p></td><td colspan="1"><p><a href="https://github.com/hexops-graveyard/dockerfile/tree/main/.github">.github</a></p></td><td><p><a href="https://github.com/hexops-graveyard/dockerfile/commit/aed47f5b4c7a923510e57019d3e4f0ee80006d78">github: add Sponsors</a></p></td><td></td></tr><tr><td colspan="2"><p><a href="https://github.com/hexops-graveyard/dockerfile/blob/main/Dockerfile">Dockerfile</a></p></td><td colspan="1"><p><a href="https://github.com/hexops-graveyard/dockerfile/blob/main/Dockerfile">Dockerfile</a></p></td><td><p><a href="https://github.com/hexops-graveyard/dockerfile/commit/c40e4c587fb4863666a1318d97458f347d7bfc1c">adduser + addgroup: use long form of arguments (</a><a href="https://github.com/hexops-graveyard/dockerfile/pull/17">#17</a><a href="https://github.com/hexops-graveyard/dockerfile/commit/c40e4c587fb4863666a1318d97458f347d7bfc1c">)</a></p></td><td></td></tr><tr><td colspan="2"><p><a href="https://github.com/hexops-graveyard/dockerfile/blob/main/LICENSE">LICENSE</a></p></td><td colspan="1"><p><a href="https://github.com/hexops-graveyard/dockerfile/blob/main/LICENSE">LICENSE</a></p></td><td><p><a href="https://github.com/hexops-graveyard/dockerfile/commit/5fb2f6a5be433ed8fde3aa828952ae18e5e9d2a6">Dual license under Apache and MIT</a></p></td><td></td></tr><tr><td colspan="2"><p><a href="https://github.com/hexops-graveyard/dockerfile/blob/main/LICENSE-APACHE">LICENSE-APACHE</a></p></td><td colspan="1"><p><a href="https://github.com/hexops-graveyard/dockerfile/blob/main/LICENSE-APACHE">LICENSE-APACHE</a></p></td><td><p><a href="https://github.com/hexops-graveyard/dockerfile/commit/5fb2f6a5be433ed8fde3aa828952ae18e5e9d2a6">Dual license under Apache and MIT</a></p></td><td></td></tr><tr><td colspan="2"><p><a href="https://github.com/hexops-graveyard/dockerfile/blob/main/LICENSE-MIT">LICENSE-MIT</a></p></td><td colspan="1"><p><a href="https://github.com/hexops-graveyard/dockerfile/blob/main/LICENSE-MIT">LICENSE-MIT</a></p></td><td><p><a href="https://github.com/hexops-graveyard/dockerfile/commit/5fb2f6a5be433ed8fde3aa828952ae18e5e9d2a6">Dual license under Apache and MIT</a></p></td><td></td></tr><tr><td colspan="2"><p><a href="https://github.com/hexops-graveyard/dockerfile/blob/main/README.md">README.md</a></p></td><td colspan="1"><p><a href="https://github.com/hexops-graveyard/dockerfile/blob/main/README.md">README.md</a></p></td><td><p><a href="https://github.com/hexops-graveyard/dockerfile/commit/0626293c22b89b87e44977b87a78f6630650b794">Fix a numbering typo in the README (</a><a href="https://github.com/hexops-graveyard/dockerfile/pull/18">#18</a><a href="https://github.com/hexops-graveyard/dockerfile/commit/0626293c22b89b87e44977b87a78f6630650b794">)</a></p></td><td></td></tr><tr><td colspan="3"></td></tr></tbody></table>

Writing production-worthy Dockerfiles is, unfortunately, not as simple as you would imagine. Most Docker images in the wild fail here, and even professionals often [\[1\]](https://github.com/docker-library/postgres/issues/175) get [\[2\]](https://github.com/prometheus/prometheus/issues/3441) this [\[3\]](https://github.com/caddyserver/caddy-docker/issues/104) wrong [\[4\]](https://github.com/docker-library/postgres/issues/796).

This repository has best-practices for writing Dockerfiles that I (@slimsag) have quite painfully learned over the years both from my personal projects and from my work @sourcegraph. This is all guidance, not a mandate - there may sometimes be reasons to not do what is described here, but if you *don't know* then this is probably what you should be doing.

Copy [the Dockerfile](https://github.com/hexops/dockerfile/blob/main/Dockerfile) into your own project and follow the comments to create *your* Dockerfile.

The following are included in the Dockerfile in this repository:

- [Run as a non-root user](https://github.com/hexops-graveyard/?tab=readme-ov-file#run-as-a-non-root-user)
- [Do not use a UID below 10,000](https://github.com/hexops-graveyard/?tab=readme-ov-file#do-not-use-a-uid-below-10000)
- [Use a static UID and GID](https://github.com/hexops-graveyard/?tab=readme-ov-file#use-a-static-uid-and-gid)
- [Do not use `latest`, pin your image tags](https://github.com/hexops-graveyard/?tab=readme-ov-file#do-not-use-latest-pin-your-image-tags)
- [Use `tini` as your ENTRYPOINT](https://github.com/hexops-graveyard/?tab=readme-ov-file#use-tini-as-your-entrypoint)
- [Only store arguments in `CMD`](https://github.com/hexops-graveyard/?tab=readme-ov-file#only-store-arguments-in-cmd)
- [Install bind-tools if you care about DNS resolution on some older Docker versions](https://github.com/hexops-graveyard/?tab=readme-ov-file#install-bind-tools-if-you-care-about-dns-resolution-on-some-older-docker-versions)

Running containers as a non-root user substantially decreases the risk that container -> host privilege escalation could occur. This is an added security benefit. ([Docker docs](https://docs.docker.com/engine/security/#linux-kernel-capabilities), [Bitnami blog post](https://engineering.bitnami.com/articles/why-non-root-containers-are-important-for-security.html))

UIDs below 10,000 are a security risk on several systems, because if someone does manage to escalate privileges outside the Docker container their Docker container UID may overlap with a more privileged system user's UID granting them additional permissions. For best security, always run your processes as a UID above 10,000.

Eventually someone dealing with your container will need to manipulate file permissions for files owned by your container. If your container does not have a static UID/GID, then one must extract this information from the running container before they can assign correct file permissions on the host machine. It is best that you use a single static UID/GID for all of your containers that never changes. We suggest `10000:10001` such that `chown 10000:10001 files/` always works for containers following these best practices.

We suggest pinning image tags using a specific image `version` using `major.minor`, not `major.minor.patch` so as to ensure you are always:

1. Keeping your builds working (`latest` means your build can arbitrarily break in the future, whereas `major.minor` *should* mean this doesn't happen)
2. Getting the latest security updates included in new images you build.

SHA pinning gives you completely reliable and reproducable builds, but it also likely means you won't have any obvious way to pull in important security fixes from the base images you use. If you use `major.minor` tags, you get security fixes by accident when you build new versions of your image - at the cost of builds being less reproducable.

**Consider using [docker-lock](https://github.com/safe-waters/docker-lock)**: this tool keeps track of exactly which Docker image SHA you are using for builds, while having the actual image you use still be a `major.minor` version. This allows you to reproduce your builds as if you'd used SHA pinning, while getting important security updates when they are released as if you'd used `major.minor` versions.

If you're a large company/organization willing to spin up infrastructure like image security scanners, automated dependency updating, etc. then [consider this approach](https://github.com/hexops-graveyard/?tab=readme-ov-file#should-i-really-use-majorminor-over-sha-pinning) as well.

We suggest using [tini](https://github.com/krallin/tini) as the ENTRYPOINT in your Dockerfile, even if you think your application handles signals correctly. This can alter the stability of the host system and other containers running on it, if you get it wrong in your application. See the [tini docs](https://github.com/krallin/tini) for details and benefits:

> Using Tini has several benefits:
> 
> - It protects you from software that accidentally creates zombie processes, which can (over time!) starve your entire system for PIDs (and make it unusable).
> - It ensures that the default signal handlers work for the software you run in your Docker image. For example, with Tini, SIGTERM properly terminates your process even if you didn't explicitly install a signal handler for it.
> - It does so completely transparently! Docker images that work without Tini will work with Tini without any changes.

By having your `ENTRYPOINT` be your command name:

```
ENTRYPOINT ["/sbin/tini", "--", "myapp"]
```

And `CMD` be only arguments for your command:

```
CMD ["--foo", "1", "--bar=2"]
```

It allows people to ergonomically pass arguments to your binary without having to guess its name, e.g. they can write:

```
docker run yourimage --help
```

If `CMD` includes the binary name, then they must guess what your binary name is in order to pass arguments etc.

If you want your Dockerfile to run on old/legacy Linux systems and Docker for Mac versions and wish to avoid DNS resolution issues, install bind-tools.

For additional details [see here](https://github.com/sourcegraph/godockerize/commit/5cf4e6d81720f2551e6a7b2b18c63d1460bbbe4e#commitcomment-45061472).

(Applies to Alpine Linux base images only)

## FAQ

- [Is `tini` still required in 2020? I thought Docker added it natively?](https://github.com/hexops-graveyard/?tab=readme-ov-file#is-tini-still-required-in-2020-i-thought-docker-added-it-natively)
- [Should I really use major.minor over SHA pinning?](https://github.com/hexops-graveyard/?tab=readme-ov-file#should-i-really-use-major-minor-over-sha-pinning)

Unfortunately, although Docker did add it natively, [it is optional](https://github.com/krallin/tini#using-tini) (you have to pass `--init` to the `docker run` command). Additionally, because it is a feature of the runtime and e.g. Kubernetes will not use the Docker runtime but rather a different container runtime [it is not always the default](https://stackoverflow.com/questions/50803268/kubernetes-equivalent-of-docker-run-init/50819443#50819443) so it is best if your image provides a valid entrypoint like `tini` instead.

It depends. We advise `major.minor` pinning here because we believe it is the most likely thing that the average developer creating a new Docker image can effectively manage day-to-day that provides the most security. If you're a larger company/organization, you might consider instead however:

- Using one of the many tools for automated image vulnerability scanning, such as [GCR Vulnerability Scanning](https://cloud.google.com/container-analysis/docs/vulnerability-scanning) so you know *when your images have vulnerabilities*.
- Using SHA pinning so you know your images will not change without your approval.
- Using automated image tag update software, [such as Renovate](https://docs.renovatebot.com/docker/) to update your image tags and get notified.
- An extensive review process to ensure you don't accept untrustworthy image tag updates.

However, this obviously requires much more work and infrastructure so we don't advise it here with the expectation that *most* people would pin a SHA and likely never update it again - thus never getting security fixes into their images.

## Sponsor this project

## Languages

- [Dockerfile 100.0%](https://github.com/hexops-graveyard/dockerfile/search?l=dockerfile)