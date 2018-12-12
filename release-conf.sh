

ROOT_URL="https://github.com/istio/istio/releases/download/"
VERSION="1.0.4"
REPO="registry.icp.com:5000/library/istio/"

# build dir
BUILD_DIR="./build-$VERSION/"

function create_dir_ifnotexist {
  if [ ! -d "$1" ];then
    mkdir -p $1
  else
    echo "$1 already exists."
  fi
}


