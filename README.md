

# VSCodium [CDE](https://github.com/wav3m1nd3d/ade-spec/README.md#CDE "Containerized Development Environment" ) Compose

<p align=center>
	<picture>
  		<source media="(prefers-color-scheme: dark)" srcset="docs/images/cde-dark.svg">
  		<source media="(prefers-color-scheme: light)" srcset="docs/images/cde.svg">
  		<img alt="CDE Logo" src="docs/images/cde.svg" height="400">
	</picture>
</p>

<p align=center> <i>"Comfortable like sitting at home, but your home is actually modular and <b>HOOKED</b> to a helicopter"</i> <sub>anon.</sub></p>

# About

This [Abstracted Development Environment](https://github.com/wav3m1nd3d/ade-spec "ADE Specification") is based on containerization technology, thus this [CDE](https://github.com/wav3m1nd3d/ade-spec/README.md#CDE "Containerized Development Environment") is used to develop projects targeted to work on Linux based OS'es or in containerized environments; that implies low memory footprint and low performance overhead, immense portability potential among software and hardware, no dependency conflicts with host and easy on-demand environment update.

VSCodium and containers are connected through SSH, so can be run locally or in a remote location without giving up on development process seamlessness thanks to VSCodium baked-in remote functionality support and to [this extension](https://open-vsx.org/extension/jeanp413/open-remote-ssh "open-remote-ssh").


## Supported Variations

| Execution Previleges | Containerization Platform | Base Image | Configuration Options & Features | 
| --- | --- | --- | --- |
| rootless<br>rootful | Podman<br>Docker | [Debian & Debian-based](# "BASE_IMG_NAME, BASE_IMG_TAG") | [Bootstrap Functionality](# "Enables CDE pre-build configuration and script execution even on systems without dependencies installed: BOOT_CONT_USER, BOOT_CONT_USER_UID, BOOT_CONT_USER_GROUPS")<br>[User](# "CONT_USER"), [UID](# "CONT_USER_UID"), [User Groups](# "CONT_USER_GROUPS"), [Encrypted Passwords](# "Generates and reads user passwords in encrypted form: CONT_USERS_PASS_DIR")<br>[Shared Directories (Bind Mount)](# "HOST_PROJ_DIR, CONT_PROJ_DIR, CONT_CDE_DIR, HOST_CDE_DIR, CONT_USERNS_MODE")<br>Bridge Networking, [SSH Port](# "CONT_SSH_PORT"), [SSH Keypair](# "Generates and uses ssh keys for passwordless public key authentication: HOST_SSH_DIR, HOST_SSH_KEYPAIR_NAME"), [Local IP](# "CONT_IP")<br>[Additional Packages](# "CONT_PKGS"), VSCodium Extensions ([online](# "CONT_CODIUM_EXTS"), [local](# "HOST_CODIUM_EXTS_DIR"))<br>[Image Name](# "IMG_NAME"), [Image Tag](# "IMG_TAG"), [Labels](# "IMG_VER, IMG_DESC")<br> |

Refer to [documentation](https://github.com/wav3m1nd3d/vscodium-cde-compose/blob/main/docs/guide.md) to see what's available

# Requirements

* Internet connection to clone repo and build container image
* Linux / Mac / Windows (WSL2/Hyper-V)
* [`VSCodium`](https://vscodium.com) with [`Open Remote - SSH`](https://open-vsx.org/extension/jeanp413/open-remote-ssh) extension
* `OpenSSH` client (builtin in Windows, Mac)
* `podman` and `podman-compose` or `docker`

# Quick Start

## Dependencies Installation

0. Install [dependencies listed previously](#requirements), here are some official installation instructions and relevant information:
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

1. Clone this repository to your project directory or download a version under [releases](https://github.com/wav3m1nd3d/vscodium-cde-compose/releases) and unarchive it there, then navigate inside the newly created directory:

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

2. Configure environment by editing `.env` file, read more about it [here](https://github.com/wav3m1nd3d/vscodium-cde-compose/blob/main/docs/env.md)


3. One option is to run `cde-bootstrap` container service to configure user passwords and generate ssh keypair

	```sh
	podman-compose build cde-bootstrap
	podman-compose run cde-bootstrap
	```

	Or run scripts in current environment if _their dependencies_ are available

	```sh
	bash ./scripts/tools/generate_ssh_keypair.bash && \
	     ./scripts/tools/generate_user_passwords.bash
	```

	Or run them manually inside container
	```sh
	podman-compose build cde-bootstrap
	podman-compose run cde-bootstrap bash

	# ... [your_commands] ...

	./scripts/tools/generate_ssh_keypair.bash
	./scripts/tools/generate_user_passwords.bash
	```



4. Add new entry prompted in previous step to `~/.ssh/config` file, it should look like this but with your own values:
   ```
   Host <CONT_NAME>
      HostName <CONT_IP>
      Port <CONT_SSH_PORT>
      User <CONT_USER>
   ```

5. Add generated key to ssh on Linux/Mac/Windows
	```sh
	ssh-add secrets/ssh/<CONT_NAME>
	```

	_Remark to Linux and Mac users:_
	* If ssh-agent is not running:
		```sh
		eval $(ssh-agent -s)
		``` 

## Connect

6. Start `cde` container service
   ```sh
   podman-compose build cde
   podman-compose up -d cde
   ```

7. Connect to development environment using `open-remote-ssh` extension

![](https://raw.githubusercontent.com/wav3m1nd3d/vscodium-cde-compose/main/docs/images/open-remote-ssh-demonstration.gif)

# Other Useful Material

* [Guide](https://github.com/wav3m1nd3d/vscodium-cde-compose/blob/main/docs/guide.md)
* [Environment Variables](https://github.com/wav3m1nd3d/vscodium-cde-compose/blob/main/docs/env.md)
* [Troubleshooting](https://github.com/wav3m1nd3d/vscodium-cde-compose/blob/main/docs/troubleshooting.md)
