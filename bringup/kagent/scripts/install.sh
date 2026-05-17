#!/usr/bin/env bash
# One-shot installer for the kagent eval kit. Scoped to a single
# `kagent-eval` namespace; only touches `content-factory` via RBAC.
#
# Prereqs: kubectl context set, helm 3.x, $OPENAI_API_KEY exported.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  echo "ERROR: OPENAI_API_KEY env var not set" >&2
  exit 1
fi
if ! command -v kubectl >/dev/null 2>&1; then
  echo "ERROR: kubectl not on PATH" >&2
  exit 1
fi
if ! command -v helm >/dev/null 2>&1; then
  echo "ERROR: helm not on PATH" >&2
  exit 1
fi

CTX="$(kubectl config current-context)"
echo "Installing kagent eval into context: ${CTX}"
echo "Press Ctrl-C in 5s to abort..."
sleep 5

echo
echo "== Step 1: Add kagent helm repo + install controller =="
helm repo add kagent https://helm.kagent.dev 2>&1 | sed 's/^/    /' || true
helm repo update kagent 2>&1 | sed 's/^/    /'
helm upgrade --install kagent kagent/kagent \
  --namespace kagent-eval \
  --create-namespace \
  --set profile=minimal \
  --wait \
  --timeout 5m 2>&1 | sed 's/^/    /'

echo
echo "== Step 2: Apply RBAC (scoped read of content-factory) =="
kubectl apply -f "${KIT_DIR}/01-namespace-eval.yaml" 2>&1 | sed 's/^/    /'

echo
echo "== Step 3: Apply OpenAI secret (key from env) =="
sed "s|REPLACE_WITH_OPENAI_API_KEY|${OPENAI_API_KEY}|" "${KIT_DIR}/02-openai-secret.yaml" \
  | kubectl apply -f - 2>&1 | sed 's/^/    /'

echo
echo "== Step 4: Apply ModelConfig + ToolServers + Agents =="
for f in \
    "${KIT_DIR}/03-modelconfig.yaml" \
    "${KIT_DIR}/04-toolserver-prometheus.yaml" \
    "${KIT_DIR}/05-toolserver-grafana.yaml" \
    "${KIT_DIR}/06-agent-cf-pod-doctor.yaml" \
    "${KIT_DIR}/07-agent-cf-gpu-rollout.yaml" \
    "${KIT_DIR}/08-agent-cf-alert-triage.yaml"; do
  echo "  apply $(basename "$f")"
  kubectl apply -f "$f" 2>&1 | sed 's/^/    /'
done

echo
echo "== Step 5: Health check =="
kubectl -n kagent-eval get pods,agents,modelconfigs,toolservers 2>&1 | sed 's/^/    /' || true

cat <<EOF

✓ kagent eval installed.

Open the UI:
  kubectl -n kagent-eval port-forward svc/kagent-ui 8082:80
  # then http://localhost:8082

Walk the gates in scripts/eval-checklist.md.

Uninstall:
  ./scripts/uninstall.sh
EOF
