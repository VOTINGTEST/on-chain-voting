# PowerVoting Backend Compilation Guide

#### 1. Install Go Toolchain

First, ensure you have the Go toolchain installed. You can find installation instructions [here](https://go.dev/doc/install). Make sure you have Go version >= 1.20.

#### 2. Install Docker

Install Docker by following the instructions for your operating system [here](https://docs.docker.com/engine/install/).

#### 3. Install MySQL Server

Install the MySQL server Docker image by running the following command:

```
docker pull mysql/mysql-server
```

#### 4. Clone the PowerVoting Backend Repository

Clone the PowerVoting backend repository with the repository branch set to `main`:

```
git clone https://github.com/filecoin-project/on-chain-voting.git
```

#### 5. Obtain your proofs to upload w3storage

Install w3 cli and generate your did,create a space,delegate capabilities to your did,save the generated ucan file above.

```
npm install -g @web3-storage/w3cli

w3 key create

w3 space create [NAME]

w3 delegation create -c 'store/*' -c 'upload/*' [DID] -o proof.ucan
```

#### 6. Modify the Configuration File

Edit the `configuration.yaml` file as needed for your environment.

![Edit Configuration](img/1.png)

#### 7. Build the Project

Run the shell script to build project:

```
sh build.sh
```

<img src="img/2.png" width="50%" />

#### 8. View Logs

To monitor the logs of the running container, you can use the Docker logs command:

```
docker logs <container_id>
```

<img src="img/4.png" width="50%" />

By following these steps, you will successfully compile, build, and run the PowerVoting backend using Docker.
