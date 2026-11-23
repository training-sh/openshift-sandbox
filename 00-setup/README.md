# 00 — Storage and Polaris setup

Complete [00-get-started](../00-get-started/README.md). Follow its **Import a manifest** steps to import each YAML file below into your assigned project. If you completed MySQL, reuse the existing `olist-workloads` service account.

For the Web Terminal alternative, run the command blocks from the cloned `openshift-sandbox` directory with `PROJECT` set to your assigned project.

## 1. Create configuration, Secrets, and the service account

1. [01-config.yaml](../manifests/01-config.yaml)
2. [02-lab-secret.yaml](../manifests/02-lab-secret.yaml)
3. [02-seaweedfs-secret.yaml](../manifests/02-seaweedfs-secret.yaml)
4. [03-workload-account.yaml](../manifests/03-workload-account.yaml)

```bash
oc apply -n "$PROJECT" -f manifests/01-config.yaml
oc apply -n "$PROJECT" -f manifests/02-lab-secret.yaml
oc apply -n "$PROJECT" -f manifests/02-seaweedfs-secret.yaml
oc apply -n "$PROJECT" -f manifests/03-workload-account.yaml
```

## 2. Start PostgreSQL and SeaweedFS

| Order | File |
| --- | --- |
| 1 | [10-postgres-service.yaml](../manifests/10-postgres-service.yaml) |
| 2 | [10-postgres-pvc.yaml](../manifests/10-postgres-pvc.yaml) |
| 3 | [10-postgres.yaml](../manifests/10-postgres.yaml) |
| 4 | [10-seaweedfs-service.yaml](../manifests/10-seaweedfs-service.yaml) |
| 5 | [10-seaweedfs-pvc.yaml](../manifests/10-seaweedfs-pvc.yaml) |
| 6 | [10-seaweedfs.yaml](../manifests/10-seaweedfs.yaml) |

Open **Workloads → Pods** in the **Administrator** perspective. Wait for `postgres-0` and `seaweedfs-0` to be **Running** and **Ready**. If either stays pending, check its **Events** and the claim under **Storage → PersistentVolumeClaims**.

```bash
oc apply -n "$PROJECT" -f manifests/10-postgres-service.yaml
oc apply -n "$PROJECT" -f manifests/10-postgres-pvc.yaml
oc apply -n "$PROJECT" -f manifests/10-postgres.yaml
oc apply -n "$PROJECT" -f manifests/10-seaweedfs-service.yaml
oc apply -n "$PROJECT" -f manifests/10-seaweedfs-pvc.yaml
oc apply -n "$PROJECT" -f manifests/10-seaweedfs.yaml
oc rollout status -n "$PROJECT" statefulset/postgres --timeout=10m
oc rollout status -n "$PROJECT" statefulset/seaweedfs --timeout=10m
```

## 3. Bootstrap and start Polaris

1. Import [11-polaris-bootstrap.yaml](../manifests/11-polaris-bootstrap.yaml). Open **Workloads → Jobs** and wait for `polaris-bootstrap` to show **Complete**. If it fails, open the Job's pod and inspect **Logs** before continuing.
2. Import [12-polaris-service.yaml](../manifests/12-polaris-service.yaml), then [12-polaris.yaml](../manifests/12-polaris.yaml).
3. Open **Workloads → Deployments → polaris** and wait for one ready replica.

Keep the completed bootstrap Job and the PVCs when you return.

```bash
oc apply -n "$PROJECT" -f manifests/11-polaris-bootstrap.yaml
oc wait -n "$PROJECT" --for=condition=complete job/polaris-bootstrap --timeout=10m &&
  oc apply -n "$PROJECT" -f manifests/12-polaris-service.yaml -f manifests/12-polaris.yaml &&
  oc rollout status -n "$PROJECT" deployment/polaris --timeout=10m
```

## 4. Open the lab interfaces

