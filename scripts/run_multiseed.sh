#!/usr/bin/env bash
# Run the default multi-seed comparison used by artifacts/multiseed_summary.md.

set -euo pipefail

PYTHON_BIN="${PYTHON:-python3}"
OUT_DIR="${OUT_DIR:-artifacts}"
STEPS="${STEPS:-200}"
SEEDS=(${SEEDS:-0 1 2 3 4 5 6 7 8 9})

mkdir -p "${OUT_DIR}"

echo "Writing seed artifacts under ${OUT_DIR}"
echo "Python: ${PYTHON_BIN}"
echo "Steps: ${STEPS}"
echo "Seeds: ${SEEDS[*]-}"

set +u
for seed in "${SEEDS[@]}"; do
  "${PYTHON_BIN}" scripts/evaluate_sequence.py \
    --steps "${STEPS}" \
    --seed "${seed}" \
    --out "${OUT_DIR}/sequence_seed_${seed}.json"

  "${PYTHON_BIN}" scripts/run_controller.py \
    --steps "${STEPS}" \
    --seed "${seed}" \
    --anchor 1.0 \
    --out "${OUT_DIR}/controller_anchor_seed_${seed}.json"
done
set -u
