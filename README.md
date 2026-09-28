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

### STEP 2: — Create CodeBuild Project.
- Login to the AWS Console and Navigate to CodeBuild. Search for CodeBuild in AWS Management Console

<img width="720" height="398" alt="1_5nO5NsuBikonotNZjd26gg" src="https://github.com/user-attachments/assets/b088a625-80c0-4cec-8476-35baad640674" />

- Click on “CodeBuild” under “services”

<img width="720" height="296" alt="1_iLEDMTBeY8Tr0jubz1auNQ" src="https://github.com/user-attachments/assets/c0b76f1b-1eb1-4639-965b-9f18129e7e06" />

- Click on “Create Project”

<img width="720" height="711" alt="1_ptj3e5QL4j3pcN9CvbxK3Q" src="https://github.com/user-attachments/assets/cef89e68-6680-4fdb-a3fa-c3235417ebf7" />

- Give the project the name “HotelApp-Build”

<img width="720" height="329" alt="1_nmpqn4OIcihaqoTw47tr2Q" src="https://github.com/user-attachments/assets/1befb59d-c1dc-4e4c-b818-eab30d13af72" />

- On the primary Source will be “Github” and select “Custom Source Credential”, Select “OAuth App” for credential type

<img width="720" height="499" alt="1_rLbk41llYXSd73v6mFHJ9w" src="https://github.com/user-attachments/assets/a7f6d12d-4062-4292-9adf-246a92022128" />

- Click on “Create a new secret”

<img width="610" height="174" alt="1_wcSNPbCDIH_7imJlNTFSOA" src="https://github.com/user-attachments/assets/a2f8ccb8-400b-4be5-b778-7f65fbd7eebd" />

- Click on “Connect to GitHub”

<img width="554" height="236" alt="Screenshot 2026-09-28 at 8 32 17 AM" src="https://github.com/user-attachments/assets/3693f555-c08b-49ce-b709-9288d39119d8" />


- I will use the name “HoteApp” and leave “secret description” blank. Then click on “Confirm”

<img width="720" height="250" alt="1_ad_nJKTqdWKY-LvagbK3dw" src="https://github.com/user-attachments/assets/ffe49425-ebbb-457a-b28a-b7828d5a1ffe" />

- Copy the URL of your GitHub repository and paste it in “GitHub Repository”

<img width="1234" height="333" alt="Screenshot 2026-09-28 at 8 34 19 AM" src="https://github.com/user-attachments/assets/1d75bdfd-3ab4-4bee-86a6-797c2ff5491c" />


<img width="720" height="343" alt="1_1T_ifjx3XVL7T6BgZI850A" src="https://github.com/user-attachments/assets/63a2047d-64a8-4c14-a685-1f3c516211f7" />

- Scroll down to “Environment”. On “operating Systems”, select “Ubuntu”, Runtime is “Standard”.

<img width="720" height="632" alt="1_n4344ocYNV2Q6aP6bqRV0w" src="https://github.com/user-attachments/assets/cd4d8d6f-c678-412a-ab9a-0e87bcb8e792" />

<img width="720" height="293" alt="1_2XmNtcaWx4foJSu31YX6Ig" src="https://github.com/user-attachments/assets/43bc187c-e699-424f-b2db-acfb9290b29f" />

- Note that this will create an IAM role called “codebuild-HotelApp-Build-service-role”

- Under “Buildspec” Select “Use a buildspec file” and give a name as in github repo. That is “buildspec.yml”

<img width="720" height="261" alt="1_me17U6dFD5E_Tl7zndi-cA" src="https://github.com/user-attachments/assets/34bdc867-7fd1-4fc4-9715-1797d69d8f05" />

<img width="720" height="409" alt="1_6feyAqP5pHWWAf0hxpY4Qw" src="https://github.com/user-attachments/assets/c16d4ad8-7385-48d9-a3bc-63bb8850b6de" />

<img width="720" height="481" alt="1_r7wKHD3SBXw3BZr-nDWdxA" src="https://github.com/user-attachments/assets/35c4755e-7b04-4622-89b6-8969a87a94a9" />

- Click on “create build project”.

<img width="1536" height="532" alt="Screenshot 2026-09-28 at 8 41 32 AM" src="https://github.com/user-attachments/assets/21974adc-4cce-49bb-b2e2-106427a3a1f0" />


- Before building it let us understand what is inside the “buildspec file”

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

### STEP 3: Configure System Manager

- Here we are using env variables that are stored in System manager’s parameter store. Let us configure them first.
- Search for “System Manager” on AWS Management Console

