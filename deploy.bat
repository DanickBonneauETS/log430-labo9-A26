@echo off
cd /d "%~dp0"
kubectl apply -f k8s\cockroachdb.yml
kubectl rollout status statefulset/cockroachdb --timeout=300s
kubectl exec cockroachdb-0 -- /cockroach/cockroach init --insecure
kubectl get pods -l app=cockroachdb
