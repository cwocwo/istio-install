

ROOT_URL="https://gcsweb.istio.io/gcs/istio-prerelease/daily-build/"
VERSION="release-0.8-20180531-09-15"
REPO="registry.k8s77.com:5000/library/istio/"

# build dir
BUILD_DIR="./build-$VERSION/"

# istio release package url
RLEASE_PKG_URL=${ROOT_URL}istio-${VERSION}-linux.tar.gz

# istio release: docker images url
IMAGE_URL=${ROOT_URL}${VERSION}/docker



function create_dir_ifnotexist {
  if [ ! -d "$1" ];then
    mkdir -p $1
  else
    echo "$1 already exists."
  fi
}


