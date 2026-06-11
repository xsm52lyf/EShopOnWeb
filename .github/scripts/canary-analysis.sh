set -euo pipefail

COMMAND=${1:-analyze}
NAMESPACE=${2:-corecommerce-prod}
SERVICE=${3:-corecommerce-web}
PROMETHEUS_URL=${PROMETHEUS_URL:-http://prometheus-kube-prometheus-prometheus.monitoring:9090}

smoke_test() {
  local endpoint=$1
  local max_retries=10
  local retry_count=0
  
  echo " Running smoke tests against ${endpoint}..."
  
  # 健康检查
  while [ $retry_count -lt $max_retries ]; do
    if curl -s -f "http://${endpoint}/health/ready" > /dev/null 2>&1; then
      echo " Health check passed"
      break
    fi
    retry_count=$((retry_count + 1))
    echo "Waiting for service... (${retry_count}/${max_retries})"
    sleep 10
  done
  
  if [ $retry_count -eq $max_retries ]; then
    echo " Health check failed!"
    return 1
  fi
  
  # API 测试
  if curl -s -f "http://${endpoint}/api/catalog/items?pageSize=1" > /dev/null 2>&1; then
    echo " API test passed"
  else
    echo " API test failed!"
    return 1
  fi
  
  return 0
}

check_error_rate() {
  local threshold=${1:-5}  
  
  echo " Checking error rate (threshold: ${threshold}%)..."
  
  QUERY='sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100'
  
  ERROR_RATE=$(curl -s "${PROMETHEUS_URL}/api/v1/query" \
    --data-urlencode "query=${QUERY}" \
    | jq -r '.data.result[0].value[1] // "0"')
  
  echo "Current error rate: ${ERROR_RATE}%"
  
  if (( $(echo "${ERROR_RATE} > ${threshold}" | bc -l) )); then
    echo " Error rate (${ERROR_RATE}%) exceeds threshold (${threshold}%)!"
    return 1
  fi
  
  echo " Error rate within acceptable range"
  return 0
}

check_latency() {
  local threshold_p99=${1:-1000}  
  
  echo "  Checking P99 latency (threshold: ${threshold_p99}ms)..."
  
  QUERY='histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le)) * 1000'
  
  P99_LATENCY=$(curl -s "${PROMETHEUS_URL}/api/v1/query" \
    --data-urlencode "query=${QUERY}" \
    | jq -r '.data.result[0].value[1] // "0"')
  
  echo "Current P99 latency: ${P99_LATENCY}ms"
  
  if (( $(echo "${P99_LATENCY} > ${threshold_p99}" | bc -l) )); then
    echo " P99 latency (${P99_LATENCY}ms) exceeds threshold (${threshold_p99}ms)!"
    return 1
  fi
  
  echo "Latency within acceptable range"
  return 0
}

full_analysis() {
  echo "============================================"
  echo "🔍 Running Full Canary Analysis"
  echo "============================================"
  
  local service_endpoint="${SERVICE}.${NAMESPACE}.svc.cluster.local"
  local analysis_passed=true
  
  if ! smoke_test "${service_endpoint}"; then
    analysis_passed=false
  fi
  
  if ! check_error_rate 5; then
    analysis_passed=false
  fi
  
  if ! check_latency 1000; then
    analysis_passed=false
  fi
  
  echo "============================================"
  if [ "${analysis_passed}" = true ]; then
    echo " All analysis checks passed!"
    return 0
  else
    echo " Analysis checks failed!"
    return 1
  fi
}

rollback() {
  echo " Initiating rollback for ${SERVICE} in ${NAMESPACE}..."
  
  if kubectl rollout undo deployment/${SERVICE} -n ${NAMESPACE}; then
    echo " Deployment rollback initiated"
  else
    echo "Attempting Argo Rollout rollback..."
    kubectl-argo-rollouts abort ${SERVICE} -n ${NAMESPACE}
    kubectl-argo-rollouts status ${SERVICE} -n ${NAMESPACE} --watch --timeout=10m
  fi
  
  echo " Rollback completed"
}


case "${COMMAND}" in
  smoke-test)
    smoke_test "$3"
    ;;
  check-errors)
    check_error_rate "$3"
    ;;
  check-latency)
    check_latency "$3"
    ;;
  analyze)
    full_analysis
    ;;
  rollback)
    rollback
    ;;
  *)
    echo "Usage: $0 {smoke-test|check-errors|check-latency|analyze|rollback} [args...]"
    exit 1
    ;;
esac