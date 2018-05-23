source ./env.sh
cp ../istio-$VERSION/install/kubernetes/istio-demo.yaml .
for line in $(<img-tars); 
do 
  # docker load < $line;
  image_name=${line/\.tar\.gz/}
  echo "processing image: $image_name ......."
  echo "--------------------------------------------------------------------------------"
  localname="$REPO$image_name:$VERSION"
  #docker tag istio/$image_name:$VERSION $localname
  #docker push $REPO$image_name:$VERSION 
  source="gcr\.io/istio-release/${image_name}:${VERSION}"  
  echo "docker tag $source $localname"
  sed -i "s|${source}|${localname}|g" istio-demo.yaml
done

otherimages=(quay.io/coreos/hyperkube:v1.7.6_coreos.0 prom/statsd-exporter:latest docker.io/prom/prometheus:latest)
for image in ${otherimages[@]};  
do  
  docker pull $image  
  local_image_name="${REPO}$image"
  echo "docker tag $image $local_image_name"
  docker tag $image $local_image_name
  docker push $local_image_name
  sed -i "s|${image}|${local_image_name}|g" istio-demo.yaml
done  

