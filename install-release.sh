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
grep "image:" $istio_install_file|grep -v ObjectMeta|sed 's/- //g'|awk '{print $2}' |sed 's/"//g'|sort|uniq > $image_name_index_file
#sed -i "s|gcr.io/istio-release|istio|g" $image_name_index_file
#echo "kiali/kiali:istio-release-1.0" >> $image_name_index_file

# save images
image_dir=${BUILD_DIR}images/
create_dir_ifnotexist ${image_dir}

# generate load image script
load_images_script=${image_dir}load-image.sh
cat "" > $load_images_script

# prepare istio helm install values.yaml
helm_install_values_file="${install_file_dir}helm/istio/values.yaml"
cp $helm_install_values_file ${install_file_dir}/helm/istio/values.yaml.bak

#all_images=$(<$image_name_index_file)" "$(grep -A 1 -E "/kiali|/jetstack" $helm_install_values_file|awk -F- '{print $1}'|awk '{print $2}'|awk -f hub_image.awk)
all_images=$(<$image_name_index_file)" "$(grep -A 1 -E "/kiali|/jetstack" $helm_install_values_file|awk -F- '{print $1}'|awk '{print $2}'|awk -F/ '{print $1 "\n" $2}'|awk -f hub_image.awk)
echo $all_images
#for hub_image in $(grep -A 1 -E "/kiali|/jetstack" $helm_install_values_file|awk -F- '{print $1}'|awk '{print $2}'|awk -f hub_image.awk);
#do
#  echo "===================================================================================================================================="
#  echo $hub_image
#done

for image_name in $all_images;
do
  echo ""
  echo "===================================================================================================================================="
  # pull images
  echo "starting to pull image: $image_name"
  trimed_image_name=$(echo ${image_name/docker.io\//}|awk -F: '{print $1}')
  images_exists=$(docker images $trimed_image_name|wc -l)
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

  #image_origin_name=${image_name//istio/gcr.io\/istio-release}
  image_origin_name=$image_name
  echo "replace image:[$image_origin_name] to local repo:[$image_name_local] in istio install file"
  sed -i "s|${image_origin_name}|${image_name_local}|g" $istio_install_file
  echo "------------------------------------------------------------------------------------------------------------------------------------"
done

# disable auto sidecar auto inject
sed -i "s|policy: enabled|policy: $sidecarAutoInject|g" $istio_install_file
sed -i "s|autoInject: enabled|autoInject: $sidecarAutoInject|g" $helm_install_values_file

# set privileged
# If set to true, istio-proxy container will have privileged securityContext
# sed -i "s|securityContext:\n          capabilities:|securityContext:\n          runAsUser: 0\n          runAsNonRoot: false\n          capabilities:|g" $istio_install_file
sed -i ":begin; /        securityContext:/,/          capabilities:/ { /          capabilities:/! { $! { N; b begin }; }; s/securityContext.*capabilities:/securityContext:\n          runAsUser: 0\n          runAsNonRoot: false\n          capabilities:/; };" $istio_install_file
helm_sidecar_injector_configmap_file="${install_file_dir}helm/istio/templates/sidecar-injector-configmap.yaml"
sed -i "s|privileged: false|privileged: $privileged|g" $helm_install_values_file
sed -i ":begin; /        securityContext:/,/          privileged: true/ { /          privileged: true/! { $! { N; b begin }; }; s/securityContext.*privileged: true/securityContext:\n          runAsUser: 0\n          runAsNonRoot: false\n          capabilities:\n            add:\n            - NET_ADMIN\n          privileged: true/; };" $helm_sidecar_injector_configmap_file

# set includeIPRanges
sed -i "s|\`traffic.sidecar.istio.io/includeOutboundIPRanges\`  \"\*\"|\`traffic.sidecar.istio.io/includeOutboundIPRanges\`  \"$includeIPRanges\"|g" $istio_install_file
sed -i "s|includeIPRanges: \"\*\"|includeIPRanges: \"$includeIPRanges\"|g" $helm_install_values_file

# set ingressgateway service's externalTrafficPolicy
sed -i "s|type: LoadBalancer|type: LoadBalancer\n  externalTrafficPolicy: $externalTrafficPolicy|g" $istio_install_file
sed -i "s|# externalTrafficPolicy: Local|externalTrafficPolicy: $externalTrafficPolicy|g" $helm_install_values_file

# ImagePullSecrets for all ServiceAccount, list of secrets in the same namespace
# to use for pulling any images in pods that reference this ServiceAccount.
# Must be set for any clustser configured with privte docker registry.
# TODO  set istio-demo.yaml
sed -i "s|imagePullSecrets:|imagePullSecrets:\n    - $imagePullSecrets|g" $helm_install_values_file

# set ingress-gateway externalIPs
ip_array=(${externalIPs//,/ })
k8s_ips=""
for ip in ${ip_array[@]}
do
  k8s_ips=${k8s_ips}"  - "${ip}\\n
done
sed -i "s|type: LoadBalancer|type: LoadBalancer\n  externalIPs:\n$k8s_ips|g" $istio_install_file


helm_ips=""
for ip in ${ip_array[@]}
do
  helm_ips=${helm_ips}"    - "${ip}\\n
done
sed -i "s|      istio: ingressgateway|      istio: ingressgateway\n    externalIPs:\n$helm_ips|g" $helm_install_values_file

for hub in $(grep "hub:" $helm_install_values_file|awk '{print $2}');
do
  sed -i "s|hub: $hub|hub: ${REPO}$hub|g" $helm_install_values_file
done



#sed -i "s|hub: docker.io/istio|hub: ${REPO}istio|g" $helm_install_values_file
#sed -i "s|hub: quay.io/coreos|hub: ${REPO}quay.io/coreos|g" $helm_install_values_file
#sed -i "s|hub: docker.io/prom|hub: ${REPO}docker.io/prom|g" $helm_install_values_file
#sed -i "s|hub: docker.io/jaegertracing|hub: ${REPO}docker.io/jaegertracing|g" $helm_install_values_file
#sed -i "s|hub: docker.io/kiali|hub: ${REPO}docker.io/kiali|g" $helm_install_values_file
#sed -i "s|hub: quay.io/jetstack|hub: ${REPO}quay.io/jetstack|g" $helm_install_values_file
