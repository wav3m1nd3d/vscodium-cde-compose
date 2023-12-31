# VSCodium [CDE](https://github.com/wav3m1nd3d/ade-spec/README.md#CDE "Containerized Development Environment" ) Compose

<div align=center>
	<picture>
  		<source media="(prefers-color-scheme: dark)" srcset="docs/images/cde-dark-mini.svg">
  		<source media="(prefers-color-scheme: light)" srcset="docs/images/cde-mini.svg">
  		<img alt="CDE Logo" src="docs/images/cde-mini.svg" height="150">
	</picture>
</div>
<p align=center>
	<i>"Comfortable like sitting at home, but your home is actually modular and <b>HOOKED</b> to a helicopter"</i> <sub>anon.</sub>
</p>

# About

This project is an [_Abstracted Development Environment_](https://github.com/wav3m1nd3d/ade-spec "ADE Specification") that utilizes containerization technology as abstraction layer, thus called for short a [_CDE_](https://github.com/wav3m1nd3d/ade-spec/README.md#CDE "Containerized Development Environment"), that integrates seamlessly with VSCodium IDE using one of the industry de-facto-standard [compose specification](https://compose-spec.io/) compliant software like _**Docker**_ or _**Podman**_ to _**reduce to a minimum time spent on setting up projects**_ on developers machine, and letting possible _**cross-platform development with minimal amount of dependencies**_ required to be installed on host.


## What can it do?

Put simply: projects using this CDE let you develop seamlessly on multiple platforms like _**Windows, Mac, Linux**_ and reduce all _**setup process**_ to a constant minimum required amount of work that ususally trickles down to _**running a single command**_.

There should be _**little to no maintainance and entry costs**_: it's as easy as _**adding a subtree**_ with `git subtree add` and performing sometimes `git subtree pull` to upstream your CDE or _**using a GitHub Template**_ containing a template project with already seamlessly working software stack with sane choices and defaults (for now only Python).

Afterall, the main advantageous characteristic is that this CDE can be adapted to _**your own software stack**_, even choosing _**programming language**_ and drop-in your _**custom setup and configuration scripts**_ to shape perfectly your workflow of choice.

<details open>
<summary>
	<h2>Variations</h2>
</summary>

The following software configurations are available for this CDE:

| Host Operaring System | Execution Previleges | Containerization Platform |
| --- | --- | --- |
| Linux<br>Mac<br>Windows<br> | rootless<br>rootful<br> | Podman<br>Docker<br> |

<br>

| Base Image | Features & Configuration Options|
| --- | --- |
| [Debian & Debian-based](# "BASE_IMG_NAME, BASE_IMG_TAG") | <ul style="list-style: ;"><li>[Cross-Platform Setup Script](# "Single command to setup everything on multiple platforms")</li><li>[Bootstrap Functionality](# "Enables CDE pre-build configuration and script execution even on systems without dependencies installed: BOOT_CONT_USER, BOOT_CONT_USER_UID, BOOT_CONT_USER_GROUPS")</li><li>[User](# "CONT_USER"), [UID](# "CONT_USER_UID"), [User Groups](# "CONT_USER_GROUPS"), [Encrypted Passwords](# "Generates and reads user passwords in encrypted form: CONT_USERS_PASS_DIR")<br>[Shared Directories (Bind Mount)](# "HOST_PROJ_DIR, CONT_PROJ_DIR, CONT_CDE_DIR, HOST_CDE_DIR, CONT_USERNS_MODE")</li><li>Bridge Networking, [SSH Port](# "CONT_SSH_PORT"), [SSH Keypair](# "Generates and uses ssh keys for passwordless public key authentication: HOST_SSH_DIR, HOST_SSH_KEYPAIR_NAME"), [Local IP](# "CONT_IP")</li><li>[Additional Packages](# "CONT_PKGS"), VSCodium Extensions ([online](# "CONT_CODIUM_EXTS"), [local](# "HOST_CODIUM_EXTS_DIR"))</li><li>[Image Name](# "IMG_NAME"), [Image Tag](# "IMG_TAG"), [Labels](# "IMG_VER, IMG_DESC")</li></ul> |
</details>
</details>

Refer to [documentation](docs/guide.md) to see what's available

# Requirements

* Internet connection to clone repo and build container image
* Linux / Mac / Windows (WSL2)
* [`VSCodium`](https://vscodium.com) with [`Open Remote - SSH`](https://open-vsx.org/extension/jeanp413/open-remote-ssh) extension
* `OpenSSH` client (builtin in Windows WSL2, Mac)
* `bash` (builtin in Windows WSL2, Mac, almost any Linux distribution)
* `podman` and `podman-compose` or `docker`

# Quick Start

## Dependencies Installation

Install [dependencies listed previously](#requirements), here are some official installation instructions and relevant information:
* Containerization
	* [Podman](https://podman.io/docs/installation)
	* [podman-compose](https://github.com/containers/podman-compose#installation)
	* [Podman Desktop](https://podman-desktop.io/downloads)
	* [Docker](https://docs.docker.com/engine/install)
	* [Docker Desktop](https://docs.docker.com/desktop/install/linux-install)
* IDE
	* [VSCodium](https://vscodium.com/#install)
	* [Open Remote - SSH (Extension)](https://open-vsx.org/extension/jeanp413/open-remote-ssh#ssh-host-requirements#) 
		* [\[VSCode Extension Installation\]](https://code.visualstudio.com/learn/get-started/extensions)
	
_Remark to Linux users:_

It's worth checking your distribution repository with your package manager for required packages ignoring official documentation: 
* `openssh-client` or `openssh` widely available among distribution repositories, just search for `ssh` and then install the right one
* `podman-compose` is available in Debian, while not mentioned in documentation


## Download

Clone this repository to your project directory or download a version under [releases](https://github.com/wav3m1nd3d/vscodium-cde-compose/releases) and unarchive it there, then navigate inside the newly created directory:

```sh
cd <my-project>
git clone https://github.com/wav3m1nd3d/vscodium-cde-compose.git
cd vscodium-cde-compose
```

or

```sh
cd <my-project>
wget -qO- https://github.com/wav3m1nd3d/vscodium-cde-compose/releases/vscodium-cde-compose_<version>.zip | unzip -
cd vscodium-cde-compose
```


## Configure

Configure environment by editing `.env` file, read more about it [here](docs/env.md)


## Setup

Run the following script to bootstrap and build CDE:

```sh
./scripts/setup/setup.bash
```


## Start

Start CDE (add `-d` option to spin up in background)
```sh
podman-compose up cde
```


## Connect

Connect to development environment using `open-remote-ssh` extension

![](https://raw.githubusercontent.com/wav3m1nd3d/vscodium-cde-compose/main/docs/images/open-remote-ssh-demonstration.gif)

## Stop

Stop CDE
```sh
podman-compose down cde
```


# Other Useful Material

* [Guide](docs/guide.md)
* [Environment Variables](docs/env.md)
* [Troubleshooting](docs/troubleshooting.md)
