#!/bin/bash

function create_dir_ifnotexist {
  if [ ! -d "$1" ];then
    mkdir $1
  else
    echo "$1 already exists."
  fi
}


source ./env.sh
echo "$VERSION"
build_dir="./build"
create_dir_ifnotexist $build_dir
sample_dir="$build_dir/samples/"
create_dir_ifnotexist $sample_dir
cp $build_dir/istio-$VERSION/samples/bookinfo/kube/bookinfo.yaml $sample_dir

image_file=${sample_dir}images
grep "image: " $sample_dir/bookinfo.yaml|awk '{print $2}'>${image_file}

for image_name in $(<${image_file});
  do
    # docker load < $line;
    echo "processing image: $image_name ......."
    echo "--------------------------------------------------------------------------------"
    echo "pull image: $image_name ......"
    docker pull $image_name
    image_name_local="${REPO}samples/bookinfo/$image_name"
    echo "docker tag $image_name $image_name_local"
    docker push $image_name_local
    
    sed -i "s|image: ${image_name}|image: ${image_name_local}|g" $sample_dir/bookinfo.yaml
  done


echo "pull docker images ......"
#docker pull 


