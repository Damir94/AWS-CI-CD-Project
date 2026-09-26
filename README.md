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
- Create these files and upload them to your repository.
- Step 1: Create Dockerfile and put these commands in it.

```bash
FROM nginx

COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY index.js /usr/share/nginx/html/
```

- Step 2: Create appspec.yml file and leave these commands into it.
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

- Step 4: Create index.html file and put these codes into it

```bash
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Web Page Title</title>
    <link rel="stylesheet" href="./style.css">
</head>
<body>

<div class="app-container">
  <section class="navigation">
    <a href="#" class="app-link">Travelers</a>
    <div class="navigation-links">
      <a href="#" class="nav-link ">Destinations</a>
      <a href="#" class="nav-link active">Hotels</a>
      <a href="#" class="nav-link">Camping</a>
      <a href="#" class="nav-link">Car Rent</a>
    </div>
    <div class="nav-right-side">
      <button class="mode-switch">
       <svg class="sun" fill="none" stroke="#fbb046" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" class="feather feather-sun" viewBox="0 0 24 24"><defs/><circle cx="12" cy="12" r="5"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>
  <svg class="moon" fill="none" stroke="#ffffff" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" class="feather feather-moon" viewBox="0 0 24 24"><defs/><path d="M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z"/></svg>
     </button>
      <button class="profile-btn">
      <span>Ryan Evans</span>
      <img src="https://images.unsplash.com/photo-1492633397843-92adffad3d1c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2167&q=80" alt="pp">
    </button>
    </div>  
  </section>
  <section class="app-actions">
    <div class="app-actions-line">
      <div class="search-wrapper">
        <button class="loaction-btn">
          <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-map-pin" viewBox="0 0 24 24">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/>
            <circle cx="12" cy="10" r="3"/>
          </svg>
        </button>
        <input type="text" class="search-input" value="San Francisco, Stockton Street">
        <button class="search-btn">Find Hotel</button>
      </div>
      <div class="contact-actions-wrapper">
         <div class="contact-actions">
        <span>Contact us: </span>
        <a href="#" class="contact-link">
          <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-phone"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
        </a>
         <a href="#" class="contact-link">
           <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" fill="currentColor" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-message-circle" viewBox="0 0 24 24">
             <path d="M21 11.5a8.38 8.38 0 01-.9 3.8 8.5 8.5 0 01-7.6 4.7 8.38 8.38 0 01-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 01-.9-3.8 8.5 8.5 0 014.7-7.6 8.38 8.38 0 013.8-.9h.5a8.48 8.48 0 018 8v.5z"/>
           </svg>
         </a>
      </div>
      <div class="contact-actions socials">
        <span>Follow us: </span>
         <a href="#" class="contact-link facebook">
           <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-facebook"><path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"/></svg>
         </a>
         <a href="#" class="contact-link">
           <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" fill="currentColor" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-twitter" viewBox="0 0 24 24">
             <path d="M23 3a10.9 10.9 0 01-3.14 1.53 4.48 4.48 0 00-7.86 3v1A10.66 10.66 0 013 4s-4 9 5 13a11.64 11.64 0 01-7 2c9 5 20 0 20-11.5a4.5 4.5 0 00-.08-.83A7.72 7.72 0 0023 3z"/>
           </svg>
         </a>
      </div>
      </div>
    </div>
    <div class="app-actions-line filter-line">
      <div class="filter-action-buttons">
        <button class="filter-btn">
        <div class="filter-icon">
          <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-calendar"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
        </div>
        <span class="filter-text">Sat,Nov 10-Fri,Nov 22</span>
      </button>
      <button class="filter-btn">
        <div class="filter-icon">
          <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-book"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
        </div>
        <span class="filter-text">Rooms - 2</span>
      </button>
      <button class="filter-btn">
        <div class="filter-icon">
          <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-users" viewBox="0 0 24 24">
            <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/>
            <circle cx="9" cy="7" r="4"/>
            <path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/>
          </svg>
        </div>
        <span class="filter-text">Adults - 2</span>
      </button>
      <button class="filter-btn">
        <div class="filter-icon">
            <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-users" viewBox="0 0 24 24">
            <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/>
            <circle cx="9" cy="7" r="4"/>
            <path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/>
          </svg>
        </div>
        <span class="filter-text">Child - 1</span>
      </button>
      <button class="filter-btn more">
        <div class="filter-icon">
          <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-sliders" viewBox="0 0 24 24">
            <path d="M4 21v-7M4 10V3M12 21v-9M12 8V3M20 21v-5M20 12V3M1 14h6M9 8h6M17 16h6"/>
          </svg>
        </div>
        <span class="filter-text">More</span>
      </button>
      </div>
    </div>
  </section>
  <section class="app-main">
    <div class="app-main-left cards-area">
      <div class="card-wrapper main-card">
        <a class="card cardItemjs"  onclick="openModal()">
          <div class="card-image-wrapper">
          <img src="https://source.unsplash.com/featured/1200x900/?sculpture,hotel" alt="Hotel">
        </div>
          <div class="card-info">
            <div class="card-text big cardText-js">The Grand Budapest Hotel</div>
            <div class="card-text small">Stockton Street</div>
            <div class="card-text small">
              Starts from: 
              <span class="card-price"> $1000</span>
            </div>
          </div>
          </a>
      </div>
       <div class="card-wrapper main-card">
        <a class="card cardItemjs"  onclick="openModal()">
          <div class="card-image-wrapper">
          <img src="https://source.unsplash.com/featured/1200x900/?architecture,hotel" alt="Hotel">
        </div>
          <div class="card-info">
            <div class="card-text big cardText-js">The Grand Canyon Hotel</div>
            <div class="card-text small">Stockton Street</div>
            <div class="card-text small">
              Starts from: 
              <span class="card-price"> $1500</span>
            </div>
          </div>
          </a>
      </div>
       <div class="card-wrapper main-card">
        <a class="card cardItemjs"  onclick="openModal()">
          <div class="card-image-wrapper">
          <img src="https://source.unsplash.com/featured/1200x900/?hotel-room,hotel" alt="Hotel">
        </div>
          <div class="card-info">
            <div class="card-text big cardText-js">The Beakman Spa Hotel</div>
            <div class="card-text small">Stockton Street</div>
            <div class="card-text small">
              Starts from: 
              <span class="card-price"> $1300</span>
            </div>
          </div>
          </a>
      </div>
      <div class="card-wrapper main-card">
        <a class="card cardItemjs"  onclick="openModal()">
          <div class="card-image-wrapper">
          <img src="https://source.unsplash.com/featured/1200x900/?hotel,design" alt="Hotel">
        </div>
          <div class="card-info">
            <div class="card-text big cardText-js">Paloma Hotel & Spa</div>
            <div class="card-text small">Stockton Street</div>
            <div class="card-text small">
              Starts from: 
              <span class="card-price"> $700</span>
            </div>
          </div>
          </a>
      </div>
      <div class="card-wrapper main-card">
        <a class="card cardItemjs"  onclick="openModal()">
          <div class="card-image-wrapper">
          <img src="https://source.unsplash.com/featured/1200x900/?interior,design" alt="Hotel">
        </div>
          <div class="card-info">
            <div class="card-text big cardText-js">The Golden Hours Hotel</div>
            <div class="card-text small">Stockton Street</div>
            <div class="card-text small">
              Starts from: 
              <span class="card-price"> $700</span>
            </div>
          </div>
          </a>
      </div>
      <div class="card-wrapper main-card">
        <a class="card cardItemjs"  onclick="openModal()">
          <div class="card-image-wrapper">
          <img src="https://source.unsplash.com/featured/1200x900/?interior,architecture" alt="Hotel">
        </div>
          <div class="card-info">
            <div class="card-text big cardText-js">The Daydream Hotel & Spa</div>
            <div class="card-text small">Stockton Street</div>
            <div class="card-text small">
              Starts from: 
              <span class="card-price"> $1250</span>
            </div>
          </div>
          </a>
      </div>
      <div class="card-wrapper main-card">
        <a class="card cardItemjs"  onclick="openModal()">
          <div class="card-image-wrapper">
          <img src="https://source.unsplash.com/featured/1200x900/?interior,modern" alt="Hotel">
        </div>
          <div class="card-info">
            <div class="card-text big cardText-js">The Harmony Hotel</div>
            <div class="card-text small">Stockton Street</div>
            <div class="card-text small">
              Starts from: 
              <span class="card-price"> $500</span>
            </div>
          </div>
          </a>
      </div>
      <div class="card-wrapper main-card">
        <a class="card cardItemjs"  onclick="openModal()">
          <div class="card-image-wrapper">
          <img src="https://source.unsplash.com/featured/1200x900/?architecture,modern" alt="Hotel">
        </div>
          <div class="card-info">
            <div class="card-text big cardText-js">The Hotel Star Pasific</div>
            <div class="card-text small">Stockton Street</div>
            <div class="card-text small">
              Starts from: 
              <span class="card-price"> $1400</span>
            </div>
          </div>
          </a>
      </div>
       <div class="card-wrapper main-card">
        <a class="card cardItemjs"  onclick="openModal()">
          <div class="card-image-wrapper">
          <img src="https://source.unsplash.com/featured/1200x900/?hotel,modern" alt="Hotel">
        </div>
          <div class="card-info">
            <div class="card-text big cardText-js">Hotel Roller Coaster </div>
            <div class="card-text small">Stockton Street</div>
            <div class="card-text small">
              Starts from: 
              <span class="card-price"> $1800</span>
            </div>
          </div>
          </a>
      </div>
    </div>
    <div class="app-main-right cards-area">
      <div class="app-main-right-header">
        <span>Latest Deals</span>
        <a href="#">See More</a>
      </div>
      <div class="card-wrapper main-card">
        <a class="card cardItemjs"  onclick="openModal()">
          <div class="card-image-wrapper">
          <img src="https://source.unsplash.com/featured/1200x900/?hotel-room,interior">
        </div>
          <div class="card-info">
            <div class="card-text big cardText-js">Hotel Conrad</div>
            <div class="card-text small">Stockton Street</div>
            <div class="card-text small">
              Starts from: 
              <span  class="card-price"> $1000</span>
            </div>
          </div>
        </a>
      </div>
      <div class="card-wrapper main-card">
        <a class="card cardItemjs"  onclick="openModal()">
          <div class="card-image-wrapper">
          <img src="https://source.unsplash.com/featured/1200x900/?interior,hotel">
        </div>
          <div class="card-info">
            <div class="card-text big cardText-js">The Hotel Riviera</div>
            <div class="card-text small">Stockton Street</div>
            <div class="card-text small">
              Starts from: 
              <span  class="card-price"> $300</span>
            </div>
          </div>
        </a>
      </div>
      <div class="card-wrapper main-card">
        <a class="card cardItemjs"  onclick="openModal()">
          <div class="card-image-wrapper">
          <img src="https://source.unsplash.com/featured/1200x900/?architecture,modern">
        </div>
          <div class="card-info">
            <div class="card-text big cardText-js">The Hotel Star Pasific</div>
            <div class="card-text small">Stockton Street</div>
            <div class="card-text small">
              Starts from: 
              <span class="card-price"> $1400</span>
            </div>
          </div>
          </a>
      </div>
       <div class="card-wrapper main-card">
        <a class="card cardItemjs"  onclick="openModal()">
          <div class="card-image-wrapper">
          <img src="https://source.unsplash.com/featured/1200x900/?hotel,modern">
        </div>
          <div class="card-info">
            <div class="card-text big cardText-js">Hotel Instant Destiny </div>
            <div class="card-text small">Stockton Street</div>
            <div class="card-text small">
              Starts from: 
              <span class="card-price"> $1800</span>
            </div>
          </div>
          </a>
      </div>
      <div class="card-wrapper main-card">
        <a class="card cardItemjs"  onclick="openModal()">
          <div class="card-image-wrapper">
          <img src="https://source.unsplash.com/featured/1200x900/?architecture,modern" alt="Hotel">
        </div>
          <div class="card-info">
            <div class="card-text big cardText-js">The White Roses Hotel</div>
            <div class="card-text small">Stockton Street</div>
            <div class="card-text small">
              Starts from: 
              <span class="card-price"> $700</span>
            </div>
          </div>
          </a>
      </div>
       <div class="card-wrapper main-card">
        <a class="card cardItemjs"  onclick="openModal()">
          <div class="card-image-wrapper">
          <img src="https://source.unsplash.com/featured/1200x900/?hotel,modern" alt="Hotel">
        </div>
          <div class="card-info">
            <div class="card-text big cardText-js">Hotel Tom's Dinner</div>
            <div class="card-text small">Stockton Street</div>
            <div class="card-text small">
              Starts from: 
              <span class="card-price"> $1500</span>
            </div>
          </div>
          </a>
      </div>
    </div>
  </section>
</div>
<div id="modal-window" class="shadow">
  <div class="main-modal">
    <div class="modal-left">
      <div class="modal-image-wrapper">
        <img src="https://source.unsplash.com/featured/1200x900/?design,hotel">
      </div>
      <div class="modal-info-header">
        <div class="left-side">
          <h1 class="modalHeader-js"></h1>
          <p>Stockton Street</p>
        </div>
        <div class="right-side">
          Starts from:
          <span class="amount">$1000</span>
        </div>
      </div>
      <div class="info-bar">
        <div class="info-wrapper">
          <div class="info-icon">
            <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
          </div>
          <span>2 Bedrooms</span>
        </div>
        <div class="info-wrapper">
          <div class="info-icon">
            <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-wind"><path d="M9.59 4.59A2 2 0 1 1 11 8H2m10.59 11.41A2 2 0 1 0 14 16H2m15.73-8.27A2.5 2.5 0 1 1 19.5 12H2"/></svg>
          </div>
          <span>2 Bathrooms</span>
        </div>
        <div class="info-wrapper">
          <div class="info-icon">
            <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-square"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/></svg>
          </div>
          <span>1250m2</span>
        </div>
        <div class="info-wrapper">
          <div class="info-icon">
            <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-shield"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
          </div>
          <span>Highly Secured</span>
        </div>
      </div>
      <div class="desc-wrapper">
        <div class="modal-info-header">
          <h1>Description</h1>
          <p>
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
          </p>
        </div>
        <div class="desc-actions">
          <button class="btn-book">Book Now</button>
          <div class="add-favourite">
            <input type="checkbox" id="favourite">
            <label for="favourite">
              <span class="favourite-icon">
                <svg class="btn-icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-heart"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>  
                </span>
              <span>Add to favourites</span>
            </label>
          </div>
        </div>
      </div>
      </div>
     <div class="modal-right">
       <div class="app-main-right-header">
        <span>Reviews</span>
        <a href="#">See All</a>
      </div>
       <div class="card-wrapper">
         <div class="card">
           <div class="profile-info-wrapper">
             <div class="profile-img-wrapper">
               <img src="https://source.unsplash.com/featured/1200x900/?woman,cool" alt="Review">
             </div>
             <p>Jessica Finnick</p>
           </div>
           <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris</p>
         </div>
      </div>
       <div class="card-wrapper">
         <div class="card">
           <div class="profile-info-wrapper">
             <div class="profile-img-wrapper">
               <img src="https://source.unsplash.com/featured/1200x900/?woman,latina" alt="Review">
             </div>
             <p>Gloria Ramirez</p>
           </div>
           <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris</p>
         </div>
      </div>
       <div class="card-wrapper">
         <div class="card">
           <div class="profile-info-wrapper">
             <div class="profile-img-wrapper">
               <img src="https://source.unsplash.com/featured/1200x900/?man,art" alt="Review">
             </div>
             <p>Luck Besson</p>
           </div>
           <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris</p>
         </div>
      </div>
       <div class="card-wrapper">
         <div class="card">
           <div class="profile-info-wrapper">
             <div class="profile-img-wrapper">
               <img src="https://source.unsplash.com/featured/1200x900/?woman,adventure" alt="Review">
             </div>
             <p>Luna Rosa</p>
           </div>
           <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris</p>
         </div>
      </div>
       <div class="card-wrapper">
         <div class="card">
           <div class="profile-info-wrapper">
             <div class="profile-img-wrapper">
               <img src="https://source.unsplash.com/featured/1200x900/?man,modern" alt="Review">
             </div>
             <p>John mayer</p>
           </div>
           <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris</p>
         </div>
      </div>
       <div class="card-wrapper">
         <div class="card">
           <div class="profile-info-wrapper">
             <div class="profile-img-wrapper">
               <img src="https://source.unsplash.com/featured/1200x900/?woman" alt="Review">
             </div>
             <p>Tina Finnick</p>
           </div>
           <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris</p>
         </div>
      </div>
       <div class="card-wrapper">
         <div class="card">
           <div class="profile-info-wrapper">
             <div class="profile-img-wrapper">
               <img src="https://source.unsplash.com/featured/1200x900/?woman,modern" alt="Review">
             </div>
             <p>July Wallock</p>
           </div>
           <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris</p>
         </div>
      </div>

     </div>
    <button class="btn btn-close" onclick="closeM()">
      <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-x"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
    </button>
    </div>    
  </div>
<script> 
  let ini= document.querySelector('#modal-window');
  ini.classList.add("hideModal");
</script>
<script src="./index.js"></script>
</body>
</html>
```

