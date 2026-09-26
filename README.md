# Automating CI/CD for Scalable App Deployment using AWS CodeBuild, CodePipeline & CodeDeploy

<img width="1721" height="914" alt="ChatGPT Image Sep 26, 2026, 10_44_30 AM" src="https://github.com/user-attachments/assets/abf95cd5-5418-4ee6-8a59-ee72c9965fbe" />

- I’m excited to share a project I did: developing a CI/CD pipeline that integrates GitHub, AWS CodeBuild, CodeDeploy and CodeDepipeline,
for optimized development and deployment workflows.

### Objective & Learning Outcomes:
- Objective: To implement an automated CI/CD pipeline that handles code integration, testing, and deployment of Dockerized applications.
- Learning Outcome: Gained deeper insight into DevOps automation with Docker containerization, AWS services, and streamlined infrastructure management for production-ready environments.

### AWS & Docker Services Utilized:
- AWS CodePipeline: Manages the entire CI/CD flow from GitHub to deployment.
- AWS CodeBuild: Builds Docker images and performs unit testing to ensure code integrity.
- AWS CodeDeploy: Deploys containerized applications on EC2 instances, supporting multi-environment setups.
- Docker: Provides application consistency and scalability with containers.
- Amazon EC2: Hosts the application, ensuring reliable compute resources.
- Amazon S3: Stores CI/CD artifacts with robust versioning.

### Steps:
- In this project, we will follow these steps:
1. Create GitHub repository and upload project files from Local Machine to repository
- Create GitHub Repository
- Upload files to repository using terminal (Windows PowerShell / Git Bash)
2. Create CodeBuild Project
- Specify source
- Write “buildspec” file
3. Configure System Manager
- Setting up Parameter Store: Username (string), Password (SecureString), Docker Registry URL (String)
4. AttachPolicies to CodeBuild IAM Role and Build the Project
- Policies: AministratorAccess
5. Create two IAM Roles
- Role for EC2 Instance
- Role for CodeDeploy
6. Create an EC2 Instance as a server
- Create a “Key Pair” to be used to SSH connect to instance
- In “Advance Details”, select the EC2 Role under “IAM Instance Profile”
- SSH connect to Instance
7. Attach the created EC2 Instance IAM role to the EC2 instance.
8. Install CodeDeploy Agent on EC2 Instance
- Use Vi Editor to create the file “install_codedeploy.sh”
Command: vi install_codedeploy.sh
9. Install docker
- Use Vi Editor to create the file “install_docker.sh”
Command: vi install_docker.sh
10. Create and Configure Deployment
- Create Applications
- Create Deployment Group
- Create Deployment
11. Create an AWS CodePipeline for Seamless flow

### STEP 1: — Create GitHub Repository and upload project files from laptop to repository

- Part 1: We have to create a GitHub repository called “AWS-CICD-Project”
- Click on “Create Repository”

<img width="964" height="920" alt="Screenshot 2026-09-26 at 12 48 13 PM" src="https://github.com/user-attachments/assets/a29e8986-35fd-412e-bc7e-c72fc1088bcc" />

- Part 2: Upload files to the GitHub repository
- Here we will push the files from our local machine to the GitHub repository we just created
- Clone your repository to your local machine first.

```bash
git clone https://github.com/Damir94/AWS-CI-CD-Project.git
```
### Create these files and upload them to your repository.

- Step 1: Create Dockerfile in your local machine and copy commands from Dockerfile in my current repository and put them in your Dockerfile.
- A Dockerfile is a set of instructions used to build a Docker image. It defines the base image, application dependencies, configuration, files to copy, and the command to start the application.
- It allows us to create a consistent and reproducible environment, so the application behaves the same across development, CI/CD, and production.

```bash
FROM nginx

COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY index.js /usr/share/nginx/html/
```

- Step 2: Create appspec.yml file and leave these commands into it.
- appspec.yml is a configuration file used by AWS CodeDeploy to define the deployment process. It specifies which files should be copied and which lifecycle scripts should run during stages such as stopping the old application, installing the new version, starting the application, and validating the deployment.

```bash
version: 0.0
os: linux

hooks:
  ApplicationStop:
    - location: scripts/stop_container.sh
      timeout: 300
      runas: root
  AfterInstall:
    - location: scripts/start_container.sh
      timeout: 300
      runas: root
```

