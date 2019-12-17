# SpigotMC Minecraft Server
--- 

## About this image

This Docker image allows you to create a Spigot server quickly and easily. It was inspired by the `dlord/spigot` Docker image but uses a minimal base image, specifically `azul/zulu-openjdk-alpine:8`.

The first run of this instance will download the Spigot BuildTools.jar and compile the server from source. This is done this way because pre-building the server would violate Minecraft's EULA. 

## Starting an instance

```
docker run \
    --name spigot-instance \
    -p 0.0.0.0:25565:25565 \
    -d -it \
    -e DEFAULT_OP=KowboyMac \
    -e MINECRAFT_EULA=true \
    cpmcdaniel/spigot
```

By default, this starts up a Spigot 1.15 server instance. To start a different server version, you can use the `MINECRAFT_VERSION` variable. 

There are two variables that must be set on startup - `DEFAULT_OP` and `MINECRAFT_EULA`. The `DEFAULT_OP` variable should be set to the Minecraft account username of the server's primary administrator. The `MINECRAFT_EULA` variable must be set to `true` to indicate that you are agreeing to Minecraft's EULA. Without either of these variables, the server will not start.

This image exposes the standard Minecraft port (25565). 

It is strongly recommended to start the container with `-it`. This will enable the execution of Spigot console commands via `docker exec` and also allows safe shutdown via `docker stop`. 

## Commands

This image uses an entrypoint script called `spigot`, which has several preset commands. If it does not recognize the command, it will be treated as a regular shell command. These preset commands are:

* `run` - Runs the Spigot server and is the default command for the container. Additional parameters are passed through to the Spigot server. See the [Spigot documentation](https://www.spigotmc.org/wiki/start-up-parameters/) for those additional parameters. 
* `permissions` - Resets ownership of the Spigot files and directories. May be necessary after manually editing certain files or creating new ones. Probably not necessary during normal operation.
* `console` - This executes a console command in the Minecraft server (as administrator). This command enables most adminstrative tasks without the need to use `docker attach`. See the [Spigot server documentation](https://www.spigotmc.org/wiki/spigot-commands/) for more details.

### Examples

#### run - with extra args to specify a different config inside /opt/minecraft

```
docker run \
    --name spigot-instance \
    -p 0.0.0.0:25565:25565 \
    -d -it \
    -e DEFAULT_OP=KowboyMac \
    -e MINECRAFT_EULA=true \
    cpmcdaniel/spigot
    run --spigot-settings spigot-test.yaml
```

#### permissions - update file and directory permissions while container is running

```
docker exec spigot-instance spigot permissions
```

#### console - say hi to everyone on the server

```
docker exec spigot-instance spigot console say Hello, World!
```

## Data Volumes

There are two data volumes declared for this image. The `spigot` script will ensure proper ownership of these files on startup, so you may freely modify files in these data volumes outside of the container without having to fool with permissions. If you need to make changes (more likely, new files) while the container is running, you can use the `permissions` command through `docker exec` on the running instance (see the example above). 

The data volumes are:
* `/opt/minecraft` - Server-related artifacts (jar files, configs, etc). 
* `/var/lib/minecraft` - World data. This has been separated from the server artifacts purely for backup convenience. 

Example using local data volumes on the docker host:

```shell
$ docker volume create minecraft
$ docker volume create minecraft-worlds
$ docker run \
    --name spigot-instance \
    -p 0.0.0.0:25565:25565 \
    -d -it \
    -e DEFAULT_OP=KowboyMac \
    -e MINECRAFT_EULA=true \
    --mount source=minecraft,target=/opt/minecraft \
    --mount source=minecraft-worlds,target=/var/lib/minecraft \
    cpmcdaniel/spigot
```

## Environment Variables

There are additional environment variables that can be used to customize the server beyond the require `MINECRAFT_EULA` and `DEFAULT_OP` mentioned previously (and the optional `MINECRAFT_VERSION`, also mentioned).

### MINECRAFT_OPTS

JVM arguments. This actually overrides the default JVM args. The default for this can be found in the source for the [spigot](spigot) file.

### server.properties variables

The initial values for entries in the Spigot [server.properties](https://www.spigotmc.org/wiki/spigot-configuration-server-properties/) file can be changed from their defaults. For a comprehensive list, see the source for the [spigot](spigot) file. Here are some that you are most likely to want to customize:

* MOTD
* LEVEL_NAME
* SERVER_PORT
* LEVEL_TYPE
* LEVEL_SEED
* DIFFICULTY
* GAMEMODE
* PLAYER_IDLE_TIMEOUT
* MAX_PLAYERS
* VIEW_DISTANCE

## Warnings

The console feature of this image should provide for most of the administrative needs for the server. However, should you decide to `docker attach` to the instance, care should be taken to detach properly. When attaching to the instance, you are actually attaching to a `tmux` session running in the foreground with the footer disabled. You would normally detach from a `tmux` session via `CTRL-b d`. However, this will stop the container. Instead, be sure to use `CTRL-p CTRL-q`, which is the standard way to detach from `docker attach`.
