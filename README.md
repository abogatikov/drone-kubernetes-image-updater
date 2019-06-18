Drone plugin for Kubernetes
========================

This plugin allows to update a container image of a Kubernetes deployment.

## Usage

This pipeline will update the `web-server` deployment with the image `docker.io/username/webserver:0.0.1`

```yaml
    - name: deploy
      image: docker.io/abogatikov/drone-kubernetes-image-updater
      settings:
       kubernetes_server: https://lb.example.com
       kubernetes_token: PS1...
       kubernetes_cert: YVdObF...
       kubernetes_cluster: cluster.local
       kubernetes_user: drone-deploy
       namespace: web
       deployment: web-server
       repo: docker.io/username/webserver
       container: server
       tag: 0.0.1
```

## Plugin features
 
  - Multiple deployments (e.g. deployment: [`web-test`, `web-stage`])
  - Multiple containers (e.g. containers: [`server`, `worker`]) 
  - Receive tag from previous steps (`echo -n "0.0.1" > /drone/srs/.tags`)

## Required secrets
 
### RBAC

If your cluster is protected by RBAC (role-based access control), it is necessary to create a custom `ServiceAccount` with the appropriate permissions (`ClusterRole` and `ClusterRoleBinding`).

As an example (for the `web` namespace):

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: drone-deploy
  namespace: web
---

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: drone-deploy
  namespace: web
rules:
  - apiGroups: ["extensions"]
    resources: ["deployments"]
    verbs: ["get","list","patch","update"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: drone-deploy
subjects:
  - kind: ServiceAccount
    name: drone-deploy
    namespace: web
roleRef:
  kind: ClusterRole
  name: drone-deploy
  apiGroup: rbac.authorization.k8s.io
```

### Retrieve tokens and certificates

1. Get token of secret `drone`
```bash
kubectl -n web describe secret $(kubectl -n web get secret |grep drone |awk '{print $1}')
```
2. Get data of k8s cert
```bash
SECRET_NAME=$(kubectl -n web get secret |grep drone |awk '{print $1}')
kubectl -n web get secret $SECRET_NAME -o "jsonpath={.data['ca\.crt']}"
```

## License

[MIT](LICENSE) © [Alex Bogatikov](https://github.com/abogatikov) 
