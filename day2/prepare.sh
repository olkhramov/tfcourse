# docker alias for podman

# Usage: prepare.sh

alias docker=podman
export USER=$(whoami)
# make dir recursive 

mkdir -p /home/$USER/.local/share/containers/podman/
touch /home/$USER/.local/share/containers/podman/podman.sock
podman system service unix:///home/$USER/.local/share/containers/podman/podman.sock --time=0 &
