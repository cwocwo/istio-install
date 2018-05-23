wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/app.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/citadel-test.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/citadel.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/eurekamirror.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/flexvolumedriver.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/galley.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/grafana.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/mixer.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/mixer_debug.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/node-agent-test.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/node-agent.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/pilot.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/proxy.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/proxy_debug.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/proxy_init.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/proxyv2.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/servicegraph.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/servicegraph_debug.tar.gz
wget --tries=5 --timestamping --wait=5 https://storage.googleapis.com/istio-prerelease/daily-build/release-0.8-20180524-09-15/docker/sidecar_injector.tar.gz
docker pull quay.io/coreos/hyperkube:v1.7.6_coreos.0
docker pull prom/statsd-exporter:latest
docker pull docker.io/prom/prometheus:latest

