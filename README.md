
---

# CI/CD Pipeline Setup using AWS, Jenkins, and CodeDeploy
( [View all the screenshots here](https://github.com/SaadOps/oriserve-cicd-pipeline/blob/main/Screenshots.pdf) )

![CICD](https://github.com/user-attachments/assets/e912cfd4-f16f-41a1-b38c-a8e346519bb5)

This guide demonstrates how to set up a **CI/CD pipeline** using **Jenkins**, **AWS CodeDeploy**, and **EC2 instances**. The pipeline deploys a web application to an EC2 server upon every code push to a GitHub repository and scales automatically based on load, ensuring the application is always up-to-date.

## Problem Statement

- Deploy a simple web application to a server upon a code push to a repository.
- The web application should be accessible in any web browser.
- Implement auto-scaling, ensuring new servers have the latest code.
- Use AWS, Jenkins, and CodeDeploy for deployment.
- Ensure Jenkins runs on a different server than the deployed application.

## Tools Used

1. **Jenkins**: Automates the build and deployment process.
2. **GitHub**: Version control system to store code.
3. **AWS EC2**: Hosts the web application.
4. **AWS CodeDeploy**: Manages deployment to EC2 instances.
5. **S3**: Stores deployment artifacts.
6. **Application Load Balancer (ALB)**: Distributes traffic across EC2 instances.
7. **Auto Scaling Group (ASG)**: Ensures scalability based on load.

## Solution Overview

The CI/CD pipeline follows these key steps:

1. **Jenkins** pulls the latest code from **GitHub** upon a code push.
2. **Jenkins** builds the code and uploads the deployment package to **S3**.
3. **AWS CodeDeploy** retrieves the package from **S3** and deploys it to the **Auto Scaling Group** of **EC2** instances.
4. The **Application Load Balancer** distributes traffic across the EC2 instances, ensuring the app is accessible.

---

## Step-by-Step Guide

### Step 1: Create IAM Roles

- Create two **IAM roles**:
  1. **EC2 Role**: Attach policies `AmazonEC2RoleforAWSCodeDeploy` and `AmazonS3FullAccess`.
  2. **CodeDeploy Role**: Attach the `CodeDeployRole` policy.
  
  These roles will be used by EC2 instances and AWS CodeDeploy.

### Step 2: Set Up EC2 Instances

- Launch **4 EC2 instances** with the following user data to install required software:

    ```bash
    #!/bin/bash
    sudo apt -y update
    sudo apt -y install ruby wget
    cd /home/ubuntu
    wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
    sudo chmod +x ./install
    sudo ./install auto
    sudo apt install -y python3-pip
    sudo pip3 install awscli
    ```

- Assign the first IAM role (EC2 Role) to the instances.
- Create a **Security Group** allowing the following ports:
  - **HTTP (port 80)** for web traffic.
  - **HTTPS (port 443)** for secure web traffic.
  - **SSH (port 22)** for remote access.

### Step 3: Create an Image (AMI)

- Create an **Amazon Machine Image (AMI)** from one of the EC2 instances for use in the **Auto Scaling Group (ASG)**.

### Step 4: Create Application Load Balancer (ALB)

1. Create a **Target Group**.
   - Define the target path as `/index.html`.
   
2. Create an **Application Load Balancer**.
   - Attach the **Target Group** to the load balancer.
   - The ALB will distribute traffic to the EC2 instances.

### Step 5: Set Up Auto Scaling Group (ASG)

- Create a **Launch Configuration** using the previously created **AMI**.
- Set up an **Auto Scaling Group** attached to the **Application Load Balancer**.
  - Set the desired and maximum capacity to 2.
  - Upon creation, **2 instances** should automatically launch.

### Step 6: Set Up Jenkins Server

1. Launch a separate **EC2 instance** for Jenkins.
2. Install **Jenkins** by following the [Jenkins installation guide](https://www.jenkins.io/doc/tutorials/tutorial-for-installing-jenkins-on-AWS/).
3. Install **Git** on the Jenkins server if not present by default:

    ```bash
    sudo apt install git -y
    ```

### Step 7: Configure AWS CodeDeploy

1. Create a **CodeDeploy Application**.
2. Create a **Deployment Group**:
   - Select the **Auto Scaling Group** created earlier.
   - Attach the **Application Load Balancer** to the deployment group.

### Step 8: Set Up S3 Bucket

- Create an **S3 bucket** to store the deployment artifacts.

### Step 9: Configure Jenkins Pipeline

1. Install the **AWS CodeDeploy Plugin** in Jenkins.
2. Clone the repository containing the application code from GitHub:

    ```bash
    https://github.com/SaadOps/oriserve-cicd-pipeline.git
    ```

3. Set up a Jenkins **pipeline**:
   - Source: **GitHub**.
   - Trigger: **Poll SCM** with `* * * * *` (runs every minute).
   - Specify the **S3 bucket name** and other details.

4. In the **Post-build Actions**, select **Deploy an Application using AWS CodeDeploy**.
   - Provide the **Application Name**, **Deployment Group**, **S3 bucket**, and **prefix name**.
   - Use AWS access and secret keys for authorization.

### Step 10: Build Jenkins Pipeline

1. Click **Build Now** in Jenkins to trigger the pipeline.
2. Jenkins will push the build to **S3** and trigger **CodeDeploy** to deploy the application to the EC2 instances in the **Auto Scaling Group**.

### Step 11: Verify Deployment

1. Go to the **AWS Load Balancer** dashboard and copy the **DNS** of the **Application Load Balancer**.
2. Open the DNS URL in a browser, and the web application should be running.
3. Any future code changes pushed to GitHub will automatically trigger the Jenkins pipeline and redeploy the updated code.

---

## Auto-Scaling Verification

- Since the Auto Scaling Group is connected to the **Application Load Balancer**, the web application scales up or down based on traffic. Any new EC2 instances launched will have the updated code from the latest deployment.


