# DeepEval metrics research brief

Research date: 2026-08-30
Article target: *Five DeepEval Metrics That Turn RAG Scores into Engineering Decisions*
Source policy: official DeepEval documentation and the official `confident-ai/deepeval` repository only.

## Version baseline

Use **DeepEval 4.2.0**, not 4.1.0. GitHub marks `python-v4.2.0` as the latest release, published on 2026-08-24, and the tagged `pyproject.toml` declares `version = "4.2.0"`. The release includes a breaking score-direction change: metric scores were standardized so that **higher is always better**. [Release](https://github.com/confident-ai/deepeval/releases/tag/python-v4.2.0) · [tagged package metadata](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/pyproject.toml#L1-L4)

## Article-level conclusions

1. The five-metric constraint is official guidance, not an invented editorial device. DeepEval recommends no more than five metrics: 2–3 generic, system-specific metrics plus 1–2 custom, use-case-specific metrics. Treat this as guidance rather than a framework limit. [Official guidance](https://deepeval.com/docs/metrics-introduction#choosing-your-metrics) · [tagged docs source](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/docs/content/docs/metrics-introduction.mdx#L593-L598)
2. A support-RAG baseline of Faithfulness, Answer Relevancy, Contextual Precision, Contextual Recall, and one policy-specific G-Eval is defensible as an editorial recommendation. Do **not** present that exact five or its custom thresholds as DeepEval defaults.
3. DeepEval 4.2.0 reports scores on 0–1, passes at `score >= threshold`, and defaults `threshold` to `0.5`. `threshold=None` is also available for score-only mode. [Threshold contract](https://deepeval.com/docs/metrics-introduction#metric-thresholds) · [tagged docs source](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/docs/content/docs/metrics-introduction.mdx#L1140-L1168)
4. For these metrics, `strict_mode=True` sets the threshold to 1 and emits 1 only for a perfect result, otherwise 0. Describe this as a **perfect-or-zero score**, not merely “ordinary pass/fail at the configured threshold,” because the configured threshold is overridden. [Metric introduction](https://deepeval.com/docs/metrics-introduction) · [constructor example in tagged source](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/deepeval/metrics/faithfulness/faithfulness.py#L64-L80)
5. The five recommended numeric thresholds in the copied draft (0.8/0.7/0.7/0.7/0.6) are product choices, not official defaults. Label them as an illustrative starting policy or omit them. Calibrate gates against labeled examples and observed distributions; the official default remains 0.5.

## RAG metric data contract and interpretation

| Metric | Required `LLMTestCase` fields | Current calculation | Failure ownership / next investigation |
| --- | --- | --- | --- |
| `FaithfulnessMetric` | `input`, `actual_output`, `retrieval_context` | truthful claims / total claims | Generation-side grounding failure: inspect unsupported claims, prompt constraints, and model behavior. It does not grade whether retrieval found the right evidence. |
| `AnswerRelevancyMetric` | `input`, `actual_output` | relevant statements / total statements | Generation-side focus failure: inspect tangents, hedging, boilerplate, or a prompt that does not keep the answer on task. It does not establish factual correctness. |
| `ContextualPrecisionMetric` | `input`, `actual_output`, `expected_output`, `retrieval_context` | weighted cumulative precision over ranked retrieved nodes | Ranking/noise failure: inspect re-ranking and ordering. It rewards relevant nodes earlier in the retrieved list. |
| `ContextualRecallMetric` | `input`, `actual_output`, `expected_output`, `retrieval_context` | attributable statements from `expected_output` / total statements in `expected_output` | Coverage failure: inspect whether retrieval surfaced all evidence needed for the ideal answer. |
| `GEval` (policy correctness) | docs specify `input`, `actual_output`; also provide every field referenced by `evaluation_params`, such as `expected_output` | judge score normalized to 0–1, optionally probability-weighted | Product-policy failure: inspect the explicit evaluation steps and rubric before changing retrieval or generation. |

Primary references: [Faithfulness](https://deepeval.com/docs/metrics-faithfulness), [Answer Relevancy](https://deepeval.com/docs/metrics-answer-relevancy), [Contextual Precision](https://deepeval.com/docs/metrics-contextual-precision), [Contextual Recall](https://deepeval.com/docs/metrics-contextual-recall), [G-Eval](https://deepeval.com/docs/metrics-llm-evals).

### Formula nuances worth preserving

- Faithfulness is officially `truthful claims / total claims`. Current source returns 1 when there are no claim verdicts. By default, a verdict other than `no` is counted as faithful; `penalize_ambiguous_claims=True` changes how `idk` verdicts are treated. Avoid calling the score a calibrated probability. [Docs formula](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/docs/content/docs/%28rag%29/metrics-faithfulness.mdx#L310-L318) · [tagged implementation](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/deepeval/metrics/faithfulness/faithfulness.py#L380-L397)
- Answer Relevancy extracts statements from `actual_output`, classifies each against `input`, and uses their relevant fraction. A verbose preamble can lower the score because it adds judged statements, but that is a consequence of the algorithm, not proof that all verbosity is bad. [Docs formula](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/docs/content/docs/%28rag%29/metrics-answer-relevancy.mdx#L288-L294)
- Contextual Precision judges each retrieved node using `input` and `expected_output`, then applies weighted cumulative precision. `actual_output` remains part of the documented required test-case contract even though the formula is intended to isolate retrieval ranking. [Required fields and formula](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/docs/content/docs/%28rag%29/metrics-contextual-precision.mdx#L18-L26) · [calculation](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/docs/content/docs/%28rag%29/metrics-contextual-precision.mdx#L313-L337)
- Contextual Recall judges statements extracted from `expected_output` against `retrieval_context`; it deliberately does not use the generated answer as the reference for coverage. [Required fields](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/docs/content/docs/%28rag%29/metrics-contextual-recall.mdx#L20-L29) · [formula](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/docs/content/docs/%28rag%29/metrics-contextual-recall.mdx#L321-L333)

## Fault-isolation matrix for the article

Treat this as an engineering diagnostic, not a proof of root cause.

| Observed pattern | First subsystem to investigate | Why |
| --- | --- | --- |
| Low faithfulness, adequate contextual recall | Generator grounding | The required evidence was retrieved, but claims are not supported by it. |
| Low contextual recall | Retriever coverage | Evidence needed by the ideal answer was not attributable to retrieved nodes. |
| Adequate contextual recall, low contextual precision | Ranking and retrieval noise | Needed evidence exists in the list, but relevant nodes are not ranked cleanly enough. |
| Low answer relevancy while grounding and retrieval metrics are adequate | Prompt or generator focus | The response drifts even though the evidence path appears healthy. |
| RAG quartet healthy, policy G-Eval low | Product rules / answer contract | Generic mechanics pass, but the answer violates a domain-specific requirement. |

Use “first investigate” language. A metric localizes evidence, but it does not uniquely prove the causal fix.

## G-Eval details

- Supply **either** `criteria` or `evaluation_steps`, not both. If only `criteria` is supplied, DeepEval generates evaluation steps; explicit steps skip that generation stage and improve control across runs. [Official G-Eval docs](https://deepeval.com/docs/metrics-llm-evals#evaluation-steps)
- Pass only parameters actually referenced by the criteria/steps. The official docs warn that irrelevant `evaluation_params` degrade evaluation accuracy. [Tagged docs source](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/docs/content/docs/%28custom%29/metrics-llm-evals.mdx#L96-L115)
- Without a rubric, the current implementation's raw score range is 0–10. It then normalizes using `(raw - min) / (max - min)`. When supported log probabilities are available, DeepEval probability-weights candidate numeric score tokens; otherwise it falls back to the raw integer before normalization. [Default score range](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/deepeval/metrics/g_eval/utils.py#L402-L406) · [normalization](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/deepeval/metrics/g_eval/g_eval.py#L147-L158) · [log-probability weighting](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/deepeval/metrics/g_eval/utils.py#L337-L383)
- Rubric score bands must be non-overlapping integer ranges within 0–10; they constrain the raw judge score and the selected minimum/maximum become the normalization range. [Rubric implementation](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/deepeval/metrics/g_eval/utils.py#L35-L50)
- G-Eval remains non-deterministic. DAG provides more controlled score mapping, but its branch decisions can still be LLM-based. Say “more deterministic control,” not “fully deterministic execution.” [DAG comparison](https://deepeval.com/docs/metrics-dag)

## Hallucination metric: mandatory correction

The copied draft describes Hallucination as “contradicted contexts / total contexts,” says lower is better, and calls its threshold a maximum. That is obsolete in 4.2.0.

Current 4.2.0 behavior is:

```text
Hallucination score = aligned contexts / total contexts
```

Therefore **higher is better**, 1 is perfect, and `threshold` is a minimum. The metric requires `input`, `actual_output`, and curated ground-truth `context`; DeepEval recommends Faithfulness instead for RAG's live `retrieval_context`. [Current Hallucination docs](https://deepeval.com/docs/metrics-hallucination) · [tagged implementation](https://github.com/confident-ai/deepeval/blob/python-v4.2.0/deepeval/metrics/hallucination/hallucination.py#L249-L260)

## Agent metrics: correct current framing

DeepEval 4.2.0 lists six agent metrics at two scopes:

- Complete-trajectory metrics: `TaskCompletionMetric`, `StepEfficiencyMetric`, `PlanAdherenceMetric`, `PlanQualityMetric`. These require tracing and evaluate the ordered trace.
- Component-level action metrics: `ToolCorrectnessMetric`, `ArgumentCorrectnessMetric`. These diagnose the LLM span that selects tools and produces arguments.

For a five-slot **RAG** article, mention these as replacements when the evaluated system is agentic, not as add-ons that exceed the metric budget. `TaskCompletionMetric` is the broad success signal; `ToolCorrectnessMetric` is the narrower tool-selection diagnostic. Tool Correctness requires `input`, `actual_output`, `tools_called`, and `expected_tools`; by default it matches tool names deterministically, with optional stricter argument/output/order checks. Supplying `available_tools` adds an LLM optimality judgment and the final score is the minimum of the deterministic and LLM scores. [Agent metric scopes](https://deepeval.com/guides/guides-ai-agent-evaluation-metrics) · [Tool Correctness](https://deepeval.com/docs/metrics-tool-correctness) · [Task Completion](https://deepeval.com/docs/metrics-task-completion)

## Corrections and qualifications to the copied source

| Copied claim | Rewrite decision |
| --- | --- |
| “Written against DeepEval v4.1.0” | Update to v4.2.0 and date the verification. |
| Hallucination is lower-is-better and its threshold is a maximum | Remove. This is false in 4.2.0; all current metric directions are higher-is-better. |
| “Every metric returns a written reason by default” | Safer: DeepEval metrics expose `reason`; these discussed metrics default `include_reason=True`. Avoid universal phrasing where a metric may not expose the same option. |
| “Faithfulness 0.75 means one claim in four was unsupported” | Qualify: it means roughly 75% of extracted claim verdicts counted as truthful under the judge/template settings. It is not model confidence. |
| “The highest-value metric in the framework” / “Correctness is the most-used metric” | These are unsupported rankings. Present them as this article's recommendation for the support-RAG scenario, not official fact. |
| “Right chunks retrieved, ranked badly (re-ranker)” | Use “first inspect ordering, re-ranking, and retrieval noise”; do not imply a unique root cause. |
| Fixed thresholds 0.8/0.7/0.7/0.7/0.6 | Label as illustrative product gates. Official defaults are all 0.5. |
| “DAG is deterministic” | Say DAG controls score mapping more tightly; LLM-based branch decisions can still vary. |
| “Scores are ratios of judged sub-decisions” | Limit this explanation to the ratio-based RAG metrics. G-Eval and several other metrics use different scoring procedures. |

## Primary-source set for the final article

1. [DeepEval 4.2.0 release](https://github.com/confident-ai/deepeval/releases/tag/python-v4.2.0)
2. [Metric introduction, selection guidance, and thresholds](https://deepeval.com/docs/metrics-introduction)
3. [Faithfulness](https://deepeval.com/docs/metrics-faithfulness)
4. [Answer Relevancy](https://deepeval.com/docs/metrics-answer-relevancy)
5. [Contextual Precision](https://deepeval.com/docs/metrics-contextual-precision)
6. [Contextual Recall](https://deepeval.com/docs/metrics-contextual-recall)
7. [G-Eval](https://deepeval.com/docs/metrics-llm-evals)
8. [Hallucination](https://deepeval.com/docs/metrics-hallucination)
9. [AI agent metric guide](https://deepeval.com/guides/guides-ai-agent-evaluation-metrics)
10. [DAG](https://deepeval.com/docs/metrics-dag)
