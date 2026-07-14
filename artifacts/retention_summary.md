# Sweep summary

Values are mean +/- sample std across seeds within each condition.

## Inputs

- JSON files: 40

## Aggregate metrics

| condition | n | final acc avg | A | B | C | retention | rev gap | collateral | order sens | drift KL | paraphrase |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| hard_ortho;base | 10 | 0.167 +/- 0.000 | 0.250 +/- 0.000 | 0.250 +/- 0.000 | 0.000 +/- 0.000 | - | - | - | - | 0.000 +/- 0.000 | - |
| hard_ortho;controller | 10 | 0.542 +/- 0.071 | 0.250 +/- 0.000 | 0.375 +/- 0.212 | 1.000 +/- 0.000 | 0.312 +/- 0.106 | 0.025 +/- 0.079 | 0.637 +/- 0.092 | 0.617 +/- 0.090 | 4.923 +/- 0.469 | 0.000 +/- 0.000 |
| hard_ortho;controller_routed | 10 | 0.983 +/- 0.035 | 0.975 +/- 0.079 | 1.000 +/- 0.000 | 0.975 +/- 0.079 | - | - | - | - | - | - |
| replay=1;base | 10 | 0.167 +/- 0.000 | 0.250 +/- 0.000 | 0.250 +/- 0.000 | 0.000 +/- 0.000 | - | - | - | - | 0.000 +/- 0.000 | - |
| replay=1;controller | 10 | 1.000 +/- 0.000 | 1.000 +/- 0.000 | 1.000 +/- 0.000 | 1.000 +/- 0.000 | 1.000 +/- 0.000 | 0.050 +/- 0.105 | 0.887 +/- 0.092 | 0.000 +/- 0.000 | 4.547 +/- 0.661 | 0.000 +/- 0.000 |
| replay=1;controller_routed | 10 | 0.983 +/- 0.035 | 0.975 +/- 0.079 | 1.000 +/- 0.000 | 0.975 +/- 0.079 | - | - | - | - | - | - |
| replay=1;hard_ortho;base | 10 | 0.167 +/- 0.000 | 0.250 +/- 0.000 | 0.250 +/- 0.000 | 0.000 +/- 0.000 | - | - | - | - | 0.000 +/- 0.000 | - |
| replay=1;hard_ortho;controller | 10 | 0.983 +/- 0.053 | 0.975 +/- 0.079 | 0.975 +/- 0.079 | 1.000 +/- 0.000 | 0.975 +/- 0.079 | 0.050 +/- 0.105 | 0.875 +/- 0.118 | 0.017 +/- 0.053 | 4.705 +/- 0.630 | 0.000 +/- 0.000 |
| replay=1;hard_ortho;controller_routed | 10 | 0.983 +/- 0.035 | 0.975 +/- 0.079 | 1.000 +/- 0.000 | 0.975 +/- 0.079 | - | - | - | - | - | - |
| retention_ctrl;base | 10 | 0.167 +/- 0.000 | 0.250 +/- 0.000 | 0.250 +/- 0.000 | 0.000 +/- 0.000 | - | - | - | - | 0.000 +/- 0.000 | - |
| retention_ctrl;controller | 10 | 0.575 +/- 0.092 | 0.300 +/- 0.197 | 0.425 +/- 0.206 | 1.000 +/- 0.000 | 0.362 +/- 0.138 | 0.050 +/- 0.105 | 0.675 +/- 0.158 | 0.575 +/- 0.073 | 4.670 +/- 0.595 | 0.000 +/- 0.000 |
| retention_ctrl;controller_routed | 10 | 0.983 +/- 0.035 | 0.975 +/- 0.079 | 1.000 +/- 0.000 | 0.975 +/- 0.079 | - | - | - | - | - | - |

Notes:

- Conditions are inferred from JSON config fields. For example, `k=16;controller` means controller metrics from runs with `n_components=16`.
- Routed controller rows report held-out context routing accuracy; sequence-only metrics are intentionally blank for those rows.
