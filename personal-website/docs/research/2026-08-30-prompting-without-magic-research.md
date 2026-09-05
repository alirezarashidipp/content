# Prompting Without Magic — research brief

Research date: 2026-08-30  
Article target: *Prompting Without Magic — Six Principles That Survive Model Changes*  
Source policy: official OpenAI, Anthropic, and Google documentation plus original research papers. The copied article is treated as an untrusted lead, not a source.

## Editorial conclusion

The durable story is not “six tricks that always improve every model.” It is a specification-and-evaluation discipline: define success, state the task and constraints, provide missing evidence, demonstrate difficult patterns when needed, structure the input, then test the whole prompt against the exact model and workload. Provider guidance now diverges most sharply around reasoning: older instruction-tuned models sometimes benefited from visible chain-of-thought prompts, while current reasoning models often reason internally and expose controls such as `reasoning_effort`, adaptive thinking, or thinking levels. The article should call the principles **durable defaults with model-specific exceptions**, not universal laws.

## Six defensible principles

### 1. Define success before polishing prose

Prompt quality is only meaningful relative to a task-specific outcome. OpenAI recommends scoped, real-distribution evals, typical/edge/adversarial cases, continuous evaluation, and human calibration; Anthropic likewise begins prompt engineering with measurable success criteria and task-specific tests. For the running duplicate-payment example, success can be tested: identify invoice `INV-2047`, avoid inventing refund status, request only missing evidence, and return the required support format.

