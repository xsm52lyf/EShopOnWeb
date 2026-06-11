```mermaid
graph LR
    %% ==========================================
    %% 1. 样式与视觉定义
    %% ==========================================
    classDef devStyle fill:#f4ebff,stroke:#7f56d9,stroke-width:2px;
    classDef gitStyle fill:#e0f2fe,stroke:#0284c7,stroke-width:2px;
    classDef ciStyle fill:#fff7ed,stroke:#ea580c,stroke-width:2px;
    classDef cdStyle fill:#f0fdf4,stroke:#16a34a,stroke-width:2px;
    classDef k8sStyle fill:#eff6ff,stroke:#2563eb,stroke-width:2px;

    %% ==========================================
    %% 2. 核心流程节点
    %% ==========================================
    Dev["🧑‍💻 开发者 (Developer)"]:::devStyle
    GitHub["🐙 GitHub Repo<br>(Source of Truth)"]:::gitStyle
    
    %% CI 阶段
    subgraph CI_Pipeline ["🚀 GitHub Actions CI 流水线"]
        CI_Run["运行 CI 任务"]:::ciStyle
        CI_Tasks["▪️ dotnet build & test<br>▪️ SonarCloud 代码扫描<br>▪️ Docker Build & Tag<br>▪️ Trivy 镜像安全扫描<br>▪️ Push to ECR"]
        CI_Run --- CI_Tasks
    end

    %% 路由分水岭
    Filter{"⚡ 路径过滤<br>(Path Filter)"}:::ciStyle

    %% 基础设施轨道
    subgraph Infra_Track ["🛠️ IaC 基础设施轨道 (GitHub Actions)"]
        TF_Init["1. Validate & Plan"]:::ciStyle
        TF_Appr{"2. Manual Approval<br>(仅 Prod)"}:::ciStyle
        TF_Apply["3. Terraform Apply"]:::ciStyle
        
        TF_Init --> TF_Appr
        TF_Appr -->|Approved| TF_Apply
    end

    %% GitOps 应用轨道
    subgraph Service_Track ["🐙 GitOps 应用部署轨道 (ArgoCD)"]
        Argo_Watch["1. 自动监控 Manifest"]:::cdStyle
        Argo_Sync["2. Kustomize 镜像版本更新<br>(dev/test/perf/prod)"]:::cdStyle
        
        Argo_Watch --> Argo_Sync
    end

    %% 最终目标
    K8s["☸️ Kubernetes 集群<br>(EKS / AKS)"]:::k8sStyle

    %% ==========================================
    %% 3. 连接上下游线（纯单向流，杜绝算法死循环）
    %% ==========================================
    Dev -->|"1. git push"| GitHub
    GitHub -->|"2. PR 合并到 main"| CI_Run
    CI_Tasks --> Filter

    Filter -->|"路径包含 infra/"| TF_Init
    Filter -->|"路径包含 src/"| Argo_Watch

    TF_Apply -->|"4. 更新集群基础资源"| K8s
    Argo_Sync -.->|"4. 自动同步应用 Pods"| K8s