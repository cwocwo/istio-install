#!/bin/bash
# install release version of istio
source release-conf.sh

create_dir_ifnotexist ${BUILD_DIR}
echo "download release package"
release_pkg_name=istio-${VERSION}-linux.tar.gz
release_pkg_path=${BUILD_DIR}${release_pkg_name}
download_url=${ROOT_URL}${VERSION}/$release_pkg_name

if [ ! -f "$release_pkg_path" ];then
  curl -# -C - -L -o $release_pkg_path $download_url
else
  echo "$release_pkg_path has been downloaded."
fi

echo "extract it --------------------------------------------------------------"
tar -xzvf $release_pkg_path -C ${BUILD_DIR}

# prepare k8s istio install file: istio-demo.yaml
cp ${BUILD_DIR}istio-${VERSION}/install/kubernetes/istio-demo.yaml ${BUILD_DIR}
istio_install_file="${BUILD_DIR}/istio-demo.yaml"
# grep "image:" $istio_install_file|grep -v ObjectMeta| awk '{print "docker pull " $2}'|sed 's/"//g'|sh

image_name_index_file=${BUILD_DIR}images.txt
grep "image:" $istio_install_file|grep -v ObjectMeta| awk '{print $2}' |sed 's/"//g'|sort|uniq > $image_name_index_file

for image_name in $(<$image_name_index_file);
do
  #docker pull $image_name
  echo "tag and push image to local repo ......"
  image_name_local="$REPO$image_name"
  echo "docker tag $image_name $image_name_local"
  docker tag $image_name $image_name_local
  docker push $image_name_local
  echo "replace image to local repo in istio install file"
  sed -i "s|${image_name}|${image_name_local}|g" $istio_install_file
done

