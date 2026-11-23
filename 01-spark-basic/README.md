# 01 — Spark basics

Open [JupyterLab through the OpenShift Route](../00-setup/README.md#jupyterlab).

1. Download [spark-basic.ipynb](spark-basic.ipynb) using GitHub’s **Download raw file** button.
2. In JupyterLab, use **Upload Files** in the file browser, then open the notebook.
3. Select the **Python 3** kernel if prompted and choose **Run → Run All Cells**.

The notebook uses one local Spark thread in the JupyterLab pod. It shows the filtered totals and the SQL counts below.

## Run as an OpenShift Job

1. Use **Import YAML** to create [21-spark-basic-code.yaml](../manifests/21-spark-basic-code.yaml).
2. Import [21-spark-basic.yaml](../manifests/21-spark-basic.yaml) to start the Job.
3. In the **Administrator** perspective, open **Workloads → Pods** and select the pod whose name begins with `spark-basic-`. Open **Logs** and look for `SPARK_BASIC_PASS`.

The Spark program builds a DataFrame from four orders, filters to orders worth at least 1,000 cents, and groups them by category. A separate Spark SQL query counts all orders through the temporary `orders` view.

| Category | Filtered total in cents | Order count before filtering |
| --- | ---: | ---: |
| books | 1200 | 2 |
| games | 2500 | 2 |

Try changing the filter in `orders.py` to 500 cents and updating the expected books total to 2,000. In **Workloads → ConfigMaps → spark-basic-code**, edit the script in the **YAML** tab and save. Delete the completed `spark-basic` Job in **Workloads → Jobs**, then reimport the Job YAML. It reads the updated ConfigMap when its new pod starts.
