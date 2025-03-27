# golang-project-layout

Golang项目结构参考规范

## 简介

该规范考虑平台组项目当前情况，也参考了Go开源生态中一些项目：

- [Kubernetes](https://github.com/kubernetes/kubernetes)
- [Docker](https://github.com/moby/moby)
- [Prometheus](https://github.com/prometheus/prometheus)
- [Influxdb](https://github.com/influxdata/influxdb)
- [Contour](https://github.com/projectcontour/contour)

需要注意的是，这只是一个基础规范，并不能涵盖所有Go项目的场景。

## Go 项目结构

建议的项目结构如下：

```
{project_name}/

    // 核心目录
    cmd/
        {app1}/
            main.go
        {app2}}/
            main.go
    internal/
        app/
            {app1}/
                config/                 # 配置解析
                providers/              # 所有依赖相关的
                cache/user.go
                model/{rest/biz/dao}/
                dao/user.go
                biz/user.go
                rest/rest.go
                rpc/rpc.go
            {app2}/
                ...
        {pkg}/                          # app1, app2 的共享代码
            {private_lib1}/
                ...
            {private_lib2}/
                ...
    pkg/                                # Library code that's ok to use by external applications
        {public_lib1}/
            ...
            go.mod                      # 作为独立的 module 管理
            go.sum
        {public_lib2}/
            ...
            go.mod                      # 作为独立的 module 管理
            go.sum
    thirdparty/                         # External helper tools, forked code and other 3rd party utilities (e.g., Swagger UI).
    api/                                # OpenAPI/Swagger specs, JSON schema files, protocol definition files.
        {app1}/
            rest/
                ...
            grpc/
                hello.proto
                hello.pb.go
                hello_grpc.pb.go
                ...
                go.mod                  # 作为独立的 module 管理
                go.sum
        {app2}/
            rest/
                ...
            grpc/
                ...
    vendor/
        ...

    // CI/CD相关目录
    conf/                               # 配置文件
        {app1}/
            prod/{main.yaml}            # 生产环境配置，如果使用外部配置管理服务保存配置，则无需该目录
            testing/{main.yaml}         # 测试环境配置，如果使用外部配置管理服务保存配置，则无需该目录
            dev/{main.yaml}
        {app2}/
            prod/{main.yaml}
            testing/{main.yaml}
            dev/{main.yaml}
    scripts/                            # Scripts to perform various build, install, analysis, etc operations. These scripts keep the root level Makefile small and simple (e.g., https://github.com/hashicorp/terraform/blob/master/Makefile).
    deploy/                             # IaaS, PaaS, system and container orchestration deployment configurations and templates (docker-compose, kubernetes/helm, mesos, terraform, bosh)
    test/                               # Additional external test apps and test data

    // 周边目录
    docs/                               # Design and user documents (in addition to your godoc generated documentation).
    tools/                              # Supporting tools for this project. Note that these tools can import code from the /pkg and /internal directories.
    assets/                             # Other assets to go along with your repository (images, logos, etc).

    Makefile
    README.md                           # 项目说明
    go.mod
    go.sum
    .gitignore
    .gitlab-ci.yml
    .editorconfig
```

## 核心目录

### /cmd

应用程序入口。不要在这个目录中放置太多代码。如果你认为代码可以导入并在其他项目中使用，那么它应该位于 `/pkg` 目录中。如果代码不是可重用的，或者你不希望其他人重用它，请将该代码放到 `/internal` 目录中。

通常有一个小的 `main` 函数，从 `/internal` 和 `/pkg` 目录导入和调用代码，除此之外没有别的东西。

例子:

- https://github.com/moby/moby/tree/master/cmd
- https://github.com/prometheus/prometheus/tree/master/cmd
- https://github.com/influxdata/influxdb/tree/master/cmd
- https://github.com/kubernetes/kubernetes/tree/master/cmd
- https://github.com/dapr/dapr/tree/master/cmd
- https://github.com/ethereum/go-ethereum/tree/master/cmd
- https://github.com/heptio/ark/tree/master/cmd (just a really small main function with everything else in packages)

### /internal

私有应用程序和库代码。这是你不希望其他人在其应用程序或库中导入代码。`internal` 命名的目录有特殊涵义，更多细节请参阅[Go 1.4 release notes](https://golang.org/doc/go1.4#internalpackages)。

你可以选择向 `internal` 包中添加一些子目录，分开共享和非共享的内部代码。这不是必需的(特别是对于较小的项目)，但是最好有可见的线索来显示预期的包用途。实际应用程序代码可以放在 `/internal/app` 目录下(例如 `/internal/app/restapi` )，共享的代码可以放在 `/internal/pkg` 目录下(例如 `/internal/pkg/myprivatelib` )。

例子：

- https://github.com/grpc-ecosystem/grpc-gateway/tree/master/internal

### /pkg

供其他项目访问使用的library。 如 rest api client 代码适合放在 `/pkg/restclient` 目录。

例子：

- https://github.com/jaegertracing/jaeger/tree/master/pkg
- https://github.com/istio/istio/tree/master/pkg
- https://github.com/GoogleContainerTools/kaniko/tree/master/pkg
- https://github.com/google/gvisor/tree/master/pkg
- https://github.com/google/syzkaller/tree/master/pkg
- https://github.com/perkeep/perkeep/tree/master/pkg
- https://github.com/minio/minio/tree/master/pkg
- https://github.com/heptio/ark/tree/master/pkg
- https://github.com/argoproj/argo/tree/master/pkg
- https://github.com/heptio/sonobuoy/tree/master/pkg
- https://github.com/helm/helm/tree/master/pkg
- https://github.com/kubernetes/kubernetes/tree/master/pkg
- https://github.com/kubernetes/kops/tree/master/pkg
- https://github.com/moby/moby/tree/master/pkg
- https://github.com/grafana/grafana/tree/master/pkg
- https://github.com/influxdata/influxdb/tree/master/pkg
- https://github.com/cockroachdb/cockroach/tree/master/pkg
- https://github.com/derekparker/delve/tree/master/pkg
- https://github.com/etcd-io/etcd/tree/master/pkg
- https://github.com/oklog/oklog/tree/master/pkg
- https://github.com/flynn/flynn/tree/master/pkg
- https://github.com/jesseduffield/lazygit/tree/master/pkg
- https://github.com/gopasspw/gopass/tree/master/pkg
- https://github.com/sosedoff/pgweb/tree/master/pkg
- https://github.com/GoogleContainerTools/skaffold/tree/master/pkg
- https://github.com/knative/serving/tree/master/pkg
- https://github.com/grafana/loki/tree/master/pkg
- https://github.com/bloomberg/goldpinger/tree/master/pkg
- https://github.com/Ne0nd0g/merlin/tree/master/pkg
- https://github.com/jenkins-x/jx/tree/master/pkg
- https://github.com/DataDog/datadog-agent/tree/master/pkg
- https://github.com/dapr/dapr/tree/master/pkg
- https://github.com/cortexproject/cortex/tree/master/pkg
- https://github.com/dexidp/dex/tree/master/pkg
- https://github.com/pusher/oauth2_proxy/tree/master/pkg
- https://github.com/pdfcpu/pdfcpu/tree/master/pkg
- https://github.com/weaveworks/kured/tree/master/pkg
- https://github.com/weaveworks/footloose/tree/master/pkg
- https://github.com/weaveworks/ignite/tree/master/pkg
- https://github.com/tmrts/boilr/tree/master/pkg
- https://github.com/kata-containers/runtime/tree/master/pkg
- https://github.com/okteto/okteto/tree/master/pkg
- https://github.com/solo-io/squash/tree/master/pkg

### /thirdparty

External helper tools, forked code and other 3rd party utilities (e.g., Swagger UI).

如二进制工具、ip库文件、第三方工具

例子：

- https://github.com/kubernetes/kubernetes/tree/master/third_party
- https://github.com/googleapis/google-cloud-go/tree/main/third_party

### /api

[OpenAPI](https://github.com/OAI/OpenAPI-Specification)/[Swagger](https://swagger.io/specification/) specs, [JSON schema](https://json-schema.org/) files, [protocol definition](https://developers.google.com/protocol-buffers/docs/proto3) files.

例子：

- https://github.com/kubernetes/kubernetes/tree/master/api
- https://github.com/moby/moby/tree/master/api

### /vendor

所有依赖的三方的 library。

将依赖的三方 library 放在 `/vendor` 目录下有如下好处：

- 不依赖远程的 git 仓库，在一些网络异常、git仓库服务不可用 情况下也能完成编译。
- 不用下载三方 library，编译速度快

## CI/CD相关目录

### /conf

配置文件目录。按照应用、环境组成子目录。如 `/conf/myapp/dev/`

### /scripts

执行各种构建、安装、分析等操作的脚本。

这些脚本让根目录下的Makefile保持精简(e.g., https://github.com/hashicorp/terraform/blob/master/Makefile).

例子：

- https://github.com/kubernetes/helm/tree/master/scripts
- https://github.com/cockroachdb/cockroach/tree/master/scripts
- https://github.com/hashicorp/terraform/tree/master/scripts


### /deploy

IaaS、PaaS、系统和容器编排相关的部署配置和模板，包括docker-compose、kubernetes/helm、mesos、terraform和bosh等。

### /test

额外的外部测试应用程序和测试数据

例子：

- https://github.com/openshift/origin/tree/master/test (test data is in the /testdata subdirectory)



## 周边目录

### /docs

设计文档和用户文档（godoc生成文档的补充）

例子：

- https://github.com/gohugoio/hugo/tree/master/docs
- https://github.com/openshift/origin/tree/master/docs
- https://github.com/dapr/dapr/tree/master/docs

### /tools

项目支持工具。可以引用 /pkg 和 /internal 下的代码。

例子：

- https://github.com/istio/istio/tree/master/tools
- https://github.com/openshift/origin/tree/master/tools
- https://github.com/dapr/dapr/tree/master/tools

### /assets

Other assets to go along with your repository (images, logos, etc).

## 参考

- [golang-standards/project-layout](https://github.com/golang-standards/project-layout)
- Go Modules
  - https://github.com/golang/go/wiki/Modules
  - https://go.dev/blog/using-go-modules
  - https://golang.org/ref/mod
