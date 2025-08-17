pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        // Jenkins credentials ID storing AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
        AWS_CREDENTIALS = 'aws-creds'
        FRONTEND_IMAGE_TAG = 'frontend-latest'
        BACKEND_IMAGE_TAG = 'backend-latest'
        ECR_REPO_NAME = 'my-repo'
        TERRAFORM_DIR = 'Terraform'
        TF_VAR_FILE = '/home/jenkins/terraform.tfvars'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/Lokeshwar-Rajan/CI-CD-Repo.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS}"]]) {
                    dir("${TERRAFORM_DIR}") {
                        sh 'terraform init'
                        sh "terraform apply -auto-approve -var-file='${TF_VAR_FILE}'"
                    }
                }
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS}"]]) {
                    sh """
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com
                    """
                }
            }
        }

        stage('Build & Push Frontend Docker Image') {
            steps {
                script {
                    docker.build("${ECR_REPO_NAME}:${FRONTEND_IMAGE_TAG}", './Frontend')
                    sh """
                    docker tag ${ECR_REPO_NAME}:${FRONTEND_IMAGE_TAG} $(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${FRONTEND_IMAGE_TAG}
                    docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${FRONTEND_IMAGE_TAG}
                    """
                }
            }
        }

        stage('Build & Push Backend Docker Image') {
            steps {
                script {
                    docker.build("${ECR_REPO_NAME}:${BACKEND_IMAGE_TAG}", './Backend')
                    sh """
                    docker tag ${ECR_REPO_NAME}:${BACKEND_IMAGE_TAG} $(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${BACKEND_IMAGE_TAG}
                    docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${BACKEND_IMAGE_TAG}
                    """
                }
            }
        }

        stage('Update ECS Services') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS}"]]) {
                    sh """
                    # Update frontend
                    aws ecs update-service --cluster myapp-cluster --service myapp-cluster-frontend-svc --force-new-deployment
                    # Update backend
                    aws ecs update-service --cluster myapp-cluster --service myapp-cluster-backend-svc --force-new-deployment
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment Successful! ECS Services Updated!'
        }
        failure {
            echo 'Deployment Failed! Check the logs for errors.'
        }
    }
}
