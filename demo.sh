#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# weatherapp Helm demo - run from the folder that contains ./weatherapp
#
#   ./demo.sh            interactive: press Enter to move to the next section
#   AUTO=1 ./demo.sh     hands-free: pauses DELAY seconds (default 4) per section
#   ./demo.sh --fresh    uninstall first, then install from scratch on camera
#
# Before recording, open a SECOND terminal and run:  minikube tunnel
# (leave it running so https://weatherapp.local works)
#
# Secrets (API key, DB passwords) are masked so they never appear in the video.
# ---------------------------------------------------------------------------
set -u

CHART="${CHART:-./weatherapp}"
RELEASE="${RELEASE:-weatherapp}"
HOST="weatherapp.local"
AUTO="${AUTO:-0}"
DELAY="${DELAY:-4}"

C_T=$'\e[1;36m'; C_C=$'\e[1;33m'; C_G=$'\e[1;32m'; C_R=$'\e[0m'

pause() {
  if [ "$AUTO" = "1" ]; then sleep "$DELAY"
  else read -r -p "${C_G}>> Press Enter to continue...${C_R}" _; fi
  echo
}
title() { clear; echo "${C_T}======== $* ========${C_R}"; echo; }
say()   { echo "${C_G}# $*${C_R}"; }
run()   { echo "${C_C}\$ $*${C_R}"; eval "$@"; echo; }

if [ ! -d "$CHART" ]; then
  echo "Chart folder '$CHART' not found. Run this from the folder that contains ./weatherapp"
  exit 1
fi

# ---------------------------------------------------------------- intro
title "Weather App on Kubernetes - packaged with Helm"
cat <<'EOF'
   Browser --> Ingress (nginx) --> UI (x2) --+--> Auth --> MySQL (StatefulSet + PVC)
                                             |
                                             +--> Weather API service (x2)

   Packaged as ONE Helm chart:  ui | weather | auth | mysql | ingress
EOF
echo
pause

# ---------------------------------------------------------------- fresh
if [ "${1:-}" = "--fresh" ]; then
  title "Cleaning the previous deployment"
  run "helm uninstall $RELEASE"
  run "kubectl delete pvc mysql-persistent-storage-mysql-0 --ignore-not-found"
  sleep 5
fi

# ---------------------------------------------------------------- cluster
title "1. The cluster"
say "Local Kubernetes cluster running on minikube"
if ! minikube status >/dev/null 2>&1; then
  say "minikube is not running - starting it"
  run "minikube start --driver=docker"
fi
run "kubectl config current-context"
run "kubectl get nodes"
run "helm version --short"
say "NGINX ingress controller (minikube addon)"
minikube addons enable ingress >/dev/null 2>&1
run "kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s"
pause

# ---------------------------------------------------------------- chart
title "2. The Helm chart"
say "Chart layout"
run "find $CHART -type f | sort"
say "values.yaml - every setting in one place (secrets masked)"
run "sed -E 's/^( *(apiKey|rootPassword|authPassword|secretKey):).*/\\1 \"********\"/' $CHART/values.yaml"
pause

title "3. Validate the chart"
run "helm lint $CHART"
say "Kubernetes resources the chart generates"
run "helm template $RELEASE $CHART | grep -E '^kind:' | sort | uniq -c"
pause

# ---------------------------------------------------------------- install
title "4. Install with one command"
run "helm upgrade --install $RELEASE $CHART --timeout 10m"
say "Waiting for everything to become ready"
run "kubectl rollout status statefulset/mysql --timeout=300s"
run "kubectl rollout status deployment/weatherapp-auth --timeout=300s"
run "kubectl rollout status deployment/weatherapp-weather --timeout=300s"
run "kubectl rollout status deployment/weatherapp-ui --timeout=300s"
pause

# ---------------------------------------------------------------- resources
title "5. What is running"
run "helm list"
run "kubectl get pods -o wide"
run "kubectl get svc"
run "kubectl get ingress"
run "kubectl get pvc"
run "kubectl get secrets,configmaps"
pause

# ---------------------------------------------------------------- scaling
title "6. Scale with Helm"
say "Change replicas through values - no YAML editing"
run "helm upgrade $RELEASE $CHART --reuse-values --set ui.replicaCount=4 --timeout 5m"
run "kubectl rollout status deployment/weatherapp-ui --timeout=120s"
run "kubectl get pods -l app.kubernetes.io/name=weatherapp-ui"
pause
say "Scale back down"
run "helm upgrade $RELEASE $CHART --reuse-values --set ui.replicaCount=2 --timeout 5m"
run "kubectl rollout status deployment/weatherapp-ui --timeout=120s"
run "helm history $RELEASE"
pause

# ---------------------------------------------------------------- healing
title "7. Self-healing"
say "Delete a weather pod - Kubernetes recreates it"
run "kubectl delete pod \$(kubectl get pod -l app.kubernetes.io/name=weatherapp-weather -o name | head -1)"
sleep 3
run "kubectl get pods -l app.kubernetes.io/name=weatherapp-weather"
run "kubectl rollout status deployment/weatherapp-weather --timeout=120s"
pause

# ---------------------------------------------------------------- database
title "8. Database (MySQL StatefulSet with persistent volume)"
run "kubectl get statefulset,pvc"
say "Database and user created by the Helm init-job hook"
run "kubectl exec mysql-0 -- sh -c 'mysql -uroot -p\"\$MYSQL_ROOT_PASSWORD\" -e \"SHOW DATABASES; SELECT user FROM mysql.user;\" 2>/dev/null'"
pause

# ---------------------------------------------------------------- logs
title "9. Service logs"
run "kubectl logs deploy/weatherapp-auth --tail=8"
run "kubectl logs deploy/weatherapp-weather --tail=8"
run "kubectl logs deploy/weatherapp-ui --tail=8"
pause

# ---------------------------------------------------------------- live test
title "10. Live test through the Ingress"
if ! pgrep -f "minikube tunnel" >/dev/null 2>&1; then
  echo "${C_C}Warning: 'minikube tunnel' is not running. Start it in another terminal for this step.${C_R}"
  echo
fi
run "curl -sk -o /dev/null -w 'UI  (https://$HOST/)       -> HTTP %{http_code}\\n' --resolve $HOST:443:127.0.0.1 https://$HOST/"
run "curl -sk -o /dev/null -w 'UI health (/health)        -> HTTP %{http_code}\\n' --resolve $HOST:443:127.0.0.1 https://$HOST/health"
say "Opening the app in the browser"
if command -v xdg-open >/dev/null 2>&1; then xdg-open "https://$HOST" >/dev/null 2>&1 & fi
echo "${C_G}Demo complete. Switch to the browser: register, log in, search a city.${C_R}"
echo
