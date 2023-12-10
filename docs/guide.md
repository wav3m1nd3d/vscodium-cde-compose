# Introduction

# Principle of Operation

In subsequent explaination `podman` and `podman-compose` are used, but one can substitute them with `docker` and `docker compose` as a drop-in replacement in terms of usage.

The main idea behind the initialization of a CDE service is the bootstrapping functionality that can configure the newly downloaded CDE in any environment with the only requirement of a correctly functioning containerization platform.

`cde-bootstrap` is a service in the stack declared in `compose.yml` that [_usually_](#cde-bootstrap-optionality) gets built and run before others to execute some configuration scripts usually located in `scripts/tools`.

```yml
version: '3'

services:

	cde-bootstrap:
		env-file: ".env"
		build:
			# ...
			context: ./
      		dockerfile: "$HOST_DOCKERFILES_DIR/vscde-bootstrap" 
				# HOST_DOCKERFILES_DIR="dockerfiles" in .env
			# ...
	  
	cde:
		# ...

	cde-deploy:
		# ...

# ...

```

In this concrete case it performs two duties:

1. Generate an ssh keypair in `secrets/ssh/` for public-key authentication between VSCodium client and container

2. Generate encrypted strings with user passwords in `secrets/users/` to store them safely without need to re-input passwords every rebuild of a `cde` or `cde-deploy`

They can be seen in the Dockerfile `dockerfiles/vscde-bootstrap` that contains the "recipe" to build `cde-deploy`

```Dockerfile
# ...
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["$CDE_HOST_SCRIPTS_DIR/tools/generate_ssh_keypair.bash && $CDE_HOST_SCRIPTS_DIR/tools/generate_user_passwords.bash"]
# ...
```

To understand better the usage of files during build and execution here is a diagram:

```
			   ┌─ dockerfiles/vscde-bootstrap ─┬─ scripts/container/ ... 
			   │                               └─ scripts/tools/ ...
			   │
  compose.yml ─┼─ dockerfiles/vscde-default ───── scripts/container/ ...
			   │                              
			   └─ dockerfiles/vscde-deploy ────── scripts/container/ ...
```

`scripts/container/*` scripts are required to build containers, so they perform duties like:

1. Package installation
2. User creation
3. Directory creation with right ownership and ACLs
4. Conditional configuration files copy with optional string substitution


### `cde-bootstrap` Optionality

By the way, bootstrapping process can be executed baremetal on systems that already have installed required dependencies, but for now there is no sure way to know how the script will behave on missing dependency, this feature will be added in future with bash library called `libbsrc`.


## Environment Variables

Environment variables are used to present a user and/or a developer with a quick and clean way to interact with CDE and tweak its behaviour that will apply to all services at the same time using already existing widespread format specifications like [`compose`](https://compose-spec.github.io/compose-spec/spec.html "Compose Specification") and [`Dockerfile`](https://docs.docker.com/engine/reference/builder/ "Dockerfile Refrence").
 
Variables get forwarded from `.env` to `compose.yml`, partially used there, partially forwarded to Dockerfiles in `dockerfiles/` and from there used in conjunction with `ARG` to read them, with `ENV` to export them inside container shell environment and with `RUN` to use them inside commands and build-time scripts located under `scripts/container/`.

Documentation for what variables are available, their usage, function and tips on using them correctly can be seen [here](https://github.com/wav3m1nd3d/vscodium-cde-compose/main/docs/env.md).

Variable forwarding mechanism is linear, but taking into account the directory structure, `compose.yml` and `Dockerfile` argument passing method overlapping redundancy, can lead to human errors during CDE development and tweaking, so better automatization is clearly required: it's planned to release a standalone project to help with that by generating variable lists directly-insertable inside undelying files and displaying what variables are missing to be forwarded.