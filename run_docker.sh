xhost +local:docker
docker run -ti --gpus all --volume="/home/dh/Workspace/retroyolo:/home/retroyolo" --net=host --ipc host --env="DISPLAY" --volume="$HOME/.Xauthority:/root/.Xauthority:rw" darknet