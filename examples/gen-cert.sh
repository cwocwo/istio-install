mkdir -p /etc/istio/ingressgateway-certs
openssl req -config openssl.conf -new -x509 -newkey rsa:2048 -nodes -keyout /etc/istio/ingressgateway-certs/tls.key -days 3650 -out /etc/istio/ingressgateway-certs/tls.crt
kubectl create -n istio-system secret tls istio-ingressgateway-certs --key /etc/istio/ingressgateway-certs/tls.key --cert /etc/istio/ingressgateway-certs/tls.crt

