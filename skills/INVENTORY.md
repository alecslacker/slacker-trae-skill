# SKILL INVENTORY — 384 Skill (Auto-Generated)

> **JANGAN EDIT MANUAL** — di-regenerate oleh scripts/update-inventory.ps1
> (dipanggil otomatis oleh collect.ps1 step 2.6) tiap ada skill tambah/kurang.
> Sumber data: folder skills/ + plugin TRAE lokal (~/.trae/plugins/trae-remote-official)
> + upstream-manifest.json.
> Cek update skill GitHub eksternal: .\scripts\check-upstream.ps1

Diperbarui: 2026-10-30 | Total: **384** skill

## Ringkasan Sumber

| Sumber | Jumlah | Cara update |
|---|---|---|
| Kurasi pack / internal | 39 | Manual — skill standalone terkurasi + buatan sendiri |
| Plugin resmi TRAE | 94 | scripts/export-plugins.ps1 (-Force untuk timpa) |
| Repo GitHub eksternal | 251 | scripts/check-upstream.ps1 |

## Kurasi Pack / Internal (39)

agent-browser, brand-guidelines, byteplus-seedream5, canvas-design, chart-visualization, consulting-analysis, data-analysis, electron, figma, frontend-design, frontend-skill, gh-cli, git-commit, hook-analyzer-skill, html-deck, html-report, laravel-dev, local-computer-use, local-realtime-translator, marketing-tools, mcp-builder, obsidian-bases, obsidian-cli, obsidian-markdown, ppt-page, prd-builder, rab-builder, react-native-skills, redis-development, report-generator-skill, report-page, screenshot, security-best-practices, shadcn, slides, theme-factory, webapp-testing, web-artifacts-builder, web-design-guidelines

## Plugin Resmi TRAE (94)

Dihasilkan export-plugins.ps1 dari ~/.trae/plugins/trae-remote-official/ (plugin terikat MCP
TRAE-only tidak diekspor; format: nama skill — plugin asal).

- accessibility-and-inclusive-visualization — build-web-data-visualization
- agent-entrypoint-design — agent-harness-skills
- agent-ledger-and-delivery — agent-harness-skills
- agenttrace-session-audit — agenttrace
- ai-agent-bench — development-skills
- align-docs — development-skills
- atomic-commit-discipline — agent-harness-skills
- best-practices — development-skills
- brainstorming — development-skills
- canvas2d-data-visualization — build-web-data-visualization
- changelog-forge — changelog-forge
- claude-code-harness — claude-code-harness
- claude-to-agents — development-skills
- commit — development-skills
- commit-narrator — commit-narrator
- core-dev — development-skills
- create-test — development-skills
- d3-data-visualization — build-web-data-visualization
- dashboards-and-real-time-visualization — build-web-data-visualization
- data-visualization — build-web-data-visualization
- debugging — development-skills
- design-doc-and-task-board — agent-harness-skills
- dev-auto — dev-skills
- dev-code-review — dev-skills
- dev-commit-writer — dev-skills
- dev-design-context — dev-skills
- dev-finish — dev-skills
- dev-fix — dev-skills
- dev-grill-docs — dev-skills
- dev-plan — dev-skills
- dev-spec — dev-skills
- dev-tdd — dev-skills
- dev-verify — dev-skills
- dispatching-parallel-agents — superpowers
- distill — development-skills
- eval-regression — development-skills
- executing-plans — superpowers
- finishing-a-development-branch — superpowers
- frontend-app-builder — build-web-apps
- frontend-dev — development-skills
- frontend-testing-debugging — build-web-apps
- gantt-chart-visualization — build-web-data-visualization
- geospatial-and-cartographic-visualization — build-web-data-visualization
- grammar-of-graphics-and-declarative-visualization — build-web-data-visualization
- handoff — development-skills
- ingest-feedback — development-skills
- java-dev — development-skills
- node-link-and-diagram-layout — build-web-data-visualization
- pdf-monster — pdf-monster
- personal-data-protection — personal-data-protection
- produce-feedback — development-skills
- python-dev — development-skills
- quality-gardening — agent-harness-skills
- react-and-nextjs-data-visualization — build-web-data-visualization
- react-best-practices — build-web-apps
- receiving-code-review — superpowers
- repo-contracts-and-boundaries — agent-harness-skills
- repo-harness-assessment — agent-harness-skills
- reports-pdfs-and-slide-automation — build-web-data-visualization
- requesting-code-review — superpowers
- resolve-merge — development-skills
- roast-my-code — development-skills
- runtime-evidence-and-tracing — agent-harness-skills
- scrollytelling-and-parallax-data-visualization — build-web-data-visualization
- separateweb-capture — separateweb-capture
- shadcn-best-practices — build-web-apps
- simple-man — simple-man
- spec-workflow — spec-driven
- staff-engineer-mode — staff-engineer-mode
- staff-review — development-skills
- statistical-and-uncertainty-visualization — build-web-data-visualization
- stripe-best-practices — build-web-apps
- subagent-driven-development — superpowers
- supabase-best-practices — build-web-apps
- swift-dev — development-skills
- systematic-debugging — superpowers
- test-driven-development — superpowers
- testing-data-visualizations — build-web-data-visualization
- threejs-data-visualization — build-web-data-visualization
- typescript-data-visualization-engineering — build-web-data-visualization
- typescript-dev — development-skills
- uml-and-software-architecture-visualization — build-web-data-visualization
- update-precommit — development-skills
- update-reqs — development-skills
- update-reqs-dev — development-skills
- using-development-skills — development-skills
- using-git-worktrees — superpowers
- using-superpowers — superpowers
- validation-harness-design — agent-harness-skills
- verification-before-completion — superpowers
- visualization-strategy-and-critique — build-web-data-visualization
- writers-loop — writers-loop
- writing-plans — superpowers
- writing-skills — superpowers