<img width="720" height="564" alt="1_xLxroYlwPNvhIr9yFQXEXA" src="https://github.com/user-attachments/assets/beb1fdfe-49c2-4d5e-820f-3e00492eb8b8" />

- Click on “Systems Manager”

<img width="1582" height="328" alt="Screenshot 2026-09-28 at 8 45 47 AM" src="https://github.com/user-attachments/assets/2178a3ee-da92-4a58-a5db-91fc71ab72ab" />

- Click on “Parameter Store” on the Left-hand side

<img width="720" height="124" alt="1_n9p2xoxv0Q-lR6q-ex29sA" src="https://github.com/user-attachments/assets/7018521c-eee1-4cad-ad55-03aa78e146e8" />

#### Setting up Parameter Store
- Click on “Create Parameter” and give name as in the yaml file,

<img width="720" height="398" alt="1_xKwvm_DPlHoLxcoVv5fKIw" src="https://github.com/user-attachments/assets/cae6b706-5b9c-436a-a53d-b30b15d5a646" />

- That is /cloud-cicd/docker-credentials/username: Your DockerHub Username
- The Provide the “Value”, for our first Parameter, the value is “Your DockerHub Username”
- Name: /cloud-cicd/docker-credentials/username
- Value: ebotsmith

<img width="720" height="391" alt="1_k3D6v74Iz_kriA-_O8GuaA" src="https://github.com/user-attachments/assets/0b134d4a-5cea-4783-9851-824f45013bd0" />

- Click on “create parameter”

<img width="1860" height="399" alt="Screenshot 2026-09-28 at 8 54 12 AM" src="https://github.com/user-attachments/assets/27fdaf12-ac00-40bd-a759-8572c23cc252" />

- Repeat the same for other two parameters
- Name: /cloud-cicd/docker-credentials/password
- Value: xxxxxxxxx
- NOTE: The password is your docker hub password
- Name: /cloud-cicd/docker-registry/url
- Value: docker.io

- All the phases mentioned in the yaml file are like setting up the environment for building the image
- → Runtime as the Base image
- → Installing the requirements
- → Building and then pushing the image to the DockerHub with provided credentials.

### STEP 4: Attach Policies to CodeBuild role and Build the Project

- We have to attach the “AdminstratorAccess” policy to the IAM role created at the CodeBuild Project
- Go to “Roles” under IAM

<img width="1561" height="511" alt="Screenshot 2026-09-28 at 8 57 38 AM" src="https://github.com/user-attachments/assets/73ecf50d-8b09-422b-be15-0bf402108438" />

- Search for the role “codebuild-Hotel-App-service-role” and click on it

<img width="720" height="384" alt="1_Nb30PNmv_YrNXK9lMUDSMA" src="https://github.com/user-attachments/assets/04c649de-db62-4c1c-bb74-ed49872a2807" />

- Add permission “AdministratorAccess”

<img width="720" height="267" alt="1_ylGR0JTxqjTYK-mwYeRXrQ" src="https://github.com/user-attachments/assets/b9cb46d9-1bc4-427f-84db-8f8cd7c9ca44" />

- Click on “Add Permission”
- Head back to the CodeBuild

<img width="720" height="388" alt="1_eyllHGbvQjvfuLF7fqGs2A" src="https://github.com/user-attachments/assets/4d93542e-adb4-41ff-aac2-930dc206ec0b" />

- Click on “Start Build” to build it and after successful completion it will show as:

<img width="720" height="404" alt="1_zZGcfMHo-Aj91qaB1p-Q-A" src="https://github.com/user-attachments/assets/7230d5b0-3ec8-45c2-93b9-d68436374e32" />

- And the logs are:

<img width="720" height="404" alt="1_moLJA0_zsu229SmBYTBTZw" src="https://github.com/user-attachments/assets/6c9cf741-aaf6-465d-bb21-e2970fb337b5" />

- The build is successful. The image will be pushed to the dockerhub. Now, go to the Docker hub to see if the image is there

<img width="720" height="334" alt="1_BS6UP001RCyTKoLY2oSMZQ" src="https://github.com/user-attachments/assets/a85532e8-2960-447c-ba21-1d83744c973f" />

- You can see the image we just created

### STEP 5: Create IAM Roles
- We have to create two IAM Roles. One for the EC2 instance and another for CodeDeploy

Part 1: IAM Role for EC2 instance
- CodeDeploy agent in EC2 need to communicate with the CodeDeploy. So, create a role for it.

