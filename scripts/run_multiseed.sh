# run seeds
for x in 0 1 2 3 4 5 6 7 8 9; do
  python scripts/evaluate_sequence.py --steps 200 --seed "${x}" \
    --out "artifacts/sequence_seed_${x}.json"

  python scripts/run_controller.py --steps 200 --seed "${x}" --anchor 1.0 \
    --out "artifacts/controller_anchor_seed_${x}.json"
done