Sources: [OpenAI evaluation best practices](https://developers.openai.com/api/docs/guides/evaluation-best-practices) · [Anthropic: define success and build evaluations](https://platform.claude.com/docs/en/test-and-evaluate/develop-tests)

### 2. State the job, constraints, and output contract explicitly

OpenAI, Anthropic, and Google all recommend clear, specific instructions. Durable details include the task, audience, permitted evidence, hard constraints, desired format, and criteria for a successful response. Avoid contradictory requirements: OpenAI's GPT-5 guide warns that careful instruction following can spend reasoning effort trying to reconcile vague or conflicting instructions. A role label may help set scope or tone, but it is not a substitute for the actual requirements.

Sources: [OpenAI prompt engineering](https://developers.openai.com/api/docs/guides/prompt-engineering) · [OpenAI GPT-5 prompting guide](https://developers.openai.com/cookbook/examples/gpt-5/gpt-5_prompting_guide) · [Anthropic prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) · [Google prompt design strategies](https://ai.google.dev/gemini-api/docs/prompting-strategies)

### 3. Supply the context the model cannot infer

Context is useful when it contains facts or policies necessary to solve the task: payment records, company refund rules, the customer's message, or definitions of ambiguous fields. Anthropic also notes that explaining the motivation behind a rule can help the model generalize toward the intended behavior. Do not turn this into “put everything upfront.” For long-document inputs, both Anthropic and current Gemini guidance recommend placing the data first and the query near the end; unnecessary context can add cost, distraction, and attack surface.

Sources: [Anthropic prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) · [Google prompt design strategies](https://ai.google.dev/gemini-api/docs/prompting-strategies) · [OpenAI GPT-4.1 prompting guide](https://developers.openai.com/cookbook/examples/gpt4-1_prompting_guide)

### 4. Show the pattern when instructions alone leave ambiguity

Few-shot examples can teach output format, tone, scope, and mappings. OpenAI recommends diverse desired examples; Anthropic calls examples a reliable steering method and suggests relevant, diverse, structured examples; Google recommends consistent formatting and warns that too many examples can overfit the response pattern. The correct workflow is model-dependent: OpenAI's reasoning-model guide says try zero-shot first and add closely aligned examples only when needed. There is no provider-independent optimum of three, four, or five examples.

Sources: [OpenAI prompt engineering](https://developers.openai.com/api/docs/guides/prompt-engineering#few-shot-learning) · [OpenAI reasoning best practices](https://developers.openai.com/api/docs/guides/reasoning-best-practices) · [Anthropic prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) · [Google prompt design strategies](https://ai.google.dev/gemini-api/docs/prompting-strategies)

### 5. Separate sections for interpretation, not for security

Markdown headings, XML tags, or other consistent delimiters help distinguish instructions, context, examples, and variable input. Anthropic recommends descriptive XML tags for complex prompts; OpenAI accepts Markdown, XML, and section titles; Google recommends consistent XML-style tags or Markdown headings. Format choice is contextual: GPT-4.1's long-context tests found XML effective and JSON poor for a specific multi-document setup, while the same guide says JSON is well understood in coding contexts and warns that XML can be less effective when the documents themselves contain XML.

Delimiters **do not prevent prompt injection**. OpenAI describes prompt injection as an open industry security problem requiring defense in depth: instruction hierarchy, safety training, monitoring, sandboxing, restricted capabilities, confirmations, and source-to-sink controls. The original indirect-prompt-injection paper shows the underlying problem: applications blur the line between data and instructions. Treat untrusted content as untrusted even when it sits inside `<context>` tags.

Sources: [OpenAI reasoning best practices](https://developers.openai.com/api/docs/guides/reasoning-best-practices) · [OpenAI GPT-4.1 delimiter guidance](https://developers.openai.com/cookbook/examples/gpt4-1_prompting_guide) · [Anthropic prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) · [Google prompt design strategies](https://ai.google.dev/gemini-api/docs/prompting-strategies) · [OpenAI: understanding prompt injections](https://openai.com/index/prompt-injections/) · [OpenAI: designing agents to resist prompt injection](https://openai.com/index/designing-agents-to-resist-prompt-injection/) · [Greshake et al., indirect prompt injection](https://arxiv.org/abs/2302.12173)

### 6. Let the model's reasoning interface determine the technique, then iterate

Historical CoT results are real but bounded. Wei et al. showed that chain-of-thought demonstrations improved arithmetic, commonsense, and symbolic-reasoning benchmarks in sufficiently large models; Kojima et al. showed gains from “Let's think step by step” on specific 2022 models and benchmarks. These results do not establish a timeless prompt suffix.

Current guidance differs by model:

- OpenAI reasoning models: keep prompts simple; avoid requests to expose chain-of-thought; try zero-shot first; use explicit success constraints and the model's reasoning controls.
- Gemini 2.5/3: internal thinking is automatic, so visible reasoning steps are generally unnecessary; a request to think harder can increase thinking-token cost on difficult tasks.
- Current Claude models: adaptive thinking and `effort` govern internal work; general goals are preferred over a hand-written reasoning script. Manual CoT remains a fallback when thinking is disabled, not a universal default.

Prompt chaining remains distinct: it splits a workflow into inspectable or enforceable calls. Use it when intermediate outputs need validation, separate tools, or deterministic pipeline gates—not merely to make an answer look thoughtful.

Sources: [Wei et al., Chain-of-Thought Prompting](https://arxiv.org/abs/2201.11903) · [Kojima et al., Zero-Shot Reasoners](https://arxiv.org/abs/2205.11916) · [OpenAI reasoning best practices](https://developers.openai.com/api/docs/guides/reasoning-best-practices) · [Google prompt design strategies](https://ai.google.dev/gemini-api/docs/prompting-strategies) · [Anthropic prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)

## Claim-by-claim decisions for the copied text

| Copied claim | Verdict | Safe rewrite / reason |
| --- | --- | --- |
| Structured prompt engineering produces an average 67% productivity improvement | **Reject** | No identified primary source supports this cross-organization average. Remove it. |
| Vagueness is the single most common prompting failure | **Unsupported ranking** | Clear, specific instructions are strongly supported; “single most common” is not. |
| Context is underrated and often matters more than any prompting technique | **Directionally supported, comparison unsupported** | Provide information and motivation needed for the task. Do not rank context above all other interventions without a defined experiment. |
| Put all relevant constraints upfront | **Qualify** | Make constraints explicit, but placement depends on model and context length. In long-context tasks, current Anthropic and Gemini guidance puts documents first and the query/instructions at the end. |
| Few-shot is the single most reliable steering technique | **Provider-specific, not universal** | Anthropic describes examples as highly reliable; OpenAI reasoning guidance says zero-shot first. Add examples when evals show a need. |
| Include 3–5 examples; returns diminish after 4–5 | **Partly verified, overstated** | Anthropic currently recommends 3–5. Google says experiment and warns about too many examples. No universal optimum or general diminishing-return boundary is established. |
| XML is preferred by Anthropic and strongly validated by OpenAI | **Qualify** | Anthropic recommends XML for complex prompts. GPT-4.1 found it effective in long-context tests. Format performance is model-, task-, and input-dependent. |
| JSON performs poorly for multi-document prompting | **Narrowly verified** | GPT-4.1 reported poor JSON performance in its own long-context tests, while also calling JSON well understood for coding. Do not generalize across models or structured-output APIs. |
| Delimiters defend against prompt injection | **Reject as a security claim** | They improve parsing but are not a security boundary. Use instruction hierarchy, least privilege, sandboxing, confirmations, monitoring, and source/sink controls. |
| “Think step by step” improves complex reasoning | **Historically verified, no longer universal** | It improved specified 2022 model/benchmark combinations. Current reasoning models often think internally; follow model-specific guidance and evals. |
| CoT costs 3–5× more tokens and 10× more compute | **Reject** | No general primary-source basis for these multipliers. Cost depends on model, reasoning setting, task, output policy, caching, and API accounting. Say only that more visible or internal reasoning can increase latency and token cost. |
| CoT works mainly on 100B+ models | **Obsolete generalization** | Early CoT work observed scale effects in the tested model families. Parameter count is neither a sufficient nor current cross-model decision rule, especially for post-trained reasoning models. |
| SCoT improves HumanEval by up to 13.79% | **Verified only as a narrow result** | Li et al. reported up to 13.79% Pass@1 improvement over standard CoT for code generation on tested ChatGPT/Codex settings. It is not a general prompting gain. [Original paper](https://arxiv.org/abs/2305.06599) |
| Explicit CoT degrades o3 and o4-mini | **Stronger than the official evidence** | OpenAI says it is unnecessary for reasoning models, not that it always degrades them. Phrase as “can add no value or interfere; test it,” unless a model/task-specific evaluation is cited. |
| Role prompts have little or no effect on correctness | **Supported for factual QA, not all tasks** | Zheng et al. found no aggregate improvement across 2,410 factual questions and four model families; effects varied by persona and model. Anthropic still recommends roles for behavior and tone. Use roles for scope/voice, not as an accuracy guarantee. [Zheng et al.](https://arxiv.org/abs/2311.10054) |
| The Prompt Report's mention count proves role prompting is ineffective | **Reject inference** | Frequency in a survey taxonomy does not measure causal effectiveness. The survey is useful for vocabulary, not this conclusion. [The Prompt Report](https://arxiv.org/abs/2406.06608) |
| Prompt compression removes 50–65% without quality loss | **Reject as a universal range** | Research reports task-specific tradeoffs: Selective Context cut context cost 50% with small but nonzero metric drops; LLMLingua reported up to 20× compression with little loss on four datasets; LLMLingua-2 tested 2–5× ratios. Compression must be evaluated for the target task. [Selective Context](https://arxiv.org/abs/2310.06201) · [LLMLingua](https://arxiv.org/abs/2310.05736) · [LLMLingua-2](https://arxiv.org/abs/2403.12968) |
| Threatening the model no longer works and is actively counterproductive | **Overstated** | A 2025 controlled report found no meaningful overall accuracy gain from threats or tips, but effects varied by question. “No reliable benefit” is supportable; “always counterproductive” is not. [Wharton GAIL report](https://gail.wharton.upenn.edu/research-and-insights/techreport-threaten-or-tip/) |
| Positive instructions are better than negative framing | **Good default, not a law** | OpenAI and Anthropic recommend saying what to do instead of only what not to do. Keep necessary prohibitions, but pair them with the desired alternative behavior. [OpenAI guidance](https://help.openai.com/en/articles/6654000-how-to-use-advanced-prompt-engineering) · [Anthropic guidance](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) |
| The exact `Role → Instructions → Reasoning Steps → Output → Examples → Context → think step by step` order is OpenAI's universal structure | **Reject as current universal guidance** | It was a GPT-4.1 “good starting point” that explicitly allowed sections to be added or removed. Its final CoT suffix conflicts with current OpenAI reasoning-model guidance. Use a compact task-specific structure and test it. |

## Recommended article framing

Use the duplicate-payment support case throughout. Show the prompt evolving from a vague request into a small executable specification:

1. **Goal:** determine what can be concluded about invoice `INV-2047`.
2. **Evidence:** supplied ledger rows and support policy only.
3. **Constraints:** do not claim a refund was issued unless the evidence says so; ask for the transaction identifier if missing.
4. **Output:** a concise customer reply plus an internal next-action field.
5. **Examples:** add only if zero-shot tests mis-handle tone, missing evidence, or output shape.
6. **Evaluation:** test normal, incomplete, conflicting, and adversarial inputs across a pinned model snapshot.

The two proposed diagrams are evidence-safe if they remain conceptual rather than numerical:

- **Anatomy of a prompt:** goal → evidence/context → constraints → output contract → optional examples.
- **Evaluation loop:** baseline → task-specific cases → observed failure pattern → one targeted revision → regression comparison.

## Primary-source set for the article

1. [OpenAI: Prompt engineering](https://developers.openai.com/api/docs/guides/prompt-engineering)
2. [OpenAI: Reasoning best practices](https://developers.openai.com/api/docs/guides/reasoning-best-practices)
3. [OpenAI: Evaluation best practices](https://developers.openai.com/api/docs/guides/evaluation-best-practices)
4. [OpenAI: GPT-4.1 prompting guide](https://developers.openai.com/cookbook/examples/gpt4-1_prompting_guide)
5. [OpenAI: GPT-5 prompting guide](https://developers.openai.com/cookbook/examples/gpt-5/gpt-5_prompting_guide)
6. [Anthropic: Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
7. [Anthropic: Define success and build evaluations](https://platform.claude.com/docs/en/test-and-evaluate/develop-tests)
8. [Google: Prompt design strategies](https://ai.google.dev/gemini-api/docs/prompting-strategies)
9. [OpenAI: Understanding prompt injections](https://openai.com/index/prompt-injections/)
10. [OpenAI: Designing AI agents to resist prompt injection](https://openai.com/index/designing-agents-to-resist-prompt-injection/)
11. [Wei et al.: Chain-of-Thought Prompting](https://arxiv.org/abs/2201.11903)
12. [Kojima et al.: Large Language Models are Zero-Shot Reasoners](https://arxiv.org/abs/2205.11916)
13. [Greshake et al.: Indirect Prompt Injection](https://arxiv.org/abs/2302.12173)
14. [Zheng et al.: Personas in System Prompts](https://arxiv.org/abs/2311.10054)
15. [Li et al.: Structured Chain-of-Thought for Code Generation](https://arxiv.org/abs/2305.06599)

