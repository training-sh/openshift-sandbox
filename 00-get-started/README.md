# 00 — Get started with OpenShift

Use a web browser to sign in to the Red Hat Developer Sandbox and open your assigned OpenShift project.

## Sign in

1. Open the [Red Hat Developer Sandbox](https://developers.redhat.com/developer-sandbox).
2. Select **Start your sandbox for free**. Sign in with your Red Hat account or register for one if needed. Complete any verification Red Hat requests.
3. Select **Start using your sandbox** when it appears. If the OpenShift sign-in page asks you to choose a provider, select **DevSandbox**.
4. Find the **Red Hat OpenShift** tile on the sandbox dashboard and select **Launch**.

If you already have an OpenShift console URL, open it and sign in with your assigned account.

## Find your project

1. In the OpenShift web console, switch to the **Developer** perspective if the console shows a perspective selector.
2. Open **Topology** and use the **Project** dropdown to select your assigned project. In the Red Hat Developer Sandbox, the development project typically starts with your username and ends in `-dev`.
3. Confirm that your project name appears at the top of the page. Keep this tab open for the next lab.

You’re ready when you can open **Topology** for your project. An empty Topology view is normal for a fresh project. If the assigned project is missing, confirm you signed in with the correct account and that you have access to the project.

## Import a manifest

1. In the lab guide on GitHub, open the linked YAML file, select **Raw**, and copy the full contents.
2. In the OpenShift console, confirm your assigned project and select the **+** icon in the top bar to open **Import YAML**. Some console layouts also offer **+Add → Import YAML** in the Developer perspective.
3. Paste the contents into the editor. Verify the project shown on the import page, then select **Create**.
4. Repeat for each file in the guide, in the order listed. If a resource already exists, open its details and check that it matches the lab before continuing.

In the **Administrator** perspective, use **Workloads → Pods** for pod status, logs, and events. Your project permissions also apply in this perspective.

## Optional Git access

If your console offers **Web Terminal**, open it in your assigned project. Run the commands below to clone the repository and find its manifests. [Red Hat Web Terminal guide](https://developers.redhat.com/articles/2024/09/02/explore-full-capabilities-web-terminal-operator)

```bash
git --version
git clone https://github.com/training-sh/openshift-sandbox.git
cd openshift-sandbox
ls manifests
```

To deploy from the browser, open [manifests](../manifests) on GitHub and follow **Import a manifest** above.

## References

- [Red Hat’s guide to accessing the Developer Sandbox](https://developers.redhat.com/articles/2023/03/30/how-access-developer-sandbox-red-hat-openshift)
- [Red Hat’s guide to the OpenShift console and project selection](https://developers.redhat.com/learning/learn%3Aopenshift%3Ainstall-and-configure-developer-hub/resource/resources%3Ainstall-red-hat-developer-hub-on-developer-sandbox)