## Repo GitHub Eksternal (251)

Sumber + versi tercatat di upstream-manifest.json. Keluarga skill dikelompokkan per repo asal.

### AgriciDaniel/claude-blog (3544423 (2026-10-14), dicek 2026-10-30)

- blog
- blog-analyze
- blog-audio
- blog-audit
- blog-brand
- blog-brief
- blog-calendar
- blog-cannibalization
- blog-chart
- blog-cluster
- blog-decay
- blog-discourse
- blog-factcheck
- blog-flow
- blog-geo
- blog-google
- blog-image
- blog-locale-audit
- blog-localize
- blog-multilingual
- blog-notebooklm
- blog-outline
- blog-persona
- blog-repurpose
- blog-rewrite
- blog-schema
- blog-seo-check
- blog-strategy
- blog-style
- blog-taxonomy
- blog-translate
- blog-write

### BagelHole/DevOps-Security-Agent-Skills (0365f57 (2026-05-22), dicek 2026-10-30)

- access-review
- agent-evals
- agent-observability
- ai-agent-security
- ai-coding-agent-guardrails
- ai-inference-service-mesh
- ai-pipeline-orchestration
- ai-red-teaming
- ai-security-hardening
- ai-sre-incident-response
- alerting-oncall
- argocd-gitops
- arm-templates
- asset-inventory
- audit-logging
- aws-cloudtrail
- aws-cost-optimization
- aws-ec2
- aws-ecs-fargate
- aws-iam
- aws-lambda
- aws-rds
- aws-s3
- aws-secrets-manager
- aws-vpc
- azure-aks
- azure-devops
- azure-functions
- azure-keyvault
- azure-monitor-audit
- azure-networking
- azure-sql
- azure-vms
- backup-recovery
- block-storage
- blue-green-deploy
- business-continuity
- cdn-setup
- change-management
- circleci
- cis-benchmarks
- cloudflare-pages
- cloudflare-r2
- cloudflare-workers
- cloudflare-zero-trust
- cloudformation
- container-hardening
- container-registries
- container-scanning
- convex-backend
- dast-scanning
- database-backups
- datadog
- dependency-scanning
- devcontainers-nix
- disaster-recovery
- dns-management
- docker-compose
- docker-management
- ebpf-observability
- elk-stack
- feature-flags
- fedramp-compliance
- firebase-app-platform
- firewall-config
- gcp-audit-logs
- gcp-cloud-functions
- gcp-cloud-sql
- gcp-compute
- gcp-gke
- gcp-networking
- gcp-secret-manager
- gdpr-compliance
- github-actions
- gitlab-ci
- git-workflow
- gpu-kubernetes-operations
- gpu-server-management
- hashicorp-vault
- helm-charts
- hipaa-compliance
- identity-access-management
- incident-management
- incident-response
- iso27001-compliance
- jenkins
- kubernetes-hardening
- kubernetes-ops
- kustomize
- linux-administration
- linux-hardening
- llm-app-security
- llm-caching
- llm-cost-optimization
- llm-fine-tuning
- llm-gateway
- llm-inference-scaling
- llmops-platform-engineering
- load-balancing
- loki-logging
- mac-mini-llm-lab
- mcp-server-security
- mdm-device-management
- model-registry-governance
- model-serving-kubernetes
- model-supply-chain-security
- mongodb
- multi-tenant-llm-hosting
- mysql
- new-relic
- nfs-storage
- object-storage
- ollama-stack
- openclaw-deployment-hardening
- openclaw-local-mac-mini
- openclaw-security-hardening
- openshift
- opentelemetry
- opentofu-migration
- pci-dss-compliance
- penetration-testing
- performance-tuning
- planetscale
- platform-engineering
- podman
- policy-as-code
- postgresql
- prometheus-grafana
- prompt-injection-defense
- rag-infrastructure
- rag-observability-evals
- redis
- reverse-proxy
- runbook-creation
- saas-security-posture
- sast-scanning
- sbom-supply-chain
- security-automation
- semantic-versioning
- service-mesh
- soc2-compliance
- sops-encryption
- sre-dashboards
- ssh-configuration
- ssl-tls-management
- startup-it-troubleshooting
- supply-chain-attack-response
- systemd-services
- terraform-aws
- terraform-azure
- terraform-gcp
- threat-modeling
- user-management
- vector-database-ops
- vendor-management
- vercel-deployments
- vllm-server
- vpn-setup
- vulnerability-scanning
- waf-setup
- windows-hardening
- windows-server
- zero-trust

