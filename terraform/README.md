# 📘 Configure Workload Identity Federation with GitHub

![image](https://github.com/user-attachments/assets/3c822f5e-4957-4500-858c-76f6221a4e9c)

## This guide describes how to use Workload Identity Federation with 

Traditionally, authenticating from GitHub Actions to Google Cloud required exporting and storing a long-lived JSON service account key, turning an identity management problem into a secrets management problem. Not only did this introduce additional security risks if the service account key were to leak, but it also meant developers would be unable to authenticate from GitHub Actions to Google Cloud if their organization has disabled service account key creation (a common security best practice) via organization policy constraints like constraints/iam.disableServiceAccountKeyCreation

But now, with GitHub's introduction of OIDC tokens into GitHub Actions Workflows, you can authenticate from GitHub Actions to Google Cloud using Workload Identity Federation, removing the need to export a long-lived JSON service account key.

![image](https://github.com/user-attachments/assets/7da46e2e-e196-496e-87a5-9a986063ab6b)

## A new GitHub Action – auth!

To ease the process of authenticating and authorizing GitHub Actions Workflows to Google Cloud via Workload Identity Federation, we are introducing a new GitHub Action – auth! The auth action joins our growing collection of Google-managed GitHub Actions and makes it simple to set up and configure authentication to Google Cloud:

```bash
steps:
- id: 'auth'
  name: 'Authenticate to Google Cloud'
  uses: 'google-github-actions/auth@v0.4.0'
  with:
    workload_identity_provider: 'projects/123456789/locations/global/workloadIdentityPools/my-pool/providers/my-provider'
    service_account: 'my-service-account@my-project.iam.gserviceaccount.com'
```


## Setting up Identity Federation for GitHub Actions

To use the new GitHub Actions auth action, you need to set up and configure Workload Identity Federation by creating a Workload Identity Pool and Workload Identity Provider:

```bash
gcloud iam workload-identity-pools create "my-pool" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --display-name="Demo pool"
```

```bash
gcloud iam workload-identity-pools providers create-oidc "my-provider" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="my-pool" \
  --display-name="Demo provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.aud=assertion.aud,attribute.actor=assertion.actor" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

The attribute mappings map claims in the GitHub Actions JWT to assertions you can make about the request (like the repository or GitHub username of the principal invoking the GitHub Action). These can be used to further restrict the authentication using --attribute-condition flags. For example, you can map the attribute repository value (which can be used later to restrict the authentication to specific repositories):

```bash
--attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository"
```

Finally, allow authentications from the Workload Identity Provider to impersonate the desired Service Account:

```bash
gcloud iam service-accounts add-iam-policy-binding "my-service-account@${PROJECT_ID}.iam.gserviceaccount.com" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/1234567890/locations/global/workloadIdentityPools/my-pool/attribute.repository/my-org/my-repo"
```
For more configuration options, see the Workload Identity Federation documentation. If you are using Terraform to automate your infrastructure provisioning, check out the GitHub OIDC Terraform module too.
