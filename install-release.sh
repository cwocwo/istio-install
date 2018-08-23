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

install_file_dir=${BUILD_DIR}istio-${VERSION}/install/kubernetes/
# prepare k8s istio install file: istio-demo.yaml
cp ${install_file_dir}istio-demo.yaml ${BUILD_DIR}
istio_install_file="${BUILD_DIR}/istio-demo.yaml"

image_name_index_file=${BUILD_DIR}images.txt
grep "image:" $istio_install_file|grep -v ObjectMeta| awk '{print $2}' |sed 's/"//g'|sort|uniq > $image_name_index_file
sed -i "s|gcr.io/istio-release|istio|g" $image_name_index_file
echo "kiali/kiali:istio-release-1.0" >> $image_name_index_file

# save images
image_dir=${BUILD_DIR}images/
create_dir_ifnotexist ${image_dir}

# generate load image script
load_images_script=${image_dir}load-image.sh
cat "" > $load_images_script

for image_name in $(<$image_name_index_file);
do
  
  # pull images
  images_exists=$(docker images $image_name|wc -l)
  if [ "$images_exists" -lt "2" ];then
    docker pull $image_name
  else
    echo "image: $image_name already exists."
  fi
  
  export_image_name1=${image_name//\//-}
  export_image_name=${export_image_name1/\:/-}.tar.gz
  export_image_path=$image_dir$export_image_name
  if [ ! -f "$export_image_path" ];then
    docker save -o $export_image_path  $image_name
  else
    echo "image file: $export_image_path already exists."
  fi

  echo "Add images load script: docker load < $export_image_name"
  echo "docker load < $export_image_name">>$load_images_script


  echo "tag and push image:[$image_name] to local repo ......"
  image_name_local="$REPO$image_name"

  images_exists=$(docker images $image_name_local|wc -l)
  if [ "$images_exists" -lt "2" ];then
    echo "Tag $image_name to  $image_name_local"
    docker tag $image_name $image_name_local
    echo "Push image: [$image_name_local]"
    docker push $image_name_local
  else
    echo "image: $image_name_local already exists."
  fi

  image_origin_name=${image_name//istio/gcr.io\/istio-release}
  echo "replace image:[$image_origin_name] to local repo:[$image_name_local] in istio install file"
  sed -i "s|${image_origin_name}|${image_name_local}|g" $istio_install_file
done

# prepare istio helm install values.yaml
helm_install_values_file="${install_file_dir}helm/istio/values.yaml"
cp $helm_install_values_file ${install_file_dir}/helm/istio/values.yaml.bak
sed -i "s|hub: docker.io/istio|hub: ${REPO}istio|g" $helm_install_values_file
sed -i "s|hub: quay.io/coreos|hub: ${REPO}quay.io/coreos|g" $helm_install_values_file
sed -i "s|hub: docker.io/prom|hub: ${REPO}docker.io/prom|g" $helm_install_values_file
sed -i "s|hub: docker.io/jaegertracing|hub: ${REPO}docker.io/jaegertracing|g" $helm_install_values_file
sed -i "s|hub: docker.io/kiali|hub: ${REPO}docker.io/kiali|g" $helm_install_values_file
sed -i "s|hub: quay.io/jetstack|hub: ${REPO}quay.io/jetstack|g" $helm_install_values_file