<img width="720" height="399" alt="1_jK0u6i4FxhToaYwwGEooHg" src="https://github.com/user-attachments/assets/3073eb63-df3e-4527-a90d-68189ce46c15" />

- Click on “Roles” on the left-hand side

<img width="720" height="383" alt="1_LnfoGtDwBBtmcGMAbLychg" src="https://github.com/user-attachments/assets/c4f5fe5c-4262-4dfc-9ef2-052822f3f557" />

- Click on “Create Role”. We will name the role “HotelApp-EC2-Role”. Under “Trusted entity type” choose “AWS Service” and for “use case”, select “EC2”

<img width="720" height="373" alt="1_ZqDQQiAACU8TOl2VCOgjBg" src="https://github.com/user-attachments/assets/07a0f22e-2da5-45fa-a1ea-b82ba5fe9bf5" />

- Click on “Next”

<img width="720" height="382" alt="1_mD1suGMuLnrhfliY9EPZRQ" src="https://github.com/user-attachments/assets/170d394d-f5aa-4630-83e3-7ed4f3dc0b2e" />

- Check “AWSCodeDeployFullAccess” to add this policy

<img width="720" height="170" alt="1_yjD3XfiUyk9EyY87WAmk3w" src="https://github.com/user-attachments/assets/4b093989-bf50-40a7-a406-20e0cf5e8838" />

- Click on “Next”. Give the role a name “HotelApp-EC2-Role”

<img width="720" height="359" alt="1_btKRZe8rfHZhYFjDNXsJTA" src="https://github.com/user-attachments/assets/c146f7a3-783b-4880-9349-5c4e4a905c4f" />

- Click on “Create Role”

<img width="720" height="404" alt="1_HIhzIWRo9KtNkR9vZohsoA" src="https://github.com/user-attachments/assets/039fffba-a5e0-4681-af67-04feb43574a7" />

- The role has been created

<img width="720" height="378" alt="1_kNUWZcPBjEozr48vvGGjgw" src="https://github.com/user-attachments/assets/45533fc4-2e66-4829-ae04-8dbc3212e08c" />

Part 2: IAM Role for CodeDeploy
- Create the second role for CodeDeploy. We will call this role “HotelApp-Codeploy-Role”. Click on “Create Role”

<img width="720" height="383" alt="1_YnvMYmjAsCxw-L0WawgleQ" src="https://github.com/user-attachments/assets/072db0ef-caa8-4c5e-8287-bf83d03d084c" />

- Click on “Create Role” and in “Use Case” select “CodeDeploy”

<img width="720" height="385" alt="1_ETTOt-JMlmZJGiAsubnpww" src="https://github.com/user-attachments/assets/f9ac12bb-d5c0-4fbe-b7eb-1771a191a49b" />

- Scroll down and click on “Next”

<img width="720" height="203" alt="1_Jr1188H7bNvYttYuALZPXw" src="https://github.com/user-attachments/assets/7512957b-96c9-4c41-89ec-67b360014478" />

- Click on “Next” again, Give the role a name “HotelApp-CodeDeploy-Role”

<img width="720" height="367" alt="1_eLAkUN8cdeFX1ctcdjB-3Q" src="https://github.com/user-attachments/assets/6f7ee64f-e64b-486e-901f-dafbdd681b3d" />

<img width="720" height="341" alt="1_bwFA0ncMJQs6IaMkzPVE4A" src="https://github.com/user-attachments/assets/87bbcae8-4266-4438-b208-c47cc839162e" />

- Click on “Create Role”

<img width="720" height="384" alt="1_iHg4fMB4DzwGFpqs30zaXg" src="https://github.com/user-attachments/assets/9c2094ff-b5f4-4601-ab77-5c3cfa89abc9" />

- Add this permission “AmazonEC2fullAccess” to the role to access the CodeDeploy agent. Click on the role “HotelApp-CodeDeploy-Role” we just created.

<img width="720" height="378" alt="1_os-g2r13Ump5PVvT25XIiA" src="https://github.com/user-attachments/assets/c75da7eb-eef2-48f8-9925-3b285b556a6b" />

- Click on “Add Permission”

<img width="720" height="394" alt="1_gyCKgZclri5vkgV6Ku8i9g" src="https://github.com/user-attachments/assets/2dbd33ff-6d5f-487c-bcf1-151752ad370b" />

- Select “Attach Policies”

<img width="720" height="379" alt="1_5QXZY6nkM4Jb1MQor8m36w" src="https://github.com/user-attachments/assets/02d27090-3bfa-42af-aae9-aaa6cce78561" />

