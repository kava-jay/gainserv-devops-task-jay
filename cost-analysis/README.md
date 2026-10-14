# Resource Sizing, Cost, and Shared-Cluster Design

This section explains the choices I made for the Gainserv application and what I would change before running it as part of a larger production EKS cluster.

## Why I chose these CPU and memory values

| Setting | Value |
| --- | --- |
| CPU request | `100m` |
| CPU limit | `500m` |
| Memory request | `64Mi` |
| Memory limit | `128Mi` |
| HPA | 2–5 replicas, 60% CPU target |

The service is a small Node.js Express application, so I started with a modest CPU request rather than reserving half a core for every replica. The `/compute` endpoint is intentionally CPU-heavy; a `500m` CPU limit gives each Pod some room to handle bursts while still putting a cap on how much CPU one replica can consume. I chose `64Mi` requested memory and a `128Mi` limit as starting values for this simple app, not as universal Node.js defaults.

I kept two replicas running so a single Pod restart or rolling replacement would not leave the Service with no healthy endpoints. I capped the HPA at five replicas to keep the load test controlled and avoid unlimited scaling. In the Kubernetes test, CPU load pushed the deployment from two replicas to five; after the load stopped, it scaled back down to two.

These numbers are **initial sizing decisions**, not the result of a full production benchmark. Before production, I would check peak memory usage, CPU throttling, request latency, and OOM events under realistic traffic, then adjust requests and limits. In particular, the synchronous `/compute` handler blocks the Node.js event loop, so adding CPU or replicas is not a substitute for fixing that behavior in the application.

## Which EC2 purchasing options I would use

I would keep a small **On-Demand baseline** for the critical application replicas. That gives the service capacity that does not depend on Spot availability. For extra replicas during spikes and for interruption-tolerant background jobs, I would consider **Spot** capacity across multiple instance families and Availability Zones. I would not put both minimum replicas solely on Spot nodes.

Once the cluster has a few months of steady usage data, I would evaluate a **Compute Savings Plan** for the predictable portion of the EC2 spend. A Savings Plan is a pricing commitment, not a separate node type; it can reduce the cost of eligible On-Demand usage. I would avoid committing based on short-lived test traffic.

For a real EKS deployment, I would also use topology spread constraints and suitable disruption handling so replicas are not concentrated on one node. The existing PodDisruptionBudget helps with voluntary disruptions, but it cannot prevent an involuntary Spot interruption.

## One EKS cost trap: idle worker nodes

A common mistake is assuming that HPA scaling down Pods automatically reduces the EC2 bill. It does not. The cluster can still have underused worker nodes running after traffic drops.

I would track node utilization and **requested** CPU/memory, then use Karpenter or Cluster Autoscaler to consolidate or remove nodes when safe. I would also review instance sizing and set cost-allocation tags so the application's share of cluster spend is visible. I have **not** installed a node autoscaler in this practical; the demonstrated scaling was Pod-level HPA only.

## Security when the cluster hosts other workloads

I treated the cluster as shared infrastructure rather than assuming Gainserv was the only application on it.

**Network:** The application runs in its own `gainserv` namespace. Its NetworkPolicy limits inbound access to Pods in that namespace carrying the `access-gainserv=true` label, and DNS egress is allowed where needed. This is narrower than allowing traffic from every Pod in the cluster. In production, I would also control who can add those labels through Kubernetes RBAC/admission policy, and review required outbound destinations instead of granting blanket egress. Namespace separation alone is not a security boundary.

**IAM:** I defined a dedicated EKS Pod Identity role rather than relying on broad permissions attached to worker nodes. The example trust policy scopes role assumption to the `gainserv` namespace and `gainserv-app` ServiceAccount. The example IAM policy permits `s3:GetObject` only for objects under a specific bucket prefix. Since the current Node.js app does not use S3, I would leave this optional role disabled unless that access becomes necessary. The application also runs without an automatically mounted Kubernetes API ServiceAccount token.
