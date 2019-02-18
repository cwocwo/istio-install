

ROOT_URL="https://github.com/istio/istio/releases/download/"
VERSION="1.0.6"
REPO="registry.icp.com:5000/library/istio/"

# build dir
BUILD_DIR="./build-$VERSION/"


# includeIPRanges
includeIPRanges="158.158.0.0/24"

# sidecar auto inject: enabled or disabled
sidecarAutoInject=disabled

# If set to true, istio-proxy container will have privileged securityContext
privileged=true

# ImagePullSecrets for all ServiceAccount
imagePullSecrets=service-registry

# preserve client source ip in container  (Local or Cluster)
externalTrafficPolicy=Local

function create_dir_ifnotexist {
  if [ ! -d "$1" ];then
    mkdir -p $1
  else
    echo "$1 already exists."
  fi
}