- Step 5: Create index.js file and add these codes in it.
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

- Step 7: Create style.css file and add these codes in it.
```bash
@import url('https://fonts.googleapis.com/css2?family=Quicksand:wght@400;500;600&display=swap');

* {
  box-sizing: border-box;
  outline: none;
}

:root {
  font-family: 'Quicksand', sans-serif;
  --app-bg: #fff;
  --modal-before: rgba(215,215,215,.5);
  --main-font-color: #000;
  --light-font-color: #becaca;
  --main-border-color:  #f3f3f3;
  --secondary-border-color: #faeceb;
  --button-bg-light: #f3f3f3;
  --cards-area-bg: #f4f4f6;
  --cards-bg: #fff;
  --buttons-color-primary: #d84851;
  --buttons-color-secondary: #f8e4e5;
  --filter-bg: #fff;
  --search-bg: #fff;
}

.dark:root {
  --app-bg: #0c0c0c;
  --main-font-color: #fff;
  --cards-area-bg: #20222a;
  --cards-bg: #111317;
  --filter-bg: #111317;
  --search-bg: #20222a;
  --modal-before: rgba(0, 0, 0, .8);
}

.nav-right-side {
  display: flex;
}

.mode-switch  {
  flex-shrink: 0;
  padding: 0;
  background-color: var(--chat-background);
  border: none;
  color: #ddd;
  outline: none;
  cursor: pointer;
  box-shadow: var(--navigation-box-shadow);
  border-radius: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
  width: 36px;
  height: 36px;
  transform-origin: center;
  
  svg {
    width:0;
    height: 24px;
    transition: all .3s ease-in;
    transform-origin: center;
  }
  
  .moon { opacity: 0; }
  .sun { width: 24px; }
}

.dark .moon {
  opacity: 1;
  width: 24px;
}

.dark .sun {
  opacity: 0;
  width: 0;
}

body, html {
  width: 100%;
  height: 100%;
  margin: 0;
  padding: 0;
  overflow: hidden;
  background-color: var(--app-bg);
  transition: .2s;
}

a {
  text-decoration: none;
}

button, a { cursor: pointer; }

.app-container {
  display: flex;
  flex-direction: column;
  width: 100%;
  height: 100%;
}

.navigation {
  padding: 24px 40px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.app-link {
  font-weight: 600;
  font-size: 20px;
  color: var(--main-font-color);
  line-height: 24px;
}

.navigation-links {
  width: 60%;
  display: flex;
  justify-content: space-between;
  max-width: 420px;
}

.nav-link {
  color: var(--light-font-color);
  font-weight: 500;
  font-size: 14px;
  margin: 0 8px;
  transition: .2s;
  
  &.active {
    color: var(--main-font-color);
  }
  
  &:not(.active):hover {
    color: var(--buttons-color-primary);
  }
}

.profile-btn {
  border: 1px solid var(--secondary-border-color);
  background-color: transparent;
  border-radius: 20px;
  padding: 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  transition: .2s;
  
  .dark & {
    background-color: var(--cards-area-bg);
    border-color: var(--cards-area-bg);
  }
  
  &:hover {
    border-color: var(--buttons-color-primary);
  }
  
  span {
    padding: 0 8px;
    font-weight: 500;
    color: var(--buttons-color-primary);
  }
  
  img{
    width: 32px;
    height: 32px;
    border-radius: 50%;
    object-fit: cover;
  }
}

section.app-actions {
  padding: 32px 40px 0 40px;
}

.btn-icon {
  width: 16px;
}

.search-wrapper {
  border: none;
  display: flex;
  justify-content: space-between;
  border-radius: 6px;
  max-width: 420px;
  width: 100%;
  overflow: hidden;
  height: 40px;
}

.search-input {
  border-radius: 0;
  appearance: none;
  box-shadow: none;
  border-left: none;
  border-right: none;
  background-color: var( --search-bg);
  flex: 1;
  border: 1px solid var(--main-border-color);
  padding: 0 8px;
  font-size: 16px;
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  width: 100%;
  
  .dark & {
    border-color: var( --search-bg);
    color: #fff;
  }
}

.loaction-btn {
  padding: 0;
  border: 1px solid var(--main-border-color);
  background-color: var(--button-bg-light);
  padding: 8px;
  display: flex;
  justify-content: center;
  align-items: center;
  
  .dark & {
   border: none;
    background-color: var( --search-bg);
  }
}

.dark .loaction-btn .btn-icon {
   color: #fff;
}

.search-btn {
  background-color: var(--buttons-color-primary);
  color: #fff;
  border: 1px solid var(--buttons-color-primary);
  padding: 10px 16px;
  font-size: 14px;
  
  .dark & {
   border: none;
  } 
}

.app-actions-line {
  display: flex;
  align-items: center;
  margin: 32px 0;
}

.contact-actions {
  display: flex;
  align-items: center;
  margin-left: 32px;
  
  span {
    display: block;
    font-size: 14px;
    line-height: 16px;
    font-weight: 500;
    margin-right: 8px;
    
    .dark & { color: #fff; }
  }
  
  &.socials .contact-link {
    color: #b9b9b9;
  }
}

.contact-link {
  border: 1px solid var(--main-border-color);
  border-radius: 8px;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--buttons-color-primary);
  margin: 0 4px;
  flex-shrink: 0;
}

.filter-btn {
  background-color: transparent;
  border: 1px solid var(--main-border-color);
  display: flex;
  align-items: center;
  border-radius: 20px;
  padding: 0;
  padding-right: 8px;
  margin: 0 16px;
  color: var(--buttons-color-primary);
  position: relative;
  
  .dark & {
    border-color: var(--cards-area-bg);
    background-color: var(--cards-area-bg);
  }
  
  &.more {
    padding: 0 12px;
    span {
      color: var(--buttons-color-primary);
      padding: 0 4px;
      
      &:before {
        display: none;
      }
    }
    
    .filter-icon {
      background-color: transparent;
    }
  }
}

.filter-text {
  display: block;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 200px;
  padding: 0 24px 0 8px;
  position: relative;
  
  &:before {
    content: '';
    position: absolute;
    width: 16px;
    height: 16px;
    right: 0;
    top: 50%;
    transform: translatey(-50%);
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' class='feather feather-chevron-down'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: center;
    background-size: cover;
  }
  
  .dark & {
    &:before {
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='%23fff' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' class='feather feather-chevron-down'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
    }
  }
}

.filter-icon {
  background-color: var(--buttons-color-secondary);
  border-radius: 50%;
  color: var(--buttons-color-primary);
  width: 32px;
  height: 32px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.filter-line-text {
  font-size: 14px;
  font-weight: 600;
  margin-right: 32px;
  color: var(--main-font-color);
}

.app-main {
  flex: 1;
  overflow: hidden;
  padding: 24px 40px;
  display: flex;
  justify-content: space-between;
}

.cards-area {
  background-color: var(--cards-area-bg);
  padding: 24px;
  height: 100%;
  overflow-y: auto;
  border-radius: 20px;
}

.app-main-left {
  flex: 4;
  display: flex;
  flex-wrap: wrap;
}

.app-main-right {
  flex: 2;
  margin-left: 24px;
  max-width: 400px;
  
  .card-image-wrapper {
    max-height: 100%;
    padding: 0;
    height: 100%;
  }
  
  .card {
    height: 160px;
  }
  
  .card-image-wrapper img {
    margin: 0;
  }
}

.card-wrapper {
  width: 33.3%;
  height: auto;
  padding: 8px;
}

.card {
  background-color: var(--cards-bg);
  border: 3px solid var(--cards-bg);
  border-radius: 10px;
  overflow: hidden;
  display: block;
  transition: transform .2s;
  
  &:hover {
    transform: scale(1.02);
  }
}

.card-image-wrapper {
  max-height: 40%;
  border-radius: 10px;
  overflow: hidden;
  border: 3px solid var(--cards-bg);
  overflow: hidden;
  height: 0;
  padding-top: calc(591.44 / 1127.34 * 100%);
  background-color: #FAACA8;
  background-image: linear-gradient(19deg, #FAACA8 0%, #DDD6F3 100%);
  
  img {
    width: 100%;
    object-fit: cover;
    z-index: 1;
    position: relative;
    z-index: 1;
    position: relative;
    margin-top: -60.25%;
  }
}

.card-info {
  background-color: var(--cards-bg);
  padding: 8px 16px;
}

.card-text {
  line-height: 24px;
  
  &.big {
    font-size: 16px;
    font-weight: 600;
    color: var(--main-font-color);
  }
  
  &.small {
    font-size: 12px;
    color: var(--light-font-color);
    font-weight: 600;
    
    span {
      font-size: 12px;
      color: var(--main-font-color);
      font-weight: 600;
      display: inline-block;
      margin-left: 8px;
    }
  }
}

.app-main-right-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 0;
  color: var(--main-font-color);
  background-color: var(--cards-area-bg);
  
  span {
    font-size: 24px;
    line-height: 32px;
    font-weight: 600;
  }
  
  a {
    font-size: 14px;
    color: var(--buttons-color-primary);
    font-weight: 600;
  }
}

.app-main-right {
  position: relative;
  padding-top: 0;
  
  .card-wrapper {
    width: 100%;
    padding:  8px 0;
  }
  
  .card {
    display: flex;
  }
  
  .card-image-wrapper {
    flex-basis: 40%;
    flex-shrink: 0;
    
    img {
      height: 100%;
    }
  }
}


.main-modal {
  width: 98%;
  max-width: 1200px;
  height: 90%;
  background: var(--app-bg);
  border-radius: 20px;
  position: relative;
  display: flex;
  padding: 32px;
}

.btn-close {
  border: none;
  background-color: transparent;
  position: absolute;
  right: 4px;
  top: 4px;
  padding: 0;
  color: #b9b9b9;
}

.hideModal{
  z-index:-1;
  opacity:0;
  animation: hide .25s;
  transform: scale(0);
}

@keyframes hide {
  from {
    z-index:2;
    transform: scale(1);
    opacity:1;
  }
  
  to {
    z-index:-1;
    transform: scale(0);
    opacity: 0;
  }
}

.showModal {
  top: 0;
  left: 0;
  opacity:1;
  z-index:2;
  animation: show .2s;
  transform: scale(1);
  position: fixed;
  display: flex;
  justify-content: center;
  width: 100%;
  padding-top: 56px;
  background-color: var(--modal-before);
  width: 100%;
  height: 100%;
}

@keyframes show {
  from {
    transform: scale(0);
    opacity:0;
    z-index:-1;
  }
  to{    
    transform: scale(1);
    opacity: 1;
    z-index:2;
  }
}

.modal-image-wrapper {
  border-radius: 20px;
  overflow: hidden;
  max-height: 50%;
  
  img {
    width: 100%;
    height: auto;
    object-fit: cover;
  }
}

.modal-left {
  flex: 5;
  overflow-y: auto;
}

.modal-image-wrapper {
  margin-bottom: 24px;
}

.modal-info-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.left-side {
  h1 {
    margin: 0;
    font-size: 24px;
    line-height: 32px;
    color: var(--main-font-color);
  }
  
  p {
    color: var(--light-font-color);
    font-size: 16px;
    line-height: 24px;
  }
}

.right-side {
  color: var(--main-font-color);
  
  span {
    display: inline-block;
    font-weight: 500;
    font-size: 16px;
    line-height: 32px;
  }
}

.info-wrapper {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  
  span {
    display: block;
    font-weight: 500;
    font-size: 14px;
    color: var(--main-font-color);
  }
}

.info-bar {
  display: flex;
  justify-content: space-between;
}

.info-icon {
  background-color: var(--buttons-color-secondary);
  border-radius: 50%;
  color: var(--buttons-color-primary);
  width: 32px;
  height: 32px;
  display: flex;
  justify-content: center;
  align-items: center;
  margin-right: 12px;
  flex-shrink: 0;
}

.desc-wrapper {
  .modal-info-header {
    margin-top: 24px;
    flex-direction: column;
  }
  
  h1 {
    font-size: 24px;
    margin: 0;
    line-height: 32px;
    color: var(--main-font-color);
  }
  
  p {
    color: var(--light-font-color);
  }
}

.desc-actions {
  display: flex;
  align-items: center;
  margin-top: 32px;
}

.btn-book {
  background-color: var(--buttons-color-primary);
  color: #fff;
  border: none;
  border-radius: 6px;
  font-size: 16px;
  margin-right: 32px;
  padding: 10px;
  font-size: 14px;
  min-width: 120px;
}

.add-favourite {
  display: flex;
  align-items: center;
}

.add-favourite input {
  width: 0;
  height: 0;
  opacity: 0;
  position: absolute;
  
  &:checked + label {
    color: var(--buttons-color-primary);
    
    .btn-icon {
      transition: .2s;
      color: var(--buttons-color-primary);
      fill: var(--buttons-color-primary);
    }
  }
}

.add-favourite label {
  cursor: pointer;
  color: var(--light-font-color);
  font-size: 14px;
  line-height: 24px;
  font-weight: 500;
  display: flex;
  align-items: center;
  
  span {
    display: flex;
    margin-right: 4px;
  }
}

.modal-right {
  background-color: var(--cards-area-bg);
  height: 100%;
  overflow-y: auto;
  border-radius: 20px;
  padding: 0 16px;
  flex: 3;
  max-width: 320px;
  margin-left: 16px;
  
  .card-wrapper {
    width: 100%;
    padding: 8px 0;
  }

  .card > p {
    font-size: 12px;
    line-height: 16px;
    color: var(--light-font-color);
    margin: 0;
  }
  
   .card {
    padding: 8px;
     
     &:hover {
       transform: scale(1);
     }
    
    .profile-info-wrapper {
      display: flex;
      align-items: flex-start;
      margin-bottom: 16px;
      
      p {
        font-size: 12px;
        line-height: 16px;
        color: var(--main-font-color);
        margin: 0;
        font-weight: 600;
      }
    }
  }
}

.profile-img-wrapper {
  width: 32px;
  height: 32px;
  overflow: hidden;
  border-radius: 8px;
  flex-shrink: 0;
  margin-right: 12px;
  
  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}

.contact-actions-wrapper {
  display: flex;
}

.filter-action-buttons { 
  display: flex;
  overflow-x: auto;
  position: relative;
  
  button {
    margin-bottom: 4px;
  }
}

.filter-line {
  align-items: flex-start;
}

@media screen and (max-width: 1020px) {
  .app-main-left .card-wrapper {
    width: 50%;
  }
  
  .app-main-right-header span {
    font-size: 14px;
  }
}

@media screen and (max-width: 990px) {
  .app-main-right {
    display: none;
  }
}

@media screen and (max-width: 780px) {
  .filter-line-text {
    margin-right: 10px;
  }
  
  .filter-btn {
    margin: 0 8px;
  }
  
  .modal-left {
    flex-shrink: 0;
    flex-basis: auto;
  }
  
  .app-actions-line:not(.filter-line) {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .app-actions-line {
    margin: 16px 0;
  }
  
  .contact-actions-wrapper {
    margin-top: 12px;
    
    .contact-actions:first-child { margin-left: 0;} 
  }
  
  .app-main-left .card-wrapper {
    width: 100%;
  }
  
  .cards-area {
    padding: 0 8px;
  }
  
  .navigation {
    padding: 24px;
  }
  
  .app-main, .app-actions {
    padding: 24px;
  }
  
  section.app-actions {
    padding: 0 24px;
  }
  
  h1, .modal-left h1 {
    font-size: 16px;
    line-height: 24px;
  }
  .info-wrapper span {
    font-size: 12px;
    white-space: nowrap;
    margin-bottom: 4px;
  }
  
  .main-modal {
    flex-direction: column;
    overflow-y: auto;
    height: 100%;
    width: 100%;
  }
  
  #modal-window {
    padding: 0;
  }
  
  .modal-right {
    width: 100%;
    max-width: 100%;
    margin-left: 0;
    margin-top: 16px;
    overflow-y: visible;
  }
  
  .btn-close {
    right: 0;
    top: 0;
  }
}

@media screen and (max-width: 660px) {
  .navigation-links { display: none; }
}

@media screen and (max-width: 520px) {
  .app-container {
    overflow: auto;
  }

  .app-main {
    flex: unset;
  }
  
  .modal-right {
    flex: unset;
  }
  
  .card:hover {
    transform: scale(1);
  } 
  
  section.app-main {
    overflow: visible;
  }
  
  .contact-actions span { display: none; }
}
```

- Step 8: Create a folder called scripts and add two files start_container.sh and stop_container.sh respectively.
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
