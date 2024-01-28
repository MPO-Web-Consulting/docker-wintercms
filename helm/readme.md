# WinterCMS Helm Chart

This is a Helm chart for deploying WinterCMS to Kubernetes.

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
# Add the WinterCMS Helm repository
helm repo add wintercms https://github.com/MPO-Web-Consulting/docker-wintercms/raw/master/helm

# Install the chart
helm install --name my-release wintercms/wintercms
```