- Select “AmazonEC2fullaccess”, the scroll down and click on “Add Permission”

<img width="720" height="206" alt="1_ArjeRTfcMQ35j41mRNWNRQ" src="https://github.com/user-attachments/assets/7556f099-844d-40e6-bea4-e68325fe63bc" />

- Click on “Add Permission”

<img width="720" height="375" alt="1_v6zkf4dbgvySFNMHXg99QQ" src="https://github.com/user-attachments/assets/c3638840-dc69-4b0f-b2d5-d27f232b293d" />

### STEP 6: — Create an EC2 Server and connect to the server
- Here we will create an AWS Ubuntu Instance that will be our Server, then have to connect to the server using SSH.

Part 1: Launch EC2 instance adding the EC2 IAM role as “IAM Instance Profile”
- Navigate to EC2 Console

<img width="720" height="383" alt="1_2hmQgO0DcLc4m3VENvr7iQ" src="https://github.com/user-attachments/assets/c5dc31c8-a68a-4b42-b5fa-02b5c92c0540" />

- Click on Launch Instance and Provide a name to it. I will name it “HotelApp-Server”

<img width="720" height="195" alt="1_-bqCXUPfaXQxWbuKkcKs-Q" src="https://github.com/user-attachments/assets/122d0152-6ea8-4298-8d66-b5920fc02f07" />

- Select AMI as Ubuntu and instance type as “t2.micro”.

<img width="720" height="532" alt="1_N8pgpRHULZ2lDaOSVqZZCQ" src="https://github.com/user-attachments/assets/5447a718-4abd-4c31-b16f-012577e494ec" />

- Provide a key pair for it. I will use the key pair “ubuntuKey” I created in another project

<img width="720" height="125" alt="1_aUqtoX9lXopmf-EiEwW5FA" src="https://github.com/user-attachments/assets/42371581-ec25-46b5-bfb9-f8c3a07f90ff" />

<img width="720" height="461" alt="1_-sBMARHKTdLjdqG5w_kS0w" src="https://github.com/user-attachments/assets/daf49eab-e2d3-4e29-8287-199a2d37153f" />

<img width="720" height="326" alt="1_wME8RRgxMabiiOS0OQPifQ" src="https://github.com/user-attachments/assets/5d49c33e-f097-4916-9ef7-b51cdaf5629d" />

- On IAM Instance Profile, select the role we created for the EC2 instance, that is “HotelApp-EC2-Role”

<img width="720" height="357" alt="1_Y9wapgiDltweShYFziuAsQ" src="https://github.com/user-attachments/assets/48851c93-918c-4e62-879b-40f2f8f90413" />

- Click on create instance.

<img width="720" height="450" alt="1_uPPrSBsblkRmbpu4FWJAOw" src="https://github.com/user-attachments/assets/04ad51bd-c3a2-46e6-bac6-26cc3093aa9c" />

- Click on instance ID on the “Green” part at the top

<img width="720" height="208" alt="1_OtBf4itp4yrLU6iNgYCK-w" src="https://github.com/user-attachments/assets/5c9754dc-69c6-4ac3-bcbe-db0884ea07c2" />

- You can now see the instance we have just created “HotelApp-Server”

Part 2: SSH connect to the instance
- Now, connect the newly created instance by using SSH

<img width="720" height="208" alt="1_OtBf4itp4yrLU6iNgYCK-w" src="https://github.com/user-attachments/assets/1a3afe9e-5c28-4e1b-9967-11b8f335a970" />

- Select the instance we just created and then SSH into the instance with that key pair.

<img width="720" height="365" alt="1_qb8XJuw9DB5EqR8xm9Uh0w" src="https://github.com/user-attachments/assets/60686ba4-e68d-418d-b726-9dd7c6e60055" />

- Click on “Connect” at the top

<img width="720" height="288" alt="1_8Zrse5PaWYGj5x34Dsa3Rg" src="https://github.com/user-attachments/assets/cefca9eb-7256-4a32-bf9d-5b681d50ac5f" />

- Copy the above command and paste in your PowerShell terminal

```bash
ssh -i “ubuntuKey.pem” ubuntu@ec2–54–234–18–204.compute-1.amazonaws.com
```
- Open PowerShell and navigate to your Downloads folder where the ubuntuKey.pem file is saved

<img width="720" height="213" alt="1_rKoBTqh0daToIwP3r-laBg" src="https://github.com/user-attachments/assets/5675ea9b-263e-4785-b443-c1f929946f30" />

- Now, run the command:
```bash
ssh -i “ubuntuKey.pem” ubuntu@ec2–98–80–123–138.compute-1.amazonaws.com
```

