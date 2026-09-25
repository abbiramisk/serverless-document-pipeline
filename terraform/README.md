# Terraform — Serverless Document Processing Pipeline

Rebuilds the entire stack (S3, DynamoDB, IAM, 3 Lambda functions, API Gateway, SQS DLQ, CloudWatch alarm, SNS) as code, identical to what was originally built via the AWS Console.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5.0
- An AWS IAM user with programmatic access (access key + secret key) and sufficient permissions to create the resources above
- AWS CLI configured (`aws configure`) **or** credentials exported as environment variables:
  ```bash
  export AWS_ACCESS_KEY_ID="..."
  export AWS_SECRET_ACCESS_KEY="..."
  export AWS_REGION="ap-south-1"
  ```

## Deploy

```bash
cd terraform
terraform init
terraform apply -var="alert_email=your-email@example.com"
```

Type `yes` when prompted. This provisions the full stack. Note the two most important outputs printed at the end: `api_invoke_url` and `frontend_website_url`.

**Important — confirm the SNS email subscription.** AWS sends a confirmation email to the address you provided immediately after apply. Click the confirmation link, or the CloudWatch alarm will never actually notify you.

## A required manual step: wiring the frontend to the new API URL

The frontend (`frontend/index.html`) calls the API using a hardcoded URL, but API Gateway generates a **new, unique URL every time it's created** — Terraform can't know this URL until after the resource exists. So:

1. Run `terraform apply` once (creates the API Gateway and prints `api_invoke_url`)
2. Open `../frontend/index.html`, find this line near the bottom:
   ```js
   const API_BASE = "https://REPLACE-WITH-YOUR-API-URL.execute-api.ap-south-1.amazonaws.com";
   ```
3. Replace it with the real `api_invoke_url` value from the apply output
4. Run `terraform apply` again — this re-uploads the corrected `index.html` to the frontend bucket (everything else is unchanged, so this second apply is fast)

This two-step apply is a known trade-off of static frontend + serverless backend architectures without a CDN/custom domain in front. In a larger project this is usually solved with CloudFront + a custom domain, so the frontend never needs to know the raw API Gateway URL.

## Destroy

```bash
terraform destroy -var="alert_email=your-email@example.com"
```

Tears down every resource cleanly. S3 buckets must be empty before Terraform can delete them — if `destroy` fails on a bucket with "BucketNotEmpty", empty it manually in the console first (this can happen if files were uploaded outside of Terraform, e.g. manually testing with extra files).

## What's provisioned

| File | Resources |
|---|---|
| `s3.tf` | Uploads bucket (private, CORS-enabled, S3 event trigger) + frontend bucket (public, static website hosting) |
| `dynamodb.tf` | `docpipeline-results` table, on-demand billing |
| `iam.tf` | Lambda execution role with S3, Textract, DynamoDB, SQS, and CloudWatch Logs permissions |
| `lambda.tf` | All 3 Lambda functions, packaged from `../lambda/`, with the processor wired to the DLQ |
| `api_gateway.tf` | HTTP API with `/results` and `/upload-url` routes |
| `sqs_cloudwatch.tf` | Dead-letter queue, SNS topic + email subscription, CloudWatch alarm |
| `outputs.tf` | Prints the API URL, frontend URL, bucket names, table name, and DLQ URL after apply |
