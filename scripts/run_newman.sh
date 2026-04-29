#!/bin/bash

RUNS=${1:-5}

COLLECTION="postman/Lab3_JSONPlaceholder.postman_collection.json"
ENVIRONMENT="postman/Lab3_JSONPlaceholder.postman_environment.json"
DATA_FILE="data/posts_data.json"
REPORTS_DIR="reports"

mkdir -p "$REPORTS_DIR"

echo "Starting Newman stability test"
echo "Number of runs: $RUNS"
echo "Collection: $COLLECTION"
echo "Environment: $ENVIRONMENT"
echo "Data file: $DATA_FILE"
echo "----------------------------------------"

for i in $(seq 1 "$RUNS")
do
  echo "Run #$i"

  newman run "$COLLECTION" \
    -e "$ENVIRONMENT" \
    -d "$DATA_FILE" \
    -r cli,json \
    --reporter-json-export "$REPORTS_DIR/newman-run-$i.json"

  echo "Run #$i completed"
  echo "----------------------------------------"
done

echo "Generating final HTML and JSON report"

newman run "$COLLECTION" \
  -e "$ENVIRONMENT" \
  -d "$DATA_FILE" \
  -r cli,htmlextra,json \
  --reporter-htmlextra-export "$REPORTS_DIR/newman-report.html" \
  --reporter-json-export "$REPORTS_DIR/newman-report.json"

echo "Reports saved to $REPORTS_DIR"