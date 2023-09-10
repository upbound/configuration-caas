#!/usr/bin/env bash
set -aeuo pipefail

UPTEST_GCP_PROJECT=${UPTEST_GCP_PROJECT:-official-provider-testing}

echo "Running setup.sh"
echo "Waiting until configuration package is installed..."
${KUBECTL} wait configuration.pkg configuration-caas --for=condition=Installed --timeout 10m
echo "Waiting until configuration package is healthy..."
${KUBECTL} wait configuration.pkg configuration-caas --for=condition=Healthy --timeout 10m

echo "Creating aws cloud credential secret..."
${KUBECTL} -n upbound-system create secret generic aws-creds --from-literal=credentials="${UPTEST_AWS_CLOUD_CREDENTIALS}" \
    --dry-run=client -o yaml | ${KUBECTL} apply -f -

echo "Creating azure cloud credential secret..."
${KUBECTL} -n upbound-system create secret generic azure-creds --from-literal=credentials="${UPTEST_AZURE_CLOUD_CREDENTIALS}" \
    --dry-run=client -o yaml | ${KUBECTL} apply -f -

echo "Creating gcp cloud credential secret..."
${KUBECTL} -n upbound-system create secret generic gcp-creds --from-literal=credentials="${UPTEST_GCP_CLOUD_CREDENTIALS}" \
    --dry-run=client -o yaml | ${KUBECTL} apply -f -

echo "Waiting for all pods to come online..."
"${KUBECTL}" -n upbound-system wait --for=condition=Available deployment --all --timeout=10m

echo "Waiting for all XRDs to be established..."
"${KUBECTL}" wait xrd --all --for condition=Established

echo "Creating a default aws providerconfig..."
cat <<EOF | ${KUBECTL} apply -f -
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    secretRef:
      key: credentials
      name: aws-creds
      namespace: upbound-system
    source: Secret
EOF

echo "Creating a default azure providerconfig..."
cat <<EOF | ${KUBECTL} apply -f -
apiVersion: azure.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    secretRef:
      key: credentials
      name: azure-creds
      namespace: upbound-system
    source: Secret
EOF

echo "Creating a default gcp providerconfig..."
cat <<EOF | ${KUBECTL} apply -f -
apiVersion: gcp.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    secretRef:
      key: credentials
      name: gcp-creds
      namespace: upbound-system
    source: Secret
  projectID: ${UPTEST_GCP_PROJECT}
EOF
