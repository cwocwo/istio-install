#!/bin/bash
source ./release-conf.sh
#source ./env.sh
echo "$VERSION"
sample_dir="${BUILD_DIR}samples/"
create_dir_ifnotexist $sample_dir
cp ${BUILD_DIR}istio-${VERSION}/samples/bookinfo/kube/bookinfo.yaml $sample_dir

image_file=${sample_dir}images.txt
grep "image: " $sample_dir/bookinfo.yaml|awk '{print $2}'>${image_file}

# save images
image_dir=${sample_dir}images/
create_dir_ifnotexist ${image_dir}

# generate load image script
load_images_script=${image_dir}load-image.sh
cat "" > $load_images_script


for image_name in $(<${image_file});
  do
    # docker load < $line;
    echo "processing image: $image_name ......."
    echo "--------------------------------------------------------------------------------"
    echo "pull image: $image_name ......"
    #docker pull $image_name

    export_image_name1=${image_name//\//-}
    export_image_name=${export_image_name1/\:/-}.tar.gz
    if [ ! -f $image_dir$export_image_name ]; then docker save -o $image_dir$export_image_name $image_name; fi
    echo "Add script: docker load < $export_image_name"
    echo "docker load < $export_image_name">>$load_images_script

    image_name_local="${REPO}samples/$image_name"
    echo "docker tag $image_name $image_name_local"
    docker tag $image_name $image_name_local
    docker push $image_name_local
    
    sed -i "s|image: ${image_name}|image: ${image_name_local}|g" $sample_dir/bookinfo.yaml
  done


echo "pull docker images ......"
#docker pull 


