#!/usr/bin/env bash
# Tear down the kagent eval kit. Leaves `content-factory` untouched.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Removing eval Agents + ToolServers + RBAC..."
for f in \
    "${KIT_DIR}/08-agent-cf-alert-triage.yaml" \
    "${KIT_DIR}/07-agent-cf-gpu-rollout.yaml" \
    "${KIT_DIR}/06-agent-cf-pod-doctor.yaml" \
    "${KIT_DIR}/05-toolserver-grafana.yaml" \
    "${KIT_DIR}/04-toolserver-prometheus.yaml" \
    "${KIT_DIR}/03-modelconfig.yaml" \
    "${KIT_DIR}/02-openai-secret.yaml" \
    "${KIT_DIR}/01-namespace-eval.yaml"; do
  kubectl delete -f "$f" --ignore-not-found 2>&1 | sed 's/^/    /' || true
done

echo
echo "Uninstalling helm release..."
helm uninstall kagent --namespace kagent-eval 2>&1 | sed 's/^/    /' || true

echo
echo "Deleting kagent-eval namespace..."
kubectl delete namespace kagent-eval --ignore-not-found 2>&1 | sed 's/^/    /' || true

echo
echo "Done. content-factory namespace untouched."
