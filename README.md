# RFM Segmentation — eligibility and offer sizing in SQL

![SQL](https://img.shields.io/badge/SQL-CTEs%20·%20window%20functions-2456D6?style=flat-square&logo=postgresql&logoColor=white)
![Parameterised](https://img.shields.io/badge/cut--offs-parameterised-1F7A5A?style=flat-square)
![Runnable](https://img.shields.io/badge/runs-out%20of%20the%20box-1F7A5A?style=flat-square)

<img src="assets/rfm-matrix.svg" alt="RFM matrix with named segments" width="100%">

Recency–Frequency–Monetary scoring on a retail customer base, written so that **every cut-off is a parameter** and the whole rule set re-runs on new data without editing logic.

**Champions spend 39% more at the same purchase frequency** — so the growth lever is basket size, not visit count.

---

## Why parameterised cut-offs matter

Hard-coded quintile boundaries rot the moment the base changes. Here the boundaries come from `NTILE` over the current base, and the segment rules read those scores — so re-running next quarter re-segments correctly instead of mislabelling everyone.

## The query

```
orders ──▶ customer_base ──▶ rfm_raw ──▶ rfm_scored ──▶ segments
           one row per      R, F, M      NTILE(5)      named rules
           customer         per customer  per metric    on the scores
```

`sql/rfm.sql` runs end to end. Swap the `params` CTE to change the window, the tier count, or the currency filter.

## Segments produced

| Segment | Rule | What to do with it |
|---|---|---|
| Champions | R 4–5, F 4–5, M 4–5 | Grow basket size, not visit frequency |
| Loyal | R 3–5, F 3–5 | Protect — cheapest revenue to keep |
| Potential | R 4–5, F 1–2 | Second-purchase nudge |
| At risk | R 1–2, F 3–5 | Win-back before the gap closes |
| Need attention | R 1–2, F 1–2, M 1–2 | Engage too little for discounts to land — build trust, not price cuts |

## Run it

```bash
psql -f sql/rfm.sql          # PostgreSQL
# or paste into BigQuery / MySQL 8 / SQL Server — window functions only, no vendor extensions
```

Sample schema and synthetic rows in `sql/00_sample_data.sql`. No client data is used anywhere in this repository.

---

**Stack** · SQL (CTEs, window functions) · Power BI
**More** · [live SQL console on my portfolio](https://portfolionhmtri.netlify.app)
