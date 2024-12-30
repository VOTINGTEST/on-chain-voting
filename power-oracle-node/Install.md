# Oracle Node Compilation Guide

#### 1. Install Go Toolchain

First, you need to install the Go toolchain. You can find [installation instructions](https://go.dev/doc/install) here. Ensure that you install Go version >= 1.20.

#### 2. Install Docker

Next, install Docker by following the instructions for your operating system [here](https://docs.docker.com/engine/install/).

#### 3. Clone the Oracle Node Repository

Clone the Oracle node repository and navigate to the backend directory:

```
https://github.com/filecoin-project/on-chain-voting.git
cd power-oracle-node/backend
```

#### 4. Modify the Configuration File

Edit the `configuration.yaml` file as needed for your environment.

![Edit Configuration](img/1.png)

#### 5. Build the Docker Image

Build the Docker image for the Oracle node:

```
sh build.sh
```

<img src="img/2.png" width="50%" />

#### 6. View Logs

To monitor the logs of the running container, use the following command, replacing the container ID with the ID of your running container:

```
docker logs -f <container_id>
```

For example:

```
docker logs -f 624d96fdb89b
```

<img src="img/4.png" width="50%" />

By following these steps, you will successfully compile, build, and run the Oracle node using Docker.