<img width="720" height="258" alt="1_Cl7UXX_JPL1CeVQJjL-VqA" src="https://github.com/user-attachments/assets/53fdce31-9304-4930-ba4a-7b950ef42fd8" />

- Then type “yes” and press ENTER

<img width="720" height="366" alt="1_cYUwAOuqKq4RDcGZWLPv8A" src="https://github.com/user-attachments/assets/39e5c81e-f3b5-45c2-9be9-221e39a0862b" />

- We have now SSHed into the server.

### STEP 7: — Attach the created EC2 IAM role to the EC2 instance.
- → EC2 instance → Actions → Security → Modify IAM role → choose it → Update IAM role

<img width="720" height="178" alt="1_J3eCx4VzWzkRhAnQJln_9g" src="https://github.com/user-attachments/assets/919ffbd2-a748-4c39-83bb-79e4403ef527" />

- Select the EC2 instance

<img width="720" height="378" alt="1_5VdNPPYVEnh5s4b1YksRhQ" src="https://github.com/user-attachments/assets/3fb8a394-0d4c-4224-828d-6fe5f69b4134" />

- Click on “Actions” at the top → Security → Modify IAM role

<img width="720" height="179" alt="1_SkeNVGRd9d-W61v9DXtdLg" src="https://github.com/user-attachments/assets/b526a33c-6456-4247-968c-4529217149cb" />

- Click on “Update IAM role”

<img width="720" height="365" alt="1_UMytGBypd5JHLYmDnsHjDA" src="https://github.com/user-attachments/assets/96270fff-c1e0-4d71-98d9-cfc69f236c0f" />

### STEP 8: — Install CodeDeploy Agent on EC2

- Then create a script called “install_codedeploy.sh” with your favourite editor. I will use vi editor. Open the file and paste the code below to install CodeDeploy Agent:

```bash
# run system update
sudo apt update
sudo apt install ruby-full
sudo apt install wget
#wget https://bucket-name.s3.region-identifier.amazonaws.com/latest/install
# your code should look like this
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install chmod +x ./install
sudo ./install auto
```
- I will open the file using the command:
```bash
vi install_codedeploy.sh
```

<img width="720" height="398" alt="1_XB1ncBrg72SO49q1-uJqOw" src="https://github.com/user-attachments/assets/906460ea-525a-4a3e-850c-7433829b16d7" />

- Then paste the code below
```bash
# automate the codeDeploy installation with the following shell script
#!/bin/bash
# Update package list
sudo apt update
# Install Ruby and wget if not already installed
sudo apt install -y ruby wget
# Navigate to the home directory
cd /home/ubuntu
# Download the CodeDeploy agent installer script for Ubuntu
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
# Make the install script executable
chmod +x ./install
# Run the install script
sudo ./install auto
# Start the CodeDeploy agent service
sudo service codedeploy-agent start
# Check the status of the CodeDeploy agent
sudo service codedeploy-agent status
# Inform user of successful installation
echo "AWS CodeDeploy agent installed and started successfully."
```

<img width="720" height="396" alt="1_oRNS6_wzRanXCnqg8AcgBw" src="https://github.com/user-attachments/assets/09fef2d0-78cd-465f-b3ad-86f509da860c" />

- Save the script by using :wq and press ENTER

<img width="720" height="88" alt="1_uNU7lzDQ5FJpZz8NrGBJRw" src="https://github.com/user-attachments/assets/d39b1b4f-3364-419e-aa04-6a8e13073785" />

- Make the script executable:
```bash
chmod +x install_codedeploy.sh
```

<img width="720" height="97" alt="1_CoNhzFXvdn-UL-6G1hAsug" src="https://github.com/user-attachments/assets/f4df0e1c-4a1d-4753-8d42-abe8646f0b9d" />

- Run the script
```bash
./install_codedeploy.sh
```

<img width="720" height="248" alt="1_bmkYaqLaLHUkPJ3EJ1c_4Q" src="https://github.com/user-attachments/assets/19c27ed1-daaa-49c5-8f10-6f22fec31a29" />

- This script installs the CodeDeploy agent and verifies that it’s running. Make sure you replace the us-east-1 region in the S3 URL with your specific AWS region if you’re not using us-east-1.

- Verify the Installation:
- After installing the AWS CodeDeploy agent, verify its installation by running the following command on your EC2 instance:
```bash
systemctl status codedeploy-agent
```

<img width="720" height="247" alt="1_v8KV1d9o73MzHV1lh_rIhw" src="https://github.com/user-attachments/assets/f48b107c-aefe-44d2-b58e-14b679c31c63" />

### STEP 9: — Install Docker:

- Ensure that Docker is installed on your EC2 instance to use Docker commands later in the project. Create a shell script called install_docker.sh with the code below to install docker.
- Make a file install_docker.sh using the command vi install_docker.sh and paste the code below

```bash
#!/bin/bash

# Update package list and install prerequisites
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker's stable repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list to include Docker packages
sudo apt update

# Install Docker
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add the current user to the docker group
sudo usermod -aG docker $USER

# Inform user to log out and log back in for the group changes to take effect
echo "Docker installed and user added to docker group. Please log out and log back in to apply group changes."
```

- Go to your favourite editor and open it. I will use the vi editor. I will open the install_docker.sh file using the command:
```bash
vi install_docker.sh
```
- Then paste the code

<img width="720" height="258" alt="1_0z-zq6rQFr01dsiIuHkYXg" src="https://github.com/user-attachments/assets/0d5e9700-836e-429b-b8d3-db0eb5b50846" />

- And save it by typing :wq and press ENTER

<img width="720" height="99" alt="1_yVOQqvfQlOUTkmaZQ9E8-A" src="https://github.com/user-attachments/assets/123fe07a-8159-4dd4-b108-a22f01f1e909" />

- Make the script executable
```bash
chmod +x install_docker.sh
```

<img width="720" height="97" alt="1_LzSxqdU3hZBvZh92E_pTNw" src="https://github.com/user-attachments/assets/4fcd6604-cc60-4028-89a8-d09904693c66" />

- Run the script using the command
```bash
./install_docker.sh
```

<img width="720" height="236" alt="1_8PkwCLppHFcLrH02PPN2zA" src="https://github.com/user-attachments/assets/ff8eedb2-6dd7-44ec-bb85-e135b73022af" />

- log out the you log back in.
- Verify if docker has been installed successfully by running the command:
```bash
sudo docker run hello-world
```

<img width="720" height="269" alt="1_W62gBCnDnluyvul71FiRFw" src="https://github.com/user-attachments/assets/4e89d279-705b-40dc-ad88-cc5c6ebc9ad8" />

### STEP 10: — Create and Configure Deployment.

Part 1: Create CodeDeploy Application
- Search for “CodeDeploy” on AWS Management Console

<img width="720" height="304" alt="1_BSULH93dUlk8ugR7V3u_Jw" src="https://github.com/user-attachments/assets/10bb5cad-d1bb-4d34-826f-9f039fcc9543" />

- Click on “CodeDeploy” under “Services”

<img width="720" height="275" alt="1_8yACW_0e-MYxOb7p2EnulA" src="https://github.com/user-attachments/assets/ad5cd327-9f1d-487c-bc09-42736c91ee1b" />

- Click on “Applications” on the left-hand side

<img width="720" height="299" alt="1_uQBKUeVVkONl1HePgIBX1A" src="https://github.com/user-attachments/assets/713b6d37-7d8a-4d29-90f4-42dbde611917" />

- Click on “Create Application”, we will name it “Hotel-App” and choose a compute platform as “EC2/On-premises”.

<img width="720" height="497" alt="1_k2C-Lau7TZ0ZAY0rMmBhqA" src="https://github.com/user-attachments/assets/fb33de25-256a-457f-8dd0-401b29982e59" />

- Click on Create application.

<img width="720" height="347" alt="1_l8UeD16MN0K9a8rr4bb9iw" src="https://github.com/user-attachments/assets/8197d327-90fc-431e-8311-e373a55a91a9" />

Part 2: Create Deployment Group.
- Click on “Create deployment group” and enter a deployment group name. I will use the name “HotelApp-Group”

<img width="720" height="604" alt="1_RrcJ8qU3w1L0RHx23nkdfQ" src="https://github.com/user-attachments/assets/f4159a28-5668-466c-b3ba-17b5e5ebab5b" />

- Under Environment configuration choose “Amazon EC2 instances”. Under Tag group 1: Choose key as “Name” and value as created EC2 instance.

<img width="720" height="637" alt="1_9xzMAnXzlqRVG6BM7X72zg" src="https://github.com/user-attachments/assets/ea40fc49-a72d-42a4-b521-c5d601b6a154" />

- Then scroll to the end and uncheck “Enable Load Balancing”

<img width="720" height="418" alt="1_5yFuEBXDVOPgw3F5_1s_bw" src="https://github.com/user-attachments/assets/d4d876b5-6f6f-4632-8448-2d25935a6a04" />

