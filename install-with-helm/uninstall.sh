kubectl delete -n istio-system secret istio-ingressgateway-certs 
helm delete --purge istio
kubectl delete -f istio/templates/crds.yaml
rm -rf /etc/istio/ingressgateway-certs
