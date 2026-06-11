# CoreCommerce 项目文件导航

## Document
- [document](./document) - 文档中心

## Kubernetes 资源清单
- [k8s/base/](./k8s/base) - 基础配置层
- [k8s/components/](./k8s/components) - 可复用功能组件
- [k8s/environments/](./k8s/environments) - 环境公共配置
- [k8s/overlays/](./k8s/overlays) - 最终环境入口

## 基础设施即代码 (Terraform)
- [terraform/modules/](./terraform/modules) - 可复用模块
- [terraform/live/dev/](./terraform/live/dev) - DEV 环境
- [terraform/live/test/](./terraform/live/test) - TEST 环境
- [terraform/live/perf/](./terraform/live/perf) - PERF 环境
- [terraform/live/staging/](./terraform/live/staging) - STAGING 环境
- [terraform/live/production/](./terraform/live/production) - PRODUCTION 环境

## CI/CD 流水线
- [.github/workflows/infra-pipeline.yml](./.github/workflows/infra-pipeline.yml)
- [.github/workflows/service-pipeline.yml](./.github/workflows/service-pipeline.yml)
- [.github/scripts/](./.github/scripts) - 辅助脚本