Getting Started
---------------
This is a demo project for education/training purposes of DevOps. All the services used below are in the Cloud to
facilitate the understanding.

[![CI/CD Pipeline](https://github.com/fvilarinho/akamai-linode-demo/actions/workflows/pipeline.yml/badge.svg)](https://github.com/fvilarinho/akamai-linode-demo/actions/workflows/pipeline.yml)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=fvilarinho_akamai-linode-demo&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=fvilarinho_akamai-linode-demo)

The pipeline uses [`GitHub Actions`](https://github.com/features/actions)  that contains 8 main phases described below. 
The environment variables values are defined in the [`Github Actions Secrets`](https://docs.github.com/en/actions/security-guides/encrypted-secrets).

### Compile, Build & Test
All commands of this phase are defined in `build.sh` and `test.sh` files. 
It checks compile/build errors and also does unit and integration tests.
The tools used are:
- [`Gradle`](https://www.gradle.org)

### Code analysis
All commands of this phase are defined in `codeAnalysis.sh` file. 
It checks bugs, vulnerabilities, hotspots, code smells, duplications in the code and also the testing coverage.
If these metrics don't comply with the defined quality gate, the pipeline won't execute the next phases.
The tools used are:
- [`Gradle`](https://www.gradle.org)
- [`Sonar`](https://sonardcloud.io)

Environments variables needed in this phase:
- `GITHUB_TOKEN`: API Key used by Sonar client to communicate with GitHub.
- `SONAR_TOKEN`: API Key used by Sonar client to store the generated analysis.
- `SONAR_ORGANIZATION`: Identifier of the Sonar account.
- `SONAR_PROJECT_KEY`: Identifier of the Sonar project.
- `SONAR_URL`: URL of the Sonar server (By default, we use Sonarcloud infrastructure).

### IaC (Infrastructure ad Code) analysis
All commands of this phase are defined in `iacAnalysis.sh` file.
It checks for vulnerabilities the IaC files (Dockerfiles, Compose and Kubernetes manifests).
The tools used are:
- [`Snyk`](https://snyk.io)

### Libraries analysis
All commands of this phase are defined in `librariesAnalysis.sh` file. 
It checks for vulnerabilities in internal and external libraries used in the code.
The tools used are:
- [`Snyk`](https://snyk.io)

Environments variables needed in this phase:
- `SNYK_TOKEN`: API Key used by Snyk to store the generated analysis.

### Packaging
All commands of this phase are defined in `package.sh` file.
It encapsulates all binaries in a Docker image.
Once the code, libraries and IaC files were checked, it's time build the package to be used in the next phases.
The tools/services used are:
- [`Docker Compose`](https://docs.docker.com/compose)

Environments variables needed in this phase:
- `DOCKER_REGISTRY_URL`: URL of the packages' repository.
- `DOCKER_REGISTRY_ID`: Identifier of the packages' repository.

### Package analysis
All commands of this phase are defined in `packageAnalysis.sh` file.
It checks for vulnerabilities in the generated packages.
The tools/services used are:
- [`Snyk`](https://snyk.io)

Environments variables needed in this phase:
- `SNYK_TOKEN`: API Key used by Snyk to store the generated analysis.

### Publishing
All commands of this phase are defined in `publish.sh` file.
It publishes the packages in the repository.
The tools/services used are:
- [`Docker Compose`](https://docs.docker.com/compose)
- [`Github Packages`](https://github.com)

Environments variables needed in this phase:
- `DOCKER_REGISTRY_PASSWORD`: Password of the packages' repository.

### Deploy
All commands of this phase are defined in `deploy.sh` file.
It deploys the packages in a K3S (Kubernetes) cluster (2 nodes) with a load balancer in Linode and Akamai.
The tools/services used are:
- [`Terraform`](https://terraform.io) 
- [`Linode`](https://www.linode.com)
- [`Akamai`](https://www.akamai.com)

Environments variables needed in this phase:
- `TERRAFORM_CLOUD_TOKEN`: Token used to authenticate with Terraform Cloud.
- `ENVIRONMENT_ATTRIBUTES`: Contains all attributes needed for Terraform IaC files. If the environment variables doesn't
exist, it will use the file `$HOME/.environment.tfvars`. This file must contains the values of the variables defined in 
`iac/variables.tf`.

### Comments
- **If any phase got errors or violations, the pipeline will stop.**
- **All environments variables must also have a secret with the same name.** 
- **You can define the secret in the repository settings.**
- **DON'T EXPOSE OR COMMIT ANY SECRET IN THE PROJECT.**

### Architecture and requirements.
- [`Java 11`](https://www.java.com/en/) - Programming language. 
- [`Amazon Corretto`](https://aws.amazon.com/pt/corretto/?filtered-posts.sort-by=item.additionalFields.createdDate&filtered-posts.sort-order=desc) - OpenJDK installation.
- [`Spring Boot 2.7.x`](https://spring.io) - Web development framework.
- [`Gradle 6.9.x`](https://www.gradle.org) - Automation tool.
- [`Mockito 3.x`](https://site.mockito.org/) - Test framework.
- [`JUnit 5.x`](https://junit.org/junit5) - Test framework.
- [`Terraform 1.3.x`](https://www.terraform.io) - IaC automation tool.
- [`Snyk CLI 1.x`](https://snyk.io) - CLI for the SAST tool.
- [`Kubectl`](https://kubernetes.io/docs/tasks/tools/) - Kubernetes CLI.
- [`MariaDB 10.x`](https://mariadb.com/) - Database server.
- [`Flyway 9.12.x`](https://flywaydb.org/) - Database versioning.
- [`Nginx 1.x`](https://www.nginx.com/****) - Web server.
- [`Docker 20.10.x`](https://www.docker.com) - Containerization platform.
- [`K3S 1.24.x`](https://k3s.io) - Containers orchestrator.

For further documentation please check the documentation of each tool/service.

### How to install
1. `Linux` or `macOS` operating system.
2. You need an IDE such as [`IntelliJ`](https://www.jetbrains.com/pt-br/idea).
3. You need an account in the following services:
`GitHub`, `Sonarcloud`, `Snyk`, `Linode`, `Terraform Cloud` and `Akamai`.
4. You need to set the environment variables described above in you system.
5. The tokens and credentials for each service must be defined in the UI of each service. Please refer the service 
documentation.
6. Fork this project from [`GitHub`](https://www.github.com).
7. Install `Amazon Corretto`, `Gradle`, `Terraform`, `Snyk CLI`, `Kubectl` and `Docker` on your local environment.
8. Import the project in IDE.
9. Commit some changes in the code and follow the execution of the pipeline in [`GitHub`](https://www.github.com).

### How to run it locally
1. In the project directory, execute the scripts below:
`./build.sh; ./package.sh; ./start.sh`
2. Open the URL `http://localhost` in your preferred browser after the boot.

### How to run it in the Cloud
1. Run the `deploy.sh` script that will provision the infrastructure.
2. Open the URL `http://<load-balancer-ip|akamai-property-hostname>` in your preferred browser, after the boot. By
default, the Akamai Property Hostname is deployed in staging network. Don't forget to spoof the Akamai Staging Network
in the hosts file of your machine. If you change the deploy to push the Akamai Property into the production network, 
don't forget to update the Akamai Property Hostname in your DNS server with the Akamai Edge Hostname or to spoof the 
Akamai Production Network in the hosts file of your machine.

That's it! Now enjoy and have fun!

### Contact
**LinkedIn:**
- https://www.linkedin.com/in/fvilarinho

**e-Mail:**
- fvilarin@akamai.com
- fvilarinho@gmail.com
- fvilarinho@outlook.com
- me@vila.net.br
