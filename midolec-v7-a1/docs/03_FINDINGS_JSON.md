# V7-a1 Findings JSON

V7-a1 introduces a more structured JSON layer called `Findings`.

The goal is to make detections easier to test, compare, and consume from other
tools.

## Root-Level Idea

V7 outputs may include:

```json
{
  "_schema_version": "7.0",
  "Detailed_analysis": {},
  "Findings": []
}
```

The legacy `Suggestion_Set` may still exist for compatibility or debugging, but
`Findings` is the preferred V7 machine-readable contract.

## Example Finding

```json
{
  "_id": "p0000.s0000.roman000",
  "family": "numbers",
  "rule_id": "roman_numeral",
  "recommendation_id": "avoid_roman_numerals",
  "scope": "span",
  "node_id": "p0000.s0000",
  "target_ids": ["p0000.s0000.w0003"],
  "char_span": [10, 12],
  "text": "IV",
  "severity": "warning",
  "message": "Avoid roman numerals when a plain numeric form is clearer."
}
```

## Important Fields

- `_id`: unique finding identifier inside one JSON document.
- `family`: high-level group, such as `numbers`, `legal`, `technical`, or `style`.
- `rule_id`: stable detector identifier.
- `recommendation_id`: stable recommendation identifier.
- `node_id`: closest structural node affected by the finding.
- `target_ids`: specific paragraph, sentence, or word IDs affected by the finding.
- `char_span`: character range in the analyzed text.
- `severity`: `info`, `warning`, or `error`.
- `message`: human-facing text; tests should not depend on exact wording.