- Step 3: Create buildspec.yaml file and type these commands in it.
- buildspec.yaml is used by AWS CodeBuild to define the build process. It specifies the commands and phases needed to install dependencies, run tests, build the application, and create artifacts.
- Keeping these instructions in a version-controlled file makes the CI process consistent and repeatable.

```bash
version: 0.2

env:
  parameter-store:
    DOCKER_REGISTRY_USERNAME: /cloud-cicd/docker-credentials/username
    DOCKER_REGISTRY_PASSWORD: /cloud-cicd/docker-credentials/password
    DOCKER_REGISTRY_URL: /cloud-cicd/docker-registry/url
phases:
  install:
    runtime-versions:
      python: 3.11
  pre_build:
    commands:
      - echo "Installing dependencies..."
      - pip install -r requirements.txt
  build:
    commands:
      - echo "Running tests..."
      - echo "Building Docker image..."
      - echo "$DOCKER_REGISTRY_PASSWORD" | docker login -u "$DOCKER_REGISTRY_USERNAME" --password-stdin "$DOCKER_REGISTRY_URL"
      - docker build -t "$DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_USERNAME/hotel-app:latest" .
      - docker push "$DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_USERNAME/hotel-app:latest"
  post_build:
    commands:
      - echo "Build completed successfully!"
artifacts:
  files:
    - '**/*'
```

- Step 4: Create index.html file and copy codes from my current repository and put them into index.html file.
- index.html is typically the default entry point for a web application. It contains the HTML structure that the browser loads and renders when a user accesses the website. Web servers such as Nginx or Apache can be configured to serve index.html as the default document.

- Step 5: Create index.js file and add these codes in it.
- index.js is commonly used as the entry point of a JavaScript or Node.js application. It initializes the application, loads the required dependencies and configuration, sets up routes or services, and starts the application. It's a convention rather than a requirement—the entry point could also be named app.js or server.js

```bash
document.addEventListener('DOMContentLoaded', function () {
  var modeSwitch = document.querySelector('.mode-switch');

  modeSwitch.addEventListener('click', function () {
    document.documentElement.classList.toggle('dark');
  });
});

function openModal(){
  let modal= document.querySelector('#modal-window');
  modal.classList.add("showModal");
}

function closeM(){
    let m= document.querySelector('#modal-window');
  m.classList.remove("showModal");
}

document.getElementsByClassName('.mode-switch').onclick = function() {
  document.body.classList.toggle('dark');
}

const cardItems = document.querySelectorAll('.main-card');
const modalHeader = document.querySelector('.modalHeader-js');
const modalCardPrice = document.querySelector('.amount');

cardItems.forEach((cardItem) => {
  cardItem.addEventListener('click', function () {
    const cardHeader = cardItem.querySelector('.cardText-js');
    const cardPrice = cardItem.querySelector('.card-price');

    modalHeader.innerText = cardHeader.innerText;
    modalCardPrice.innerText = cardPrice.innerText;
  });
});

window.onkeydown = function (event) {
  if(event.keyCode == 27) {
    closeM();
  }
}

var modal =  document.querySelector('#modal-window');
window.onclick = function (event) {
  if(event.target == modal) {
    closeM();
  }
}
```

- Step 6: Create requirements.txt file and add it in.
```bash
npm
```

- Step 7: Create style.css file and copy codes from my current repository and put them into style.css file.
- style.css is a stylesheet that controls the presentation and layout of a web page. It separates the visual design from the HTML structure, making the application easier to maintain and allowing the same styles to be reused across multiple pages.

- Step 8: Create a folder called scripts and add two files start_container.sh and stop_container.sh respectively.
- We use start and stop shell scripts to automate Docker container lifecycle operations. Instead of manually running Docker commands during deployment, CodeDeploy can execute these scripts through the lifecycle hooks defined in appspec.yml. This makes deployments more consistent, repeatable, and easier to maintain.

- start_container.sh
```bash
#!/bin/bash
set -e

# Pull the Docker image from Docker Hub
docker pull ebotsmith/hotel-app:latest

# Run the Docker image as a container
docker run -dit -p 5000:5000 ebotsmith/hotel-app:latest
```

- stop_container.sh
```bash
#!/bin/bash
set -e

# Stop the running container (if any)
echo "Hi"
```
