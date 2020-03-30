xhost +local:docker
# docker run -ti --gpus all --net=host --ipc host --env="DISPLAY" --volume="$HOME/.Xauthority:/root/.Xauthority:rw" darknet
docker run -ti --gpus all --volume="/home/dh/Workspace/retroyolo:/home/dh/Workspace/retroyolo" --volume="/media/dh/HDD:/media/dh/HDD" --net=host --ipc host --env="DISPLAY" --volume="$HOME/.Xauthority:/root/.Xauthority:rw" darknet