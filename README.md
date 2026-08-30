# Coraline Challenge: Platform Engineer

| Task | Deliverable | Location |
|---|---|---|
| 1 | Terraform for Metabase and PostgreSQL, usable over the web, database not publicly reachable | [`part1-infrastructure/`](part1-infrastructure/) |
| 2 | Architecture and CI/CD design for a multi-service internal application | [`part2-architecture/`](part2-architecture/) |

## Part 1

Metabase on Cloud Run, PostgreSQL on Cloud SQL with no public IP, connected over VPC
peering. Secrets in Secret Manager.

```bash
cd part1-infrastructure
cp terraform.tfvars.example terraform.tfvars   # set project_id
terraform init && terraform apply
open "$(terraform output -raw metabase_url)"
```

Or locally, with no cloud account:

```bash
docker compose -f part1-infrastructure/local/docker-compose.yml up -d
```

Deploy steps, verification, assumptions and trade-offs, including why Cloud Run rather
than a VM, are in [`part1-infrastructure/README.md`](part1-infrastructure/README.md).

## Part 2

| Document | Covers |
|---|---|
| [`architecture.md`](part2-architecture/architecture.md) | architecture diagram, environments, config and secrets, external and on-premise connections, monitoring and alerting |
| [`cicd.md`](part2-architecture/cicd.md) | CI and deploy flows, promotion between environments, infrastructure pipeline, DAGs, migrations, rollback |

Cloud Run for web, API and worker. Cloud Composer for Airflow. One GCP project per
environment, same Terraform with different tfvars. Identity-Aware Proxy handles
sign-in. One image per commit, deployed unchanged to dev, staging and prod. Secrets in
Secret Manager, as in Part 1.
