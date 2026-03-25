#!/bin/bash

source configure.sh

JUPYTER_WORKSPACE=${1:-$HOME}  # default to $HOME
JETBOT_CAMERA=${2:-opencv_gst_camera}  # default to opencv

# Build images locally if they are not available
DISPLAY_IMAGE=$JETBOT_DOCKER_REMOTE/jetbot:display-$JETBOT_VERSION-$L4T_VERSION
JUPYTER_IMAGE=$JETBOT_DOCKER_REMOTE/jetbot:jupyter-$JETBOT_VERSION-$L4T_VERSION
BASE_IMAGE=$JETBOT_DOCKER_REMOTE/jetbot:base-$JETBOT_VERSION-$L4T_VERSION
MODELS_IMAGE=$JETBOT_DOCKER_REMOTE/jetbot:models-$JETBOT_VERSION-$L4T_VERSION

DOCKER_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! sudo docker image inspect $BASE_IMAGE &>/dev/null; then
	echo "Base image not found, building..."
	(cd "$DOCKER_DIR/base" && ./build.sh)
fi

if ! sudo docker image inspect $DISPLAY_IMAGE &>/dev/null; then
	echo "Display image not found, building..."
	(cd "$DOCKER_DIR/display" && ./build.sh)
fi

if ! sudo docker image inspect $MODELS_IMAGE &>/dev/null; then
	echo "Models image not found, building..."
	(cd "$DOCKER_DIR/models" && ./build.sh)
fi

if ! sudo docker image inspect $JUPYTER_IMAGE &>/dev/null; then
	echo "Jupyter image not found, building..."
	(cd "$DOCKER_DIR/jupyter" && ./build.sh)
fi

if [ "$JETBOT_CAMERA" = "zmq_camera" ]
then
	"$DOCKER_DIR/camera/enable.sh"
fi

"$DOCKER_DIR/display/enable.sh"
"$DOCKER_DIR/jupyter/enable.sh" $JUPYTER_WORKSPACE $JETBOT_CAMERA
