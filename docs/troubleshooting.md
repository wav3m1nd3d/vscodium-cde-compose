# Troubleshooting

1. Compose `up` and/or `run` errors out:
    * run `podman-compose down`, retry
2. Permission denied in container bind mounted directories (project directory):
	* set in `.env` file `CONT_USERNS_MODE=""` when `CONT_USER="root"` (not recommended for security reasons), if specified any other user `CONT_USERNS_MODE="keep-id"`, then rebuild service with `podman-compose build <container-service>`
3. No internet connection inside container (not recommended due to security reasons):
	* change in `docker-compose.yml` file under your service the `network: "none"` option to `network: "cde-net"`, then rebuild service with `podman-compose build <container-service>`
4. `CONT_USER_UID` and `CONT_USER_GID` are be ignored if `CONT_USER="root"`, select another user to use custom UID and GID


## Often overlooked details 

* `adduser -m` option is required for .bashrc to exist, warning for those who use `CONT_USER` different than root (as usually is)