# Troubleshooting AWS CodePipeline → CodeDeploy → EC2 → Docker Deployment

## Introduction

In this project, I built an automated deployment pipeline for a Dockerized Hotel Application using AWS CodePipeline, CodeBuild, CodeDeploy, EC2, S3, and Docker.

The overall deployment architecture looked like this:

```text
GitHub
   |
   v
AWS CodePipeline
   |
   v
AWS CodeBuild
   |
   v
S3 Artifact Bucket
   |
   v
AWS CodeDeploy
   |
   v
EC2 Instance
   |
   v
Docker Container
   |
   v
Hotel Application
```

The deployment did not work perfectly on the first attempt. I encountered several IAM and Docker-related errors.

This article documents the errors, how I investigated them, and how I resolved them.

---

# 1. S3 GetObject Permission Error

## Error

The first CodeDeploy error was:

```text
User: arn:aws:sts::923918898373:assumed-role/HotelApp-EC2-Role/i-06c4cf07feaecdd40
is not authorized to perform: s3:GetObject
on resource:
arn:aws:s3:::codepipeline-us-east-1-954e14ecc835-4c2d-84ca-a1f7775646ad/Hotel-App-Applicatio/BuildArtif/73AolHj
because no identity-based policy allows the s3:GetObject action
```

## What the error meant

The EC2 instance was using the IAM role:

```text
HotelApp-EC2-Role
```

CodeDeploy needed to access the deployment artifact stored in the CodePipeline S3 bucket.

The EC2 role could not download the object because it was missing:

```text
s3:GetObject
```

permission.

## Troubleshooting

First, I installed the AWS CLI on the EC2 instance because the command was initially unavailable:

```bash
aws
```

returned:

```text
Command 'aws' not found
```

I installed AWS CLI v2 and verified it:

```bash
aws --version
```

Then I checked the identity being used by the EC2 instance:

```bash
aws sts get-caller-identity
```

This confirmed that the EC2 instance was using the expected IAM role.

Next, I tested access to the S3 bucket:

```bash
aws s3 ls s3://codepipeline-us-east-1-954e14ecc835-4c2d-84ca-a1f7775646ad
```

The command returned:

```text
PRE Hotel-App-Applicatio/
```

This was important because it showed that the EC2 role could access the bucket.

However, the original error was specifically related to:

```text
s3:GetObject
```

So bucket listing alone was not enough. The role needed permission to read objects inside the bucket.

## Solution

I added an IAM policy to `HotelApp-EC2-Role`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": "arn:aws:s3:::codepipeline-us-east-1-954e14ecc835-4c2d-84ca-a1f7775646ad/*"
    }
  ]
}
```

The important detail is the `/*` at the end of the ARN.

For `s3:GetObject`, the resource needs to refer to the objects inside the bucket:

```text
arn:aws:s3:::bucket-name/*
```

rather than only:

```text
arn:aws:s3:::bucket-name
```

---

# 2. CodePipeline GetApplicationRevision Permission Error

After resolving the S3 issue, the pipeline progressed further but failed with another IAM error.

## Error

```text
User: arn:aws:sts::923918898373:assumed-role/AWSCodePipelineServiceRole-us-east-1-Hotel-App-Application/1790607633411

is not authorized to perform:

codedeploy:GetApplicationRevision

on resource:

arn:aws:codedeploy:us-east-1:923918898373:application:Hotel-App

because no identity-based policy allows the codedeploy:GetApplicationRevision action
```

## What the error meant

This time, the problem was not the EC2 role.

The failing role was:

```text
AWSCodePipelineServiceRole-us-east-1-Hotel-App-Application
```

This is the service role used by CodePipeline.

CodePipeline was trying to communicate with CodeDeploy but did not have permission to call:

```text
codedeploy:GetApplicationRevision
```

## Important troubleshooting lesson

There were two different IAM roles involved:

```text
AWSCodePipelineServiceRole-...
        |
        | Used by
        v
   CodePipeline
```

and:

```text
HotelApp-EC2-Role
        |
        | Used by
        v
     EC2
```

It is important not to fix the wrong role just because both errors involve IAM.

## Solution

I added the required CodeDeploy permissions to the CodePipeline service role.

For example:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:GetApplicationRevision",
        "codedeploy:GetDeploymentConfig",
        "codedeploy:RegisterApplicationRevision",
        "codedeploy:CreateDeployment"
      ],
      "Resource": "*"
    }
  ]
}
```

After updating the role, I reran the pipeline.

The deployment progressed to the EC2 deployment stage.

---

# 3. Docker Port Already Allocated

The next problem occurred during the CodeDeploy lifecycle event:

```text
LifecycleEvent - AfterInstall
Script - scripts/start_container.sh
```

The Docker image successfully downloaded:

```text
Status: Downloaded newer image for abdurakhimovda522/hotel-app:latest
```

So Docker Hub access and image pulling were working correctly.

However, the container failed to start.

## Error

```text
docker: Error response from daemon:

failed to set up container networking:

driver failed programming external connectivity on endpoint hungry_mcnulty:

Bind for 0.0.0.0:5000 failed:

port is already allocated
```

## What the error meant

The application container was configured to expose port `5000`.

The deployment was effectively trying to do something like:

```bash
docker run -d -p 5000:5000 abdurakhimovda522/hotel-app:latest
```

But another container was already using host port `5000`.

Docker therefore could not create another container using the same host port.

## Troubleshooting

I checked the running containers:

```bash
docker ps
```

I also checked all containers:

```bash
docker ps -a
```

To specifically identify what was using port 5000:

```bash
docker ps --filter "publish=5000"
```

This revealed that an existing container was already bound to port 5000.

## Solution

I stopped and removed the old container before starting the new one.

For example:

```bash
docker stop <container_id>
docker rm <container_id>
```

After removing the old container, the new deployment was able to bind:

```text
0.0.0.0:5000
```

and start successfully.

---

# 4. Improving the Deployment Scripts

Although manually removing the old container solved the immediate problem, a production-style deployment should handle this automatically.

Instead of allowing Docker to generate random container names such as:

```text
hungry_mcnulty
```

I used a predictable name:

```text
hotel-app
```

## stop_container.sh

```bash
#!/bin/bash

docker stop hotel-app 2>/dev/null || true
docker rm hotel-app 2>/dev/null || true
```

The `|| true` is useful because the deployment should continue even if the container does not already exist.

## start_container.sh

```bash
#!/bin/bash

docker pull abdurakhimovda522/hotel-app:latest

docker run -d \
  --name hotel-app \
  -p 5000:5000 \
  abdurakhimovda522/hotel-app:latest
```

This makes future deployments more predictable.

The deployment process becomes:

```text
Stop old container
       |
       v
Remove old container
       |
       v
Pull latest image
       |
       v
Start new container
       |
       v
Application running
```

---

# 5. Final Deployment Flow

After troubleshooting the IAM and Docker issues, the complete deployment worked successfully.

The final flow was:

```text
                   GitHub
                      |
                      v
              AWS CodePipeline
                      |
                      v
                AWS CodeBuild
                      |
                      v
                S3 Artifact
                      |
                      v
                AWS CodeDeploy
                      |
                      v
                EC2 Instance
                      |
                      v
              Docker Container
                      |
                      v
             Hotel Application
                   :5000
```

---

# 6. Key Troubleshooting Lessons

## Lesson 1: Read the IAM error carefully

AWS IAM errors usually tell you three important things:

```text
WHO
WHAT
WHERE
```

For example:

```text
WHO:
HotelApp-EC2-Role

WHAT:
s3:GetObject

WHERE:
S3 artifact bucket
```

This makes it much easier to identify the correct role and permission.

---

## Lesson 2: Different AWS services can use different IAM roles

In this deployment, at least two important roles were involved:

```text
CodePipeline
    |
    +--> AWSCodePipelineServiceRole-...

EC2
    |
    +--> HotelApp-EC2-Role
```

When an IAM error occurs, always check **which assumed role appears in the error message**.

Do not automatically modify the EC2 role for every IAM error.

---

## Lesson 3: Bucket access and object access are different

Being able to run:

```bash
aws s3 ls s3://bucket-name
```

does not necessarily mean the role can download objects.

For example:

```text
s3:ListBucket
```

and:

```text
s3:GetObject
```

are different permissions.

---

## Lesson 4: Port conflicts are common with Docker deployments

If Docker reports:

```text
port is already allocated
```

check:

```bash
docker ps
```

and:

```bash
docker ps --filter "publish=5000"
```

The problem is usually an existing container or process already listening on that port.

---

## Lesson 5: Deployment scripts should be repeatable

A deployment should be able to run multiple times without requiring manual cleanup.

Using predictable container names and stopping/removing the previous container helps make deployments repeatable.

---

# Conclusion

This deployment was a good example of real-world DevOps troubleshooting.

The pipeline itself was not the only challenge. The deployment required understanding how several AWS services and permissions interact:

* GitHub
* AWS CodePipeline
* AWS CodeBuild
* Amazon S3
* AWS CodeDeploy
* IAM
* Amazon EC2
* Docker
* Docker Hub

The main troubleshooting process was:

```text
Identify the exact error
        ↓
Identify the AWS service/role involved
        ↓
Verify permissions
        ↓
Test access manually
        ↓
Fix the specific permission/configuration
        ↓
Rerun deployment
        ↓
Investigate the next failure
```

This approach helped turn several confusing deployment errors into individual, manageable problems.

The final result was a successful automated deployment of the Dockerized Hotel Application to an EC2 instance using AWS CodePipeline and CodeDeploy.