### Cesarjoquin/Marketing-Skills (23b887f (2026-09-14), dicek 2026-10-30)

- ab-testing
- ad-creative
- ads
- ai-seo
- analytics
- aso
- churn-prevention
- cold-email
- co-marketing
- community-marketing
- competitor-profiling
- competitors
- content-strategy
- copy-editing
- copywriting
- cro
- customer-research
- directory-submissions
- emails
- free-tools
- image
- launch
- lead-magnets
- marketing-ideas
- marketing-plan
- marketing-psychology
- offers
- onboarding
- paywalls
- popups
- pricing
- product-marketing
- programmatic-seo
- prospecting
- public-relations
- referrals
- revops
- sales-enablement
- schema
- seo-audit
- signup
- site-architecture
- sms
- social
- video

### currents-dev/playwright-best-practices-skill (283d5cb (2026-07-21), dicek 2026-10-30)

- playwright-best-practices

### kaankiziltug/logo-design-skill (7340903 (2026-10-20), dicek 2026-10-30)

- logo-design

### Leonxlnx/taste-skill (12af471 (2026-10-25), dicek 2026-10-30)

- design-taste-frontend
- full-output-enforcement

### miqdadbadjuber/anti-slop (v3.2.24, dicek 2026-10-30)

- antislop
- antislop-code
- antislop-copywriting
- antislop-human
- antislop-layoutmobile
- antislop-ui

### morluto/rea (v6.8.0, dicek 2026-10-30)

- reverse-engineer-anything

