```mermaid
graph TD
    %% ==========================================
    %% 样式与角色定义
    %% ==========================================
    classDef devStyle fill:#f4ebff,stroke:#7f56d9,stroke-width:2px;
    classDef gitStyle fill:#e0f2fe,stroke:#0284c7,stroke-width:2px;
    classDef ciStyle fill:#fff7ed,stroke:#ea580c,stroke-width:2px;
    classDef cdStyle fill:#f0fdf4,stroke:#16a34a,stroke-width:2px;
    classDef k8sStyle fill:#eff6ff,stroke:#2563eb,stroke-width:2px;

    %% ==========================================
    %% 研发与代码源
    %% ==========================================
    Dev["🧑‍💻 开发者 (Developer)"]:::devStyle
    
    subgraph Repo_Layer [GitHub 源码托管]
        GitHub["🐙 GitHub (Source of Truth)"]:::gitStyle
    end

    Dev -->|"1. git push feature branch"| GitHub

    %% ==========================================
    %% 持续集成 (CI)
    %% ==========================================
    subgraph CI_Layer [持续集成流水线]
        GA_CI["🚀 GitHub Actions CI"]:::ciStyle
        
        subgraph CI_Steps [并行验证任务]
            direction LR
            T1["Build and Test"]
            T2["SonarCloud 扫描"]
            T3["Docker 编译"]
            T4["镜像安全扫描"]
            T5["Push to ECR"]
        end
    end

    GitHub -->|"2. PR 合并到 main 分支"| GA_CI
    GA_CI -->|"3. 触发并行执行"| CI_Steps

    %% ==========================================
    %% 双轨触发器（路径与分支过滤）
    %% ==========================================
    Filter{"⚡ 分支 / 路径过滤过滤 (Path Filter)"}:::ciStyle
    CI_Steps --> Filter

    %% ==========================================
    %% 轨道 A：基础设施流水线 (IaC)
    %% ==========================================
    subgraph Infra_Track [基础设施仓库 - Infra Pipeline]
        direction TB
        GA_Infra["🛠️ Infra CD (GitHub Actions)"]:::ciStyle
        
        subgraph TF_Stages [Terraform 阶段]
            S1["Validate and Lint"] --> S2["Terraform Plan"]
            S2 --> S3{"Manual Approval<br>(仅针对 Prod 环境)"}
            S3 -->|"Approved"| S4["Terraform Apply"]
        end
        
        Env["🌍 环境列表<br>(dev, test, perf, staging, prod)"]
    end
    
    Filter -->|"路径包含 infra/main"| GA_Infra
    GA_Infra --> TF_Stages

    %% ==========================================
    %% 轨道 B：应用部署流水线 (GitOps)
    %% ==========================================
    subgraph Service_Track [应用部署仓库 - Service Pipeline]
        direction TB
        ArgoCD["🐙 Service CD (ArgoCD)"]:::cdStyle
        Argo_Manifest["📋 Kustomize Overlays<br>(dev/test/perf/staging/prod 配置)"]
    end

    Filter -->|"路径包含 src/"| ArgoCD
    ArgoCD -->|"监控并读取最新配置"| Argo_Manifest

    %% ==========================================
    %% 最终交付目标 (Kubernetes)
    %% ==========================================
    subgraph Cluster_Layer [目标运行时环境]
        K8s["☸️ Kubernetes 集群 (EKS / AKS)"]:::k8sStyle
    end

    TF_Stages -->|"5. 基础设施供应/更新"| K8s
    Argo_Manifest -.->|"自动同步到集群<br>(支持蓝绿 / 金丝雀部署)"| K8s