- Then click on “Create deployment group”.

<img width="720" height="388" alt="1_VmT_ZingYXBunaN3Z07vBA" src="https://github.com/user-attachments/assets/dfc0c151-2d5a-4eb7-a528-04964a79cc0b" />

Part 3: — Create Deployment
- Go to the file “start_container.sh” in your “Scripts” folder in the GitHub repository and provide your docker image and the port.

<img width="720" height="504" alt="1_4M7ZdJ7Owj72yGnDGxsATA" src="https://github.com/user-attachments/assets/0d58655e-b256-4e0a-bc69-d6d3785bc72f" />

- Modify those two lines. You can get the modified lines from Docker

<img width="720" height="250" alt="1_g82hsFU0quk3sCriZdA_QA" src="https://github.com/user-attachments/assets/9a0766ec-44f8-4b03-acf9-f39bc0e63d7f" />

- On the open file in GitHub, click on Edit

<img width="720" height="250" alt="1_VTVy3WsaBUu4wxYegG2JSA" src="https://github.com/user-attachments/assets/d10366e1-354c-4072-88fa-7d5d6666208a" />

- Click on “Commit Changes”

<img width="720" height="429" alt="1_l7FIGexWM2BQh83z4uniug" src="https://github.com/user-attachments/assets/2dcdd3d5-c531-450c-a66c-77f7ea7b2464" />

- Click on “Commit Changes” again

<img width="720" height="253" alt="1_bGRHgDWwcU-desbuozg5Zw" src="https://github.com/user-attachments/assets/10af088e-8a5d-4010-b502-2b5c6b0ec94e" />

- Go back to “Applications”

<img width="720" height="234" alt="1_AxbLk9KUyM8sfqkhmUXg-w" src="https://github.com/user-attachments/assets/3aadb5ee-0f0a-4a59-99da-780bc30b07a4" />

- Select the “Deployments” tab

<img width="720" height="236" alt="1_aAjt4Daeg4_QE5lBXG0vKA" src="https://github.com/user-attachments/assets/0827aad6-8d79-470a-a604-5a3fbb3ae0b8" />

- Under Deployment group click on “create deployment”.

<img width="720" height="806" alt="1_wQZW3tU67n9olTaiCoBtTw" src="https://github.com/user-attachments/assets/151affab-714d-4a7a-af79-894365e88e30" />

- Select the Deployment Group we just created and under revision type choose “My application is stored in GitHub”
- Also go to GitHub and create a Token. Copy the token and paste under “GitHub Token Name” and click on Connect.

<img width="720" height="639" alt="1_5GeJIIHiESyI24JizrQ3Lg" src="https://github.com/user-attachments/assets/6a32ffda-eee3-4980-bca8-2e5b99694577" />

- Give the repo URL and the latest Commit Id from the GitHub.

<img width="720" height="357" alt="1_sqlhddJ3AYVHwjfELgXkeQ" src="https://github.com/user-attachments/assets/b8ad52cc-32e0-4e6d-8dab-4cd55b58d843" />

<img width="720" height="542" alt="1_37T-UutJlI3jw1ARhimofQ" src="https://github.com/user-attachments/assets/cd2a50b7-8376-4e5e-96a8-84d5f3ecaf54" />

- Click on “Create deployment”

<img width="720" height="450" alt="1_fcC1U6ao2x-FeUvK97ed-Q" src="https://github.com/user-attachments/assets/5472bf6d-7204-4854-8fbe-73cf65a7bcc8" />

- And you can see that the deployment is successful

<img width="720" height="189" alt="1__TXIGSbIBM7tKkKR0HklgA" src="https://github.com/user-attachments/assets/f9d8a5e5-e128-43bd-9e4c-e4d3988b0ed6" />

- Here you can find the commit ID
- Verification
- Access the application on <EC2_public_IPv4_Address>:<host port>
- 54.234.18.204:80
- Note: You need to open this port in the instance security group we are using port 80

<img width="720" height="413" alt="1_PXn9IabLu73Po2dBKYfw8w" src="https://github.com/user-attachments/assets/80d3efb6-0a37-4cf6-acd4-6342de052357" />

### STEP 11: — Create an AWS Codepipeline for Seamless flow.
- Navigate to CodePipeline in AWS console and search for “CodePipeline”

<img width="720" height="299" alt="1_aU1DlqMBcOJgqtvzqKZx1w" src="https://github.com/user-attachments/assets/65e3ba47-00d3-4300-b12c-8455177613ad" />

