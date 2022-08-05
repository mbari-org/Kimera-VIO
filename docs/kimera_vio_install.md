# Kimera-VIO Installation

## Build

Clone this repo and build the image from the `Dockerfile_18_04`. The image is approximately 4 GB in size, but ~10 GB of space is required during the build for intermediate containers.

To accelerate the build, you can use the `--build-arg NUM_THREADS=<number>` flag to specify the number of threads to use. By default, the build uses only one thread.

```bash
git clone git@github.com:mbari-org/Kimera-VIO.git Kimera-VIO
cd Kimera-VIO

docker build -t kimera_vio -f Dockerfile_18_04 [--build-arg NUM_THREADS=<number>] .
```

This may take a while (> 1 hour), so go grab a cup of coffee and a muffin.

## Run

Once the image is built, you can run it with the included `run_container.sh` script, which is simply a wrapper for the `docker run` command with some setup to enable X11 forwarding. The image has a default command of `/bin/bash`, so running this script will drop you into a shell. The `--rm` flag is recommended to remove the container after it exits; exclude this flag if you want to keep it around for debugging.

If you plan to download the target data on the host, add a `-v` flag to the script to mount your dataset.

```bash
./run_container.sh [--rm] [-v <host_path>:<container_path>]
```

Once in the container, you can run the Kimera-VIO pipeline as normal:

```bash
# e.g.
./scripts/stereoVIOEuroc.bash -p /Euroc/V1_01_easy
```