# ADR-0032: Derive Tempo-Consistency Feedback at Runtime

**Status:** Accepted

**Date:** 2026-08-15

## Context

Exercise history stores both neutral timing statistics and an acquisition-time
quality label. The quality label (`reliable`, `inconsistent`, and related
states) was designed to decide whether an attempt could count as proficiency
evidence. Reusing it directly as learner-facing feedback couples the interface
to a historical threshold and prevents the language or bands from improving
without rewriting stored rows.

The existing history schema already stores the arithmetic mean and population
standard deviation of inter-onset intervals, their coefficient of variation,
the interval count, and the measurement-algorithm version. Coefficient of
variation is the consistent, tempo-independent statistic needed here:

```text
coefficient of variation = interval standard deviation / mean interval
```

## Decision

Piano Fitness derives learner-facing tempo-consistency feedback at runtime from
the stored statistics. It does not persist a UI label or presentation band.

The initial bands are:

| Coefficient of variation | Learner-facing band |
| --- | --- |
| Up to 0.10 | Steady tempo |
| Above 0.10, up to 0.20 | Mostly steady |
| Above 0.20 | Varied tempo |

A sample classified as `insufficientData` by the acquisition algorithm is shown
as **Short tempo sample**, regardless of its apparent variation. This preserves
the calculator's exact-duration decision without reconstructing duration from
rounded aggregates. For compatible legacy rows without a stored quality, fewer
than five intervals or an estimated span of `mean interval × interval count`
shorter than two seconds provides the fallback classification.

The stored coefficient is preferred. For compatible older rows where it is
missing, the runtime interpreter reconstructs it from the stored mean and
standard deviation. Rows without sufficient raw statistics fall back to their
stored quality label so existing history remains understandable.

`tempoMeasurementQuality` and `tempoMeasurementVersion` remain persisted and
continue to govern proficiency evidence. Learner feedback does not retroactively
change whether an attempt qualified under its acquisition algorithm.

## Options Considered

### Persist the learner-facing band

**Pros:** Simple rendering and an exact record of what the UI showed at the
time.

**Cons:** Threshold or wording changes would leave old and new attempts using
different interpretations unless history were migrated.

### Derive the band from stored aggregate statistics

**Pros:** Thresholds and language can evolve, existing attempts update
consistently, and no schema migration is required.

**Cons:** The UI may reinterpret an old attempt after a product change. The
stored measurement version remains necessary for auditable proficiency rules.

### Store every onset or interval

**Pros:** Supports future robust statistics, outlier policies, beat-grid
analysis, and visual timing plots.

**Cons:** Adds considerably more data and persistence complexity than this
three-band summary needs.

## Consequences

- History presents feedback based on a standard normalized statistic rather
  than a frozen UI label.
- Exact coefficient values remain available for testing and future tuning; the
  tooltip exposes the value as a percentage of timing variation.
- Display thresholds can change independently of proficiency thresholds.
- Aggregate statistics cannot support future median, median-absolute-deviation,
  or per-note timing analysis. Raw interval retention can be added separately
  if those features become valuable.

## Related Decisions

- [ADR-0025: Exercise History Data Model](0025-exercise-history-data-model.md)
- [ADR-0028: Exercise History Configuration-Mirroring Schema](0028-exercise-history-configuration-mirroring-schema.md)

## Technical Story

- `lib/domain/services/practice/tempo_consistency_interpreter.dart`
- `lib/presentation/features/history/widgets/history_entry_card.dart`
- `docs/specifications/exercise-tempo-calculation.md`