Complete the [Spark image build](../spark-image/README.md) before deploying JupyterLab and Spark Master. Each Route appears under **Networking → Routes** in the assigned project.

### JupyterLab

1. Import [31-jupyter-secret.yaml](../manifests/31-jupyter-secret.yaml). It sets the lab token to `team1234`.
2. Import [31-jupyter-pvc.yaml](../manifests/31-jupyter-pvc.yaml), [31-jupyter-service.yaml](../manifests/31-jupyter-service.yaml), and [31-jupyter.yaml](../manifests/31-jupyter.yaml).
3. Wait for **Workloads → Deployments → spark-jupyter** to show one ready replica. Import [31-jupyter-route.yaml](../manifests/31-jupyter-route.yaml).
4. Open **Networking → Routes → spark-jupyter** and click **Location**. Enter `team1234` in the JupyterLab sign-in form.

JupyterLab saves your notebooks on the `spark-jupyter-notebooks` PVC. Open the [Spark Basics notebook guide](../01-spark-basic/README.md) for the first exercise.

From Web Terminal:

```bash
oc apply -n "$PROJECT" -f manifests/31-jupyter-secret.yaml
oc apply -n "$PROJECT" -f manifests/31-jupyter-pvc.yaml
oc apply -n "$PROJECT" -f manifests/31-jupyter-service.yaml
oc apply -n "$PROJECT" -f manifests/31-jupyter.yaml
oc rollout status -n "$PROJECT" deployment/spark-jupyter --timeout=10m &&
  oc apply -n "$PROJECT" -f manifests/31-jupyter-route.yaml
oc get route spark-jupyter -n "$PROJECT"
```

If JupyterLab is already running with an older token, restart it after applying the updated Secret with `oc rollout restart -n "$PROJECT" deployment/spark-jupyter`.

### SeaweedFS Admin UI

The Route is reachable outside the project. Before creating it, open **Workloads → Secrets → lab-credentials**, use **Edit Secret**, and change only `seaweed-admin-password` to a private password. Then delete the `seaweedfs-0` **pod** from **Workloads → Pods** and wait for its StatefulSet to replace it. The new pod reads the new password and reuses the existing PVC.

1. Import [30-seaweedfs-route.yaml](../manifests/30-seaweedfs-route.yaml).
2. Open **Networking → Routes → seaweedfs-admin** and click its **Location** link.
3. Sign in as `team` using the admin password you set. Browse the `warehouse` bucket. After the Iceberg exercise, look under the `iceberg` prefix.

After editing the Secret and confirming SeaweedFS has restarted with the new password, you can apply the Route from Web Terminal:

```bash
oc apply -n "$PROJECT" -f manifests/30-seaweedfs-route.yaml
oc get route seaweedfs-admin -n "$PROJECT"
```

### Spark Master UI

1. Import [30-spark-master.yaml](../manifests/30-spark-master.yaml), then [30-spark-master-service.yaml](../manifests/30-spark-master-service.yaml), then [30-spark-master-route.yaml](../manifests/30-spark-master-route.yaml).
2. Wait for **Workloads → Deployments → spark-master** to show one ready replica.
3. Open **Networking → Routes → spark-master-ui** and click its **Location** link.

```bash
oc apply -n "$PROJECT" -f manifests/30-spark-master-service.yaml
oc apply -n "$PROJECT" -f manifests/30-spark-master.yaml
oc rollout status -n "$PROJECT" deployment/spark-master --timeout=10m &&
  oc apply -n "$PROJECT" -f manifests/30-spark-master-route.yaml
oc get route spark-master-ui -n "$PROJECT"
```

The standalone dashboard starts with zero workers. The exercises use local-mode Jobs and report their output in pod logs. The dashboard has no sign-in, so delete its Route, Service, and Deployment from the console when the demo is over. You can also delete the SeaweedFS Route from **Networking → Routes** and keep the internal S3 service running.
