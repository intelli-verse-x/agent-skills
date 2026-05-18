#!/usr/bin/env bash
# One-shot installer for the kagent eval kit. Scoped to a single
# `kagent-eval` namespace; only touches the Content Factory namespace
# (default: content-factory; override with CF_NAMESPACE=aicart for the
# intelli-verse-x EKS cluster) via read-only RBAC.
#
# Prereqs: kubectl context set, helm 3.x, $OPENAI_API_KEY exported.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

CF_NAMESPACE="${CF_NAMESPACE:-content-factory}"

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

if ! kubectl get ns "${CF_NAMESPACE}" >/dev/null 2>&1; then
  echo "ERROR: target namespace '${CF_NAMESPACE}' does not exist in the current cluster." >&2
  echo "       Set CF_NAMESPACE to an existing namespace (e.g. CF_NAMESPACE=aicart)." >&2
  exit 1
fi

CTX="$(kubectl config current-context)"
echo "Installing kagent eval into context: ${CTX}"
echo "Content Factory namespace (read-only scope): ${CF_NAMESPACE}"
echo "Press Ctrl-C in 5s to abort..."
sleep 5

echo
echo "== Step 1a: Install kagent CRDs from OCI registry =="
# Upstream moved from helm.kagent.dev to OCI ghcr.io charts (v0.9+).
helm upgrade --install kagent-crds \
  oci://ghcr.io/kagent-dev/kagent/helm/kagent-crds \
  --namespace kagent-eval \
  --create-namespace \
  --wait \
  --timeout 5m 2>&1 | sed 's/^/    /'

echo
echo "== Step 1b: Install kagent controller + UI from OCI registry =="
helm upgrade --install kagent \
  oci://ghcr.io/kagent-dev/kagent/helm/kagent \
  --namespace kagent-eval \
  --set providers.default=openAI \
  --set providers.openAI.apiKey="${OPENAI_API_KEY}" \
  --wait \
  --timeout 10m 2>&1 | sed 's/^/    /'

echo
echo "== Step 2: Apply RBAC (scoped read of ${CF_NAMESPACE}) =="
sed "s|__CF_NAMESPACE__|${CF_NAMESPACE}|g" "${KIT_DIR}/01-namespace-eval.yaml" \
  | kubectl apply -f - 2>&1 | sed 's/^/    /'

echo
echo "== Step 3: Apply OpenAI secret (key from env) =="
# Kept for tools that read directly from a secret rather than the
# kagent-injected provider config; harmless if unused.
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
  kubectl -n kagent-eval port-forward svc/kagent-ui 8082:8080
  # then http://localhost:8082

Walk the gates in scripts/eval-checklist.md.

Uninstall:
  ./scripts/uninstall.sh
EOF
