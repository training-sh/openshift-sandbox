# 20 — Deploy MySQL

Complete [00-get-started](../00-get-started/README.md) and open your assigned OpenShift project in the browser. This lab deploys one MySQL pod, an internal Service, and a 1 GiB storage claim.

## Import the YAML

Use the same import steps for each file in the table.

1. In the OpenShift console, check that your assigned project is selected.
2. Select the **+** icon in the top bar to open **Import YAML**. In the Developer perspective, you can also look for **+Add → Import YAML**.
3. Open the file on GitHub and select **Raw**. Copy the full contents into the console editor, replacing any example text.
4. Confirm the project shown in the import screen, then select **Create**. Repeat for the next file.

| Order | File | Creates |
| --- | --- | --- |
| 1 | [02-mysql-secret.yaml](../manifests/02-mysql-secret.yaml) | The MySQL username, password, and root password |
| 2 | [03-workload-account.yaml](../manifests/03-workload-account.yaml) | The service account used by MySQL |
| 3 | [20-mysql-service.yaml](../manifests/20-mysql-service.yaml) | The internal Service at `mysql:3306` |
| 4 | [20-mysql-pvc.yaml](../manifests/20-mysql-pvc.yaml) | The 1 GiB storage claim |
| 5 | [20-mysql.yaml](../manifests/20-mysql.yaml) | The MySQL StatefulSet |

Use the project assigned to you during sign-in. The [project reference manifest](../manifests/00-project.yaml) is for environments with project creation permissions. If the shared service account already exists in your project, continue with the MySQL manifest.

## Verify MySQL

1. In the **Administrator** perspective, open **Workloads → Pods** and select `mysql-0`. If you are in the Developer perspective, open **Topology**, select MySQL, and follow the pod link under **Resources**.
2. Wait for the pod to show **Running** and its container to show **Ready**. The readiness check signs in as `team` and runs `SELECT 1` against the lab database.
3. If the pod stays pending, check its **Events** tab and confirm **Storage → PersistentVolumeClaims → mysql-data** becomes **Bound**. Use the pod's **Logs** tab for startup errors.

| Setting | Lab value |
| --- | --- |
| MySQL address inside the project | `mysql:3306` |
| Database | `hive_metastore` |
| Lab user | `team` |
| Lab password | `team1234` |
| Root password | `team1234` |

If the pod's **Terminal** tab is available, you can run this optional check there in the browser. Enter `team1234` when MySQL asks for the password.

```bash
mysql -h 127.0.0.1 -u team -p hive_metastore -e 'SELECT DATABASE(), 1 AS mysql_ready;'
```

The result should show `hive_metastore` and `1`.