- Click on “CodePipeline”

<img width="720" height="175" alt="1_kq7pakYXAsIOqkH4QIduOg" src="https://github.com/user-attachments/assets/0d8ab0ef-7716-4cfc-bea8-34bc3875f0e5" />

- Click on “create application”

<img width="720" height="256" alt="1_ecpZRctu-LnEVNGlDPNnoQ" src="https://github.com/user-attachments/assets/1c3fcf8a-3521-468f-808f-3d22b84bc095" />

- Select “Build custom pipeline”

<img width="720" height="275" alt="1_5h2s_KsUMMQRx69uO6Cd4A" src="https://github.com/user-attachments/assets/9a2c38dc-9196-4b62-bc63-ee11b8cc28f0" />

- Click on “Next” and provide a name to it. I will name it “Hotel-App-Application”

<img width="720" height="550" alt="1_f1IqA8W-GbM9klErUbs-8Q" src="https://github.com/user-attachments/assets/a4540630-b6ce-4e08-a7b4-a7703aa90fbb" />

<img width="720" height="266" alt="1_TtfSlb3whzHLpqdkQo5quA" src="https://github.com/user-attachments/assets/ba0562d8-c314-4c52-a0ec-b00f9d65487e" />

- Click on “Next”

<img width="720" height="538" alt="1_d0wnIaajPG8opo8wnJ5nBw" src="https://github.com/user-attachments/assets/02000e18-33be-4975-ae9e-f2e0dc68ee3f" />

- Click on “Connect to GitHub”

<img width="720" height="205" alt="1_dXCuCYrd75TIPhQ58TOAWA" src="https://github.com/user-attachments/assets/65c394e2-abef-4dcc-bb7b-70d178b949fb" />

- Click on “Confirm”

<img width="720" height="523" alt="1_mtHUvlO1bSPOanS-9qEpQQ" src="https://github.com/user-attachments/assets/340750dc-6a1d-47a5-8074-d4a0c5587b32" />

<img width="720" height="374" alt="1_lLBI0qYLPU-pTl8UyBalpg" src="https://github.com/user-attachments/assets/70dcc862-a3e9-4790-8fa2-718f8a467b38" />

- Click on “Next”

<img width="720" height="454" alt="1_gJT5slV2kDWyo-hMxU_GCw" src="https://github.com/user-attachments/assets/926baef4-f3e5-4f20-be1c-dca5ce8ed3aa" />

<img width="720" height="237" alt="1_V196MzKAZewiEta8fOkEGQ" src="https://github.com/user-attachments/assets/076d5ebe-a549-4c5b-b138-2488cc195e3b" />

- Click on Next. Under the Deploy Stage Select Deploy Provider as “AWS CodeDeploy”. Then Select the application and the deployment group created.

<img width="720" height="551" alt="1_oOW_ol14LiE6HlJKV_9UZw" src="https://github.com/user-attachments/assets/95bebe9b-9d18-4df5-b096-1b67b3b1d87b" />

- Click on “Next”

<img width="720" height="376" alt="1_NJEABIJWZvkpRVMpYMY59A" src="https://github.com/user-attachments/assets/9a123e1e-8497-4de1-9e33-b7710a16bc6e" />

<img width="720" height="332" alt="1_z-TeXbXOX5su8gWgVijdDA" src="https://github.com/user-attachments/assets/5726d5f6-fec9-4ac0-9609-b2f1ad62cecc" />

- Review and click on “Create Pipeline”

<img width="720" height="395" alt="1_YFf0onemkYY3eWafLJFAxw" src="https://github.com/user-attachments/assets/cd95da80-1c82-43f3-9c9a-605a9c4c939a" />

- The pipeline has been created and it has started running

<img width="720" height="386" alt="1_3Ff0y0VsobFVsUPSd3P0jg" src="https://github.com/user-attachments/assets/b590e2fc-1d50-4ba2-9ec7-cad9f6453d9d" />

<img width="720" height="379" alt="1_oq59LgCcHJfMtNjN9q-f-g" src="https://github.com/user-attachments/assets/d76325ed-82b5-49b6-aff0-f80fc465bc55" />

- You can see that the pipeline is successful
- Access the application with the instance ip:
- Public_IPv4_Address:80, that is 54.234.18.204:80

<img width="720" height="450" alt="1_kRZZ3uy_dPn7dLczbf6kYQ" src="https://github.com/user-attachments/assets/1a998845-288f-432f-b8dd-6c4ebbd4772d" />

- Congratulations you have achieved the seamless Ultimate AWS CICD pipeline.
