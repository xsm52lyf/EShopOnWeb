```mermaid
graph TB
    %% ==========================================
    %% 样式与配色定义
    %% ==========================================
    classDef userStyle fill:#f4ebff,stroke:#7f56d9,stroke-width:2px;
    classDef edgeStyle fill:#e0f2fe,stroke:#0284c7,stroke-width:2px;
    classDef awsStyle fill:#fff7ed,stroke:#ea580c,stroke-width:2px;
    classDef azureStyle fill:#f0fdf4,stroke:#16a34a,stroke-width:2px;

    %% ==========================================
    %% 客户端与全局网络层
    %% ==========================================
    subgraph Client_Layer [用户与边缘访问层]
        Users["👥 用户 (End Users)"]:::userStyle
        
        DNS["🌐 DNS 流量管理<br>Route 53 / Traffic Manager"]:::edgeStyle
        
        CDN["⚡ AWS CloudFront (CDN)<br>缓存静态网页与 S3 文件"]:::edgeStyle
    end

    %% 流量路由 - 修正了括号引起的解析错误
    Users --> DNS
    DNS -->|"2a. 静态请求"| CDN
    DNS -->|"2b. 动态主流量 (Primary)"| ALB
    DNS -->|"2c. 灾备流量 (Failover)"| AGIC

    %% ==========================================
    %% AWS 云主区域
    %% ==========================================
    subgraph AWS [AWS Cloud - us-east-1]
        direction TB
        
        ALB["⚖️ Application Load Balancer"]
        
        subgraph AWS_Private [计算层]
            EKS["☸️ Amazon EKS Cluster<br>CoreCommerce Pods"]
        end

        subgraph AWS_Data [存储层]
            RDS["🗄️ RDS PostgreSQL"]
            AWS_Redis["🚀 ElastiCache Redis"]
            S3["🪣 Amazon S3 Bucket<br>(静态网页/图片资源)"]
        end
        
        ALB --> EKS
        EKS --> RDS
        EKS --> AWS_Redis
        EKS --> S3
    end
    class AWS awsStyle;

    %% CDN 回源
    CDN -.->|"3. 缓存未命中回源"| S3

    %% ==========================================
    %% Azure 云灾备区域
    %% ==========================================
    subgraph Azure [Azure Cloud - eastasia]
        direction TB
        
        AGIC["⚖️ Application Gateway"]

        subgraph Azure_Private [计算层]
            AKS["☸️ Azure AKS Cluster<br>CoreCommerce Pods (DR)"]
        end

        subgraph Azure_Data [存储层]
            SQL["🗄️ Azure SQL DB"]
            Azure_Redis["🚀 Azure Cache for Redis"]
        end
        
        AGIC --> AKS
        AKS --> SQL
        AKS --> Azure_Redis
    end
    class Azure azureStyle;

    %% ==========================================
    %% 跨云数据同步
    %% ==========================================
    RDS -.->|"🔄 数据同步"| SQL
    AWS_Redis -.->|"🔄 缓存同步"| Azure_Redis
