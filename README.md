# Automating CI/CD for Scalable App Deployment using AWS CodeBuild, CodePipeline & CodeDeploy

<img width="1721" height="914" alt="ChatGPT Image Sep 26, 2026, 10_44_30 AM" src="https://github.com/user-attachments/assets/abf95cd5-5418-4ee6-8a59-ee72c9965fbe" />

- I’m excited to share a project I did: developing a CI/CD pipeline that integrates GitHub, AWS CodeBuild, CodeDeploy and CodeDepipeline,
for optimized development and deployment workflows.

### Objective & Learning Outcomes:
— Objective: To implement an automated CI/CD pipeline that handles code integration, testing, and deployment of Dockerized applications.
— Learning Outcome: Gained deeper insight into DevOps automation with Docker containerization, AWS services, and streamlined infrastructure management for production-ready environments.

### AWS & Docker Services Utilized:
— AWS CodePipeline: Manages the entire CI/CD flow from GitHub to deployment.
— AWS CodeBuild: Builds Docker images and performs unit testing to ensure code integrity.
— AWS CodeDeploy: Deploys containerized applications on EC2 instances, supporting multi-environment setups.
— Docker: Provides application consistency and scalability with containers.
— Amazon EC2: Hosts the application, ensuring reliable compute resources.
— Amazon S3: Stores CI/CD artifacts with robust versioning.

### Steps:
- In this project, we will follow these steps:
1. Create GitHub repository and upload project files from Local Machine to repository
— Create GitHub Repository
— Upload files to repository using terminal (Windows PowerShell / Git Bash)
2. Create CodeBuild Project
— Specify source
— Write “buildspec” file
3. Configure System Manager
— Setting up Parameter Store: Username (string), Password (SecureString), Docker Registry URL (String)
4. AttachPolicies to CodeBuild IAM Role and Build the Project
— Policies: AministratorAccess
5. Create two IAM Roles
— Role for EC2 Instance
— Role for CodeDeploy
6. Create an EC2 Instance as a server
— Create a “Key Pair” to be used to SSH connect to instance
— In “Advance Details”, select the EC2 Role under “IAM Instance Profile”
— SSH connect to Instance
7. Attach the created EC2 Instance IAM role to the EC2 instance.
8. Install CodeDeploy Agent on EC2 Instance
— Use Vi Editor to create the file “install_codedeploy.sh”
Command: vi install_codedeploy.sh
9. Install docker
— Use Vi Editor to create the file “install_docker.sh”
Command: vi install_docker.sh
10. Create and Configure Deployment
— Create Applications
— Create Deployment Group
— Create Deployment
11. Create an AWS CodePipeline for Seamless flow
