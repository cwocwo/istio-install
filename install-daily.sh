#!/bin/bash

source ./env.sh

# download istio release package
release_page_url=${ROOT_URL}${VERSION}/
release_page_file=${BUILD_DIR}release.html
echo "curl -o $release_page_file $release_page_url"
curl -# -C - -o $release_page_file $release_page_url

release_pkg_name=istio-${VERSION}-linux.tar.gz
release_pkg_path=${BUILD_DIR}${release_pkg_name}
echo "release_pkg_path : $release_pkg_path"
echo "start downloading release package: $release_pkg_name"
if [ ! -f "$release_pkg_path" ];then
  grep "${release_pkg_name}" $release_page_file|awk '{print $3}'|awk -F '"' '{print "curl -# -C - --retry 100 --retry-delay 10 -o '$release_pkg_path' " $2}'|sh
else
  echo "$release_pkg_path has been downloaded."
fi
echo "extract it --------------------------------------------------------------"
tar -xzvf $release_pkg_path -C ${BUILD_DIR}


# image build dir
images_dir="${BUILD_DIR}images/"
create_dir_ifnotexist $images_dir

image_index_page="${images_dir}image.html"

# download istio images index page
echo "download istio images index page: $IMAGE_URL"
curl -o $image_index_page $IMAGE_URL

# Analysis index page and save image's names to images.txt
image_name_index_file=${images_dir}images.txt
grep "${VERSION}/docker" $image_index_page |grep "href"|awk '{print $5}'|awk -F '<' '{print $1}' > $image_name_index_file

# prepare k8s istio install file: istio-demo.yaml
cp ${BUILD_DIR}istio-${VERSION}/install/kubernetes/istio-demo.yaml ${BUILD_DIR}
istio_install_file="${BUILD_DIR}/istio-demo.yaml"

for image_pkg_name in $(<$image_name_index_file); 
do 
  image_name=${image_pkg_name/\.tar\.gz/}
  echo "processing image: $image_name ......."
  echo "--------------------------------------------------------------------------------"

  echo "downloading image ......"
  image_pkg_path=${images_dir}$image_pkg_name
  echo "image package path: $image_pkg_path"
  grep "${image_pkg_name}" $image_index_page|awk '{print $3}'|awk -F '"' '{print "curl -# -C - --retry 100 --retry-delay 10 -o '$image_pkg_path' "  $2}' | sh
  
  echo "load image: $image_pkg_path"
  docker load < $image_pkg_path;
  
  echo "tag and push image to local repo ......"
  image_name_local="$REPO$image_name:$VERSION"
  docker tag istio/$image_name:$VERSION $image_name_local
  docker push $image_name_local

  echo "replace image to local repo in istio install file"
  source="gcr\.io/istio-release/${image_name}:${VERSION}"  
  sed -i "s|${source}|${localname}|g" $istio_install_file
done

otherimages=(quay.io/coreos/hyperkube:v1.7.6_coreos.0 prom/statsd-exporter:latest docker.io/prom/prometheus:latest)
for image in ${otherimages[@]};
do
  docker pull $image
  local_image_name="${REPO}$image"
  echo "docker tag $image $local_image_name"
  docker tag $image $local_image_name
  docker push $local_image_name
  sed -i "s|${image}|${local_image_name}|g" $istio_install_file
done
