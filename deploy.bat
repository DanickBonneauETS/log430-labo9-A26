@echo off
rem Deploie ou met a jour le cluster vise par kubectl (grappe du cours : VPN connecte).
rem Premiere fois : installe le cluster. Fois suivantes : recupere la derniere image publiee par le pipeline.
cd /d "%~dp0"
kubectl apply -f k8s\cockroachdb.yml || exit /b 1
kubectl rollout status statefulset/cockroachdb --timeout=300s || exit /b 1
rem Sans effet si le cluster est deja initialise
kubectl exec cockroachdb-0 -- /cockroach/cockroach init --insecure 2>nul
:attente
kubectl exec cockroachdb-0 -- /cockroach/cockroach sql --insecure -e "SELECT 1" >nul 2>&1 || (ping -n 4 127.0.0.1 >nul & goto attente)
rem Schema charge seulement s'il n'existe pas encore, pour ne pas effacer les donnees
kubectl exec cockroachdb-0 -- /cockroach/cockroach sql --insecure -e "SHOW DATABASES" | findstr /c:"labo09" >nul || kubectl exec -i cockroachdb-0 -- /cockroach/cockroach sql --insecure < cockroach-db\db-init\init.sql
kubectl apply -f k8s\app.yml
kubectl rollout restart deployment/labo9-app
kubectl rollout status deployment/labo9-app --timeout=180s
kubectl get pods
