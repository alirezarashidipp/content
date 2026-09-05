# Choosing the Right Model for Production AI — research brief

Research date: 2026-09-04  
Article target: a long-form, 10+ minute standalone article for Ali Reza Rashidi's personal website  
Anchor: [Modular LLM Inference Handbook — Choosing the right model](https://handbook.modular.com/getting-started/choosing-the-right-model/)  
Source policy: the Modular handbook is the anchor; technical claims are checked against official documentation, original model cards, source repositories, standards bodies, and original research papers.

## Editorial conclusion

The useful lesson in the Modular page is its taxonomy: base versus post-trained models, dense versus sparse architectures, specialist components, model hubs, and weight formats. But taxonomy is only the start of a production decision.

The article should argue that **model selection is a constrained optimization problem, not a leaderboard lookup**. Start with the behavior the application must produce, eliminate candidates that fail legal, security, modality, runtime, and deployment constraints, then compare the survivors on a task-specific evaluation set and the actual serving stack. Optimize quality until the release threshold is met; only then minimize cost and latency without crossing that threshold. This ordering matches current OpenAI model-selection guidance and the task-specific evaluation guidance from both OpenAI and Anthropic.

For a durable article, avoid ranking current model names. Prices, model catalogs, and benchmark leaders change too quickly. Teach the reader how to build a repeatable selection process.

Sources: [OpenAI model selection](https://developers.openai.com/api/docs/guides/model-selection) · [OpenAI evaluation best practices](https://developers.openai.com/api/docs/guides/evaluation-best-practices) · [Anthropic: define success criteria and build evaluations](https://platform.claude.com/docs/en/test-and-evaluate/develop-tests)

## Recommended running example

Use one fictional but concrete production workload throughout:

> A support copilot receives English and Persian customer messages, retrieves the relevant refund policy, classifies the issue, and returns a strict JSON object plus a short draft reply. It serves 40 requests per second at peak. The product target is at least 95% correct routing, no unsupported refund claims, P95 time-to-first-token below 800 ms, and a fixed monthly inference budget.

This example makes every tradeoff observable:

- A base model may be an awkward default because the application requires reliable instruction following and a response schema.
- A chat/instruct model still needs the correct chat template and application-supplied history.
- An embedding model should retrieve policy text; the generative model should not be forced to perform vector search.
- A large model may establish the quality ceiling, while a smaller or quantized candidate may meet the same release threshold more cheaply.
- A sparse MoE candidate may have low active compute but still require memory for its total weights and communication-aware serving.
- The winner is the model-and-runtime configuration that passes the workload's quality and SLO gates, not the model with the largest public benchmark score.

## A production selection framework

### Gate 1 — Write the workload contract

Record the task, input and output modalities, languages, context distribution, output schema, tool-use needs, safety requirements, concurrency, latency SLOs, monthly volume, and privacy or residency constraints. “Best model” has no meaning until these are fixed.

Use metrics that match how the system is consumed. For interactive chat, time to first token and inter-token latency matter. For a multi-step agent, end-to-end latency matters because later steps often cannot proceed until earlier calls finish. For offline work, aggregate throughput and unit cost may dominate. Average latency alone hides tail behavior, so production comparisons should include P95 or P99 and the fraction of requests that meet the SLO (“goodput”).

Sources: [Modular: key metrics for LLM inference](https://handbook.modular.com/llm-inference-basics/llm-inference-metrics/) · [vLLM benchmark commands](https://docs.vllm.ai/en/stable/cli/bench/)

### Gate 2 — Choose the model class before the model name

First decide what kind of component the application needs:

- **Generative base model:** useful when continuing pretraining, conducting model research, or applying custom post-training. Usually not the simplest production default for an end-user assistant.
- **Instruction/chat model:** a post-trained causal language model intended to respond to user or developer instructions. Suitable for drafting, extraction, classification, dialogue, and tool selection when its template and interface are respected.
- **Embedding model:** maps text or images to vectors for retrieval, similarity, clustering, and recommendation. It is a distinct component, not a smaller chat model.
- **Reranker or classifier:** often a better primitive than a general generator when the output is a relevance score or a fixed label.
- **Vision-language, speech, or image model:** required when the input or output modality goes beyond text. Converting every modality to prose can lose information and add latency.

The Modular page is right that modern systems often compose models. The caveat is that each extra component adds a versioned interface, a failure mode, latency, monitoring, and operational cost. Add a specialist only when the system-level evaluation shows it earns its place.

Sources: [Hugging Face Sentence Transformers](https://huggingface.co/docs/hub/sentence-transformers) · [Google Gemini model catalog](https://ai.google.dev/gemini-api/docs/models) · [Hugging Face model tasks and repositories](https://huggingface.co/docs/hub/models)

### Gate 3 — Eliminate candidates that cannot be operated legally and safely

For hosted APIs, inspect data controls, region availability, rate limits, deprecation policy, stable model identifiers, tool support, and provider terms. For open weights, inspect the exact license text, model card, repository history, tokenizer/config files, weight format, supported runtimes, and whether access is gated.

“Available on a model hub” does not mean “open source,” production-ready, or commercially usable. The Open Source Initiative's definition requires freedoms to use, study, modify, and share, plus access to the preferred form for modification; merely publishing weights is not enough to establish all of those properties. Hugging Face license and task fields are repository metadata supplied by model publishers. They improve discovery, but they are not an independent legal or quality certification.

Gating also has a precise, narrower meaning than the Modular page implies: Hugging Face says a gated model requires an individual user to request access and share information with the model authors. Approval may be automatic or manual, and the author may later revoke it. Gating by itself does **not** prove that the license is stricter, the model is less polished, or the service is less reliable.

Sources: [Hugging Face model cards](https://huggingface.co/docs/hub/model-cards) · [Hugging Face gated models](https://huggingface.co/docs/hub/models-gated) · [Hugging Face model release checklist](https://huggingface.co/docs/hub/model-release-checklist) · [Open Source AI Definition 1.0](https://opensource.org/ai/open-source-ai-definition)

### Gate 4 — Establish a quality ceiling, then reduce cost

Start with a capable candidate and a fixed evaluation set. Reach the quality target with the complete system: prompt, retrieval, tools, response schema, safety checks, and retry policy. Then test smaller models, shorter contexts, lower reasoning settings, quantized weights, caching, or routing. A cheaper model is only cheaper if retries, escalations, longer outputs, and downstream corrections do not erase the saving.

OpenAI's current selection guide explicitly recommends optimizing for accuracy first and then preserving that accuracy with the cheapest and fastest option. This is a useful process principle even when the candidates come from other providers or are self-hosted.

Source: [OpenAI model selection](https://developers.openai.com/api/docs/guides/model-selection)

### Gate 5 — Benchmark the exact deployable artifact

A model name is not a deployable unit. Record at least:

- model repository and immutable revision or API snapshot;
- base/post-trained variant and exact chat template;
- weight format and quantization method;
- inference engine and version;
- tensor/expert/data parallel configuration;
- hardware and driver/runtime versions;
- maximum tested input/output lengths, batch distribution, and concurrency;
- sampling and reasoning settings.

Compare quality, memory, TTFT, TPOT/ITL, end-to-end latency, throughput, goodput, failure rate, and total cost on the same traffic distribution. Public model benchmarks may identify candidates, but they cannot replace a workload benchmark.

Sources: [OpenAI evaluation best practices](https://developers.openai.com/api/docs/guides/evaluation-best-practices) · [Modular inference metrics](https://handbook.modular.com/llm-inference-basics/llm-inference-metrics/) · [Hugging Face: load a specific model revision](https://huggingface.co/docs/hub/transformers) · [vLLM benchmark commands](https://docs.vllm.ai/en/stable/cli/bench/)

## Technical findings to carry into the article

### Base, instruct, and chat models

A causal language model always continues a token sequence. A base model is first trained with a language-modeling objective on a large corpus. Post-training then changes how that model responds to instructions or conversations. The InstructGPT paper is a clean historical demonstration: supervised demonstrations and preference-based reinforcement learning made a 1.3B post-trained model preferable to a 175B pretrained model on that paper's prompt distribution. Parameter count alone therefore does not determine usefulness for an interactive application.

The Modular page's “unsupervised learning” wording should be modernized to **self-supervised next-token prediction**. Its statement that a base model “does not understand how to follow instructions” is too categorical. Base models can exhibit in-context and few-shot behavior, but they were not optimized for the interaction contract of an assistant.

The instruct-versus-chat distinction is also not a reliable naming rule across vendors. Hugging Face currently notes that many chat models are called “instruct” or “instruction-tuned.” What matters operationally is the model card and tokenizer's chat template. The application converts role/content messages into one token sequence with model-specific control tokens; using the wrong template can substantially degrade behavior.

A chat model is not inherently stateful. The application or provider sends the conversation history again, and the template serializes it. “Maintains multi-turn dialogue” means the model was trained to interpret that serialized history, not that the weights remember previous API calls.

Sources: [Hugging Face chat templates](https://huggingface.co/docs/transformers/chat_templating) · [Hugging Face chat basics](https://huggingface.co/docs/transformers/conversations) · [Ouyang et al., Training language models to follow instructions with human feedback](https://arxiv.org/abs/2203.02155)

### Dense versus sparse Mixture-of-Experts models

In a dense transformer block, the same trainable feed-forward parameters participate for each token. A sparse MoE block contains multiple learnable subnetworks and a router that selects a subset for each token. Mixtral 8x7B, for example, has eight feed-forward experts per layer and routes each token to two; its paper reports 47B total parameters and 13B active parameters per token.

Two cautions matter in production:

1. An “expert” is not necessarily a human-legible “math expert” or “code expert.” Hugging Face's current MoE implementation guide explicitly says it is simply a learnable subnetwork. Empirical specialization can be shallow, overlapping, or inconsistent across layers.
2. Sparse activation reduces per-token arithmetic relative to using all parameters, but the full model weights still need to be stored or distributed. Expert parallelism also introduces routing and communication. All-to-all communication, load imbalance, batch shape, kernels, and hardware topology can determine whether theoretical compute savings become real latency or throughput gains.

The right comparison is therefore **quality and serving behavior on the target stack**, not total parameters versus active parameters in isolation.

Sources: [Jiang et al., Mixtral of Experts](https://arxiv.org/abs/2401.04088) · [Fedus et al., Switch Transformers](https://arxiv.org/abs/2101.03961) · [Hugging Face: Mixture of Experts in Transformers](https://huggingface.co/blog/moe-transformers) · [Hugging Face: Mixture of Experts Explained](https://huggingface.co/blog/moe)

### Model hubs, cards, and licenses

A model hub is a discovery and distribution system. A repository may contain weights, configuration, tokenizer, generation defaults, code, adapters, quantized derivatives, evaluation metadata, and a model card. Read all of them together.

The model card should state intended use, out-of-scope use, limitations, training information, datasets, and evaluation results. “Should” is important: cards are authored documents and vary in completeness. A production review should verify:

- the exact publisher or organization;
- the base-model lineage and whether the artifact is a merge, adapter, or quantized derivative;
- license metadata against the actual license file and commercial scenario;
- training-data disclosures and known limitations;
- evaluation protocol, model revision, prompt/template, and hardware;
- required `trust_remote_code` or other executable model code;
- immutable revision and artifact integrity.

For gated models, account-based approval and token management become deployment dependencies. Use a least-privilege read token and plan for the possibility that access changes.

Sources: [Hugging Face model cards](https://huggingface.co/docs/hub/model-cards) · [Hugging Face annotated model card](https://huggingface.co/docs/hub/model-card-annotated) · [Hugging Face gated models](https://huggingface.co/docs/hub/models-gated) · [Hugging Face access tokens](https://huggingface.co/docs/hub/security-tokens)

### PyTorch checkpoints, Safetensors, and GGUF

These formats solve different packaging and runtime problems:

- **PyTorch checkpoints** commonly use `torch.save`/`torch.load`. PyTorch documents that `torch.load` uses an unpickler and warns never to load untrusted data. Current `torch.load` exposes `weights_only=True`, which restricts the unpickler to tensors, primitive types, dictionaries, and explicitly allowlisted types. The risk belongs to pickle-based deserialization and executable custom code—not to every file with `.pt` or `.bin` in every loading path.
- **Safetensors** stores tensor metadata plus raw tensor data without the pickle mechanism. Its project documents safe, lazy, memory-mapped access and recommends forcing Safetensors when consuming remote artifacts. It also recommends pinning a repository revision. Safetensors protects the weight-deserialization boundary; it does not make arbitrary accompanying Python code, tokenizer code, or the model's behavior trustworthy. “Zero-copy” also needs a caveat: GPU loading still involves transfer, and the format's header is not zero-copy.
- **GGUF** is a versioned binary container used by the GGML/llama.cpp ecosystem. It can include architecture, tokenizer, license, quantization, and tensor metadata alongside the tensors. Quantization is optional in the specification, so a GGUF file is not automatically a quantized model. `llama.cpp` requires GGUF and provides conversion and quantization tools, making it a strong local-inference format when the selected architecture and quantization are supported.

Format selection follows the runtime: Safetensors is common in Python/GPU inference stacks; GGUF is native to llama.cpp and local CPU/GPU deployments. Converting the same source weights can create behaviorally different artifacts if quantization or tensor transformations change.

Sources: [PyTorch `torch.load`](https://docs.pytorch.org/docs/stable/generated/torch.load.html) · [Safetensors repository](https://github.com/safetensors/safetensors) · [Safetensors security guidance](https://github.com/safetensors/safetensors/security) · [GGUF specification](https://github.com/ggml-org/ggml/blob/master/docs/gguf.md) · [llama.cpp](https://github.com/ggml-org/llama.cpp)

### Quantization, memory, cost, and latency

Quantization represents weights and sometimes activations or caches with lower-precision types. It can reduce memory and computational cost, and it may enable a model that otherwise would not fit. Hugging Face documents 8-bit and 4-bit loading plus algorithms such as AWQ and GPTQ; its bitsandbytes integration says 8-bit weight loading roughly halves weight memory.

Do not translate that into “half the latency” or “no quality loss.” Speed depends on hardware support, kernels, batching, memory bandwidth, dequantization overhead, and the rest of the graph. Accuracy effects depend on the quantization algorithm, calibration data, model, task, and bit width. Benchmark the exact quantized artifact against the unquantized baseline.

The quick weight-memory estimate is:

```text
weight bytes ≈ total parameter count × bits per parameter / 8
```

That is not a serving-capacity estimate. KV cache grows with sequence length and concurrent requests; activations, workspace buffers, framework allocations, and CUDA graphs add memory. Hugging Face's estimator explicitly says its model-size result covers loading, not full inference, and Modular likewise warns that a 7B FP16 model's roughly 14 GB of weights can leave too little headroom on a 16 GB GPU for long contexts or concurrency.

For MoE, use **total** parameter count to reason about resident weight storage and **active** parameter count as one signal about per-token compute. The official Qwen3-30B-A3B card makes the distinction concrete: 30.5B total parameters, 3.3B activated parameters, 128 experts, and 8 activated experts. The `A3B` suffix describes active parameters, not “three activated experts.”

Sources: [Hugging Face quantization](https://huggingface.co/docs/transformers/main_classes/quantization) · [Hugging Face bitsandbytes](https://huggingface.co/docs/bitsandbytes/index) · [Hugging Face Accelerate memory estimator](https://huggingface.co/docs/accelerate/package_reference/cli#accelerate-estimate-memory) · [Modular GPU memory guide](https://handbook.modular.com/getting-started/calculating-gpu-memory-for-llms/) · [Qwen3-30B-A3B model card](https://huggingface.co/Qwen/Qwen3-30B-A3B)

### Evaluation-based selection

Build a held-out set that mirrors production traffic and includes typical, edge, and adversarial cases. For the support-copilot example, measure at least:

- issue-routing accuracy by language and issue type;
- schema validity and required-field completion;
- groundedness against the retrieved policy;
- false claims about refunds or account actions;
- correct abstention/escalation when evidence is missing;
- tool-call correctness;
- output length and retry rate;
- TTFT, TPOT/ITL, end-to-end latency, and P95/P99;
- cost per successful request, not just cost per token.

Use deterministic graders for schemas, labels, and tool arguments; calibrated human review or carefully validated model graders for nuance. Compare candidates with the same dataset, prompt, context, and sampling policy. Keep evaluation logs and turn production failures into regression cases.

Model behavior can change between API snapshots, and repositories can change at `main`. Pin versions and re-run the evaluation suite on every model, prompt, retrieval, runtime, or quantization change.

Sources: [OpenAI evaluation best practices](https://developers.openai.com/api/docs/guides/evaluation-best-practices) · [Anthropic evaluation guidance](https://platform.claude.com/docs/en/test-and-evaluate/develop-tests) · [OpenAI API backward compatibility](https://platform.openai.com/docs/api-reference/backward-compatibility) · [Hugging Face Safetensors security guidance](https://github.com/safetensors/safetensors/security)

## Claim-by-claim caveats for the Modular anchor

| Modular claim or framing | Verdict | Article-safe treatment |
| --- | --- | --- |
| Base models are trained through “unsupervised learning” | **Imprecise** | Say self-supervised language-model pretraining, usually next-token prediction. |
| A base model “does not yet understand how to follow instructions” | **Too categorical and anthropomorphic** | Say it was not post-trained for the assistant interaction contract; it may still show instruction-like or few-shot behavior. |
| “Instruct” and “chat” are distinct stages, with chat typically further tuned | **Useful teaching simplification, not a naming standard** | Names are inconsistent across families; inspect the model card and required chat template. Many current chat models are called instruct models. |
| Chat models maintain context across turns | **Needs an application-state caveat** | The caller normally resends history; the chat template serializes messages into tokens. The model is not automatically persistent across requests. |
| MoE experts each focus on different types of data or tasks | **Misleading literal interpretation** | Experts are learned subnetworks selected by a router. They are not guaranteed to map to human-named domains; observed specialization can be weak or shallow. |
| MoE gives efficient scaling and manageable per-inference compute | **Directionally correct, incomplete** | Active compute can be much smaller than total capacity, but total weights, routing, all-to-all communication, load balance, kernels, and hardware topology still matter. |
| Small language models can serve as fallbacks or on-device assistants | **Plausible pattern, not a rule** | A small model is useful only if it passes the task and safety gates. Routing and fallback logic add failure modes. |
| Modern applications rarely use one LLM | **Common pattern, not a requirement** | Compose specialists when system evals justify them; the simplest passing architecture is easier to operate. |
| Hugging Face is the default starting point for most teams | **Editorial/generalized** | Describe it as a major model hub. Do not present one hub as a universal default. |
| Hugging Face provides clear cards with license, benchmarks, and intended use | **Normative, not guaranteed** | Those fields are supported and recommended, but cards are publisher-authored and may be missing, stale, or incomplete. Verify the artifact and license. |
| Gated models often have stricter terms, less polish, or fewer availability guarantees | **Unsupported generalization** | Gating means access requests and identity sharing. Evaluate the actual license, repository, and access policy separately. |
| PyTorch checkpoint formats allow arbitrary code execution | **Real risk, needs scope** | Pickle-based loading of untrusted checkpoints is dangerous. Current `torch.load(weights_only=True)` narrows deserialization; arbitrary custom repository code remains a separate risk. |
| Safetensors provides safe, fast memory mapping | **Supported with boundaries** | It prevents pickle-style code execution from the weight file and supports lazy/mapped access. It does not certify the whole repository, and GPU transfer is not literally zero-copy. |
| GGUF models are quantized | **Often true, not inherent** | GGUF is a container that supports both quantized and non-quantized tensors; inspect tensor types and metadata. |
| Q4, Q5, or Q8 shows how aggressively the model is compressed | **Roughly useful, underspecified** | Lower bit widths usually mean more compression, but scheme variants, calibration, tensor exceptions, and runtime kernels affect quality and speed. |
| `Qwen3.5-35B-A3B`'s two numbers indicate total experts and activated experts | **Incorrect** | They indicate about 35B total parameters and 3B active parameters. The [official Qwen3.5 card](https://huggingface.co/Qwen/Qwen3.5-35B-A3B) separately reports 256 experts and 8 routed plus 1 shared expert. |
| Read the model card to learn what the model is good and bad at | **Good first step, insufficient for production** | Read it, verify license and lineage, then run a task-specific evaluation on the exact artifact and stack. |

## Recommended long-form article structure

Suggested title: **The Model Is Not the Product — A Production Guide to Choosing the Right LLM**

Target editorial length: approximately 1,900–2,400 English words, excluding source list; roughly 10–13 minutes at a technical reading pace.

1. **01 — Start with the workload, not the leaderboard**  
   Define the support-copilot contract and show why accuracy, latency, cost, safety, and operability form a constraint set.
2. **02 — Choose the right kind of intelligence**  
   Explain base/instruct/chat without false boundaries; introduce embedding, reranking, vision, and speech specialists.
3. **03 — Read the architecture and artifact correctly**  
   Dense versus MoE, total versus active parameters, model-card/license review, PyTorch/Safetensors/GGUF.
4. **04 — Budget the real system**  
   Quantization, weight memory versus KV cache, latency/throughput/goodput, hosted API versus self-hosted tradeoffs.
5. **05 — Let your evaluation choose**  
   Candidate funnel, task-specific test set, Pareto frontier, pinning, regression evaluation, and rollout.
6. **Sources**

Recommended diagrams, all conceptual or explicitly labeled as estimates:

- **Constraint funnel:** workload contract → capability gate → legal/operational gate → quality eval → serving benchmark → selected configuration.
- **Two parameter budgets:** a dense block versus an MoE block, showing resident total weights separately from active per-token compute.
- **Memory stack:** weights + KV cache + activations/workspace, with a caption warning that parameter math is only the floor.
- **Quality/cost frontier:** hypothetical candidates labeled A–E, with an explicit note that numbers are illustrative; alternatively avoid invented values and use an unscaled decision matrix.

## Primary-source set for the article

1. [Modular — Choosing the right model](https://handbook.modular.com/getting-started/choosing-the-right-model/)
2. [Modular — Calculating GPU memory for serving LLMs](https://handbook.modular.com/getting-started/calculating-gpu-memory-for-llms/)
3. [Modular — Key metrics for LLM inference](https://handbook.modular.com/llm-inference-basics/llm-inference-metrics/)
4. [OpenAI — Model selection](https://developers.openai.com/api/docs/guides/model-selection)
5. [OpenAI — Evaluation best practices](https://developers.openai.com/api/docs/guides/evaluation-best-practices)
6. [Anthropic — Define success criteria and build evaluations](https://platform.claude.com/docs/en/test-and-evaluate/develop-tests)
7. [Hugging Face — Chat templates](https://huggingface.co/docs/transformers/chat_templating)
8. [Ouyang et al. — Training language models to follow instructions with human feedback](https://arxiv.org/abs/2203.02155)
9. [Jiang et al. — Mixtral of Experts](https://arxiv.org/abs/2401.04088)
10. [Fedus et al. — Switch Transformers](https://arxiv.org/abs/2101.03961)
11. [Hugging Face — Mixture of Experts in Transformers](https://huggingface.co/blog/moe-transformers)
12. [Qwen — Qwen3-30B-A3B model card](https://huggingface.co/Qwen/Qwen3-30B-A3B)
13. [Qwen — Qwen3.5-35B-A3B model card](https://huggingface.co/Qwen/Qwen3.5-35B-A3B)
14. [Hugging Face — Model cards](https://huggingface.co/docs/hub/model-cards)
15. [Hugging Face — Gated models](https://huggingface.co/docs/hub/models-gated)
16. [Open Source Initiative — Open Source AI Definition 1.0](https://opensource.org/ai/open-source-ai-definition)
17. [PyTorch — `torch.load`](https://docs.pytorch.org/docs/stable/generated/torch.load.html)
18. [Safetensors — repository and format rationale](https://github.com/safetensors/safetensors)
19. [Safetensors — security guidance](https://github.com/safetensors/safetensors/security)
20. [GGML — GGUF specification](https://github.com/ggml-org/ggml/blob/master/docs/gguf.md)
21. [llama.cpp — official repository](https://github.com/ggml-org/llama.cpp)
22. [Hugging Face — Quantization](https://huggingface.co/docs/transformers/main_classes/quantization)
23. [Hugging Face — Accelerate memory estimator](https://huggingface.co/docs/accelerate/package_reference/cli#accelerate-estimate-memory)
24. [vLLM — Benchmark CLI](https://docs.vllm.ai/en/stable/cli/bench/)
