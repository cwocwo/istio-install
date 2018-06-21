

ROOT_URL="https://github.com/istio/istio/releases/download/"
#https://github.com/istio/istio/releases/download/0.8.0/istio-0.8.0-linux.tar.gz
VERSION="0.8.0"
REPO="registry.cluster11.com:5000/library/istio/"

# build dir
BUILD_DIR="./build-$VERSION/"

function create_dir_ifnotexist {
  if [ ! -d "$1" ];then
    mkdir -p $1
  else
    echo "$1 already exists."
  fi
}


