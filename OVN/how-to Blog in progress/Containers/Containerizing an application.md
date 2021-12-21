# Containerizing an application

## Container Image

This can be explored via Docker. Pull the layers onto your local system.

docker pull redis:3.2.11-alpine

Export the image into the raw tar format.

docker save redis:3.2.11-alpine > redis.tar

Extract to the disk

tar -xvf redis.tar

All of the layer tar files are now viewable.

ls

The image also includes metadata about the image, such as version information and tag names.

cat repositories

cat manifest.json

Extracting a layer will show you which files that layer provides.

tar -xvf da2a73e79c2ccb87834d7ce3e43d274a750177fe6527ea3f8492d08d3bb0123c/layer.tar


## Docker(Container) Images

Container image contains everything required to run your application, from operating system to dependencies and configuration. Having everything within the image allows you to migrate images between different environments.

A container image is just a tar file containing tar files. Each tar file is a layer. Once all tar files have been extract into the same location then you have the container's filesystem.

We can see it in the following example:

```bash
$ docker save redis:3.2.11-alpine > redis.tar

$ tar -xvf redis.tar

$ ls
46a2fed8167f5d523f9a9c07f17a7cd151412fed437272b517ee4e46587e5557
498654318d0999ce36c7b90901ed8bd8cb63d86837cb101ea1ec9bb092f44e59
ad01e7adb4e23f63a0a1a1d258c165d852768fb2e4cc2d9d5e71698e9672093c
ca0b6709748d024a67c502558ea88dc8a1f8a858d380f5ddafa1504126a3b018.json
da2a73e79c2ccb87834d7ce3e43d274a750177fe6527ea3f8492d08d3bb0123c
db1a23fc1daa8135a1c6c695f7b416a0ac0eb1d8ca873928385a3edaba6ac9a3
f07352aa34c241692cae1ce60ade187857d0bffa3a31390867038d46b1e7739c
manifest.json
redis.tar
repositories

$ ls 46a2fed8167f5d523f9a9c07f17a7cd151412fed437272b517ee4e46587e5557/
json  layer.tar  VERSION
```

Docker images are built based on a Dockerfile. A Dockerfile defines all the steps required to create and configured application to run as a container. The Dockerfile allows for images to be composable, enabling users to extend existing images instead of building from scratch. By building on an existing image, you only need to define the steps to setup your application on the base image. The base images can be basic operating system installations or configured systems which simply need some additional customisations.

## Base Images

All Docker images start from a base image. A base image is the same images from the Docker Registry which are used to start containers. Along with the image name, we can also include the image tag to indicate which particular version we want, by default, this is latest.

** It's recommend to always use a particular version number as your tag and manage the updating yourself. Using the :latest tag can result in you building your image against a version which you were not expecting. 

## Dockerfile

Dockerfile's are simple text files with a command on each line:

- To define a base image we use the instruction FROM <image-name>:<tag>.
- RUN <command> allows you to execute any command as you would at a command prompt, for example installing different application packages or running a build command. The results of the RUN are persisted to the image so it's important not to leave any unnecessary or temporary files on the disk as these will be included in the image.
- COPY <src> <dest> allows you to copy files from the directory containing the Dockerfile to the container's image. This is extremely useful for source code and assets that you want to be deployed inside your container. NOTE If you're copying a file into a directory then you need to specify the filename as part of the destination.
- EXPOSE <port> command allows you tell Docker which ports should be open and can be bound to. You can define multiple ports on the single command, for example, EXPOSE 80 433 or EXPOSE 7000-8000.
- CMD <command string>/<command array> defines the default command to run when a container is launched. If the command requires arguments then it's recommended to use an array, for example ["cmd", "-a", "arga value", "-b", "argb-value"].
- ENTRYPOINT <command string>/<command array> an alternative to CMD. While a CMD can be overridden when the container starts, a ENTRYPOINT defines a command which can have arguments passed to it when the container launches

## Building the Container

After writing a docker file we need to build the image, for that we run:

```bash
docker build -t <name>:<tag> DIRECTORY_CONTAING_DOCKERFILE

# To see the Image we run
docker images
```

## Lunching the container

docker run -d -p port:port IMAGE

* -d to run container in background