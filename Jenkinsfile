pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Choose Terraform action: apply (provision) or destroy (delete)')
    }

    environment {
        AWS_REGION = 'us-east-1'
        AWS_CREDENTIALS = 'aws-creds'
        ECR_REGISTRY = "521926169182.dkr.ecr.us-east-1.amazonaws.com"
        FRONTEND_IMAGE_TAG = 'frontend'
        BACKEND_IMAGE_TAG = 'backend'
        ECR_REPO_NAME = 'my-repo'
        TERRAFORM_DIR = 'Terraform'
        TF_VAR_FILE = '/home/jenkins/terraform.tfvars'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/Lokeshwar-Rajan/CI-CD-Repo.git'
            }
        }

        stage('Terraform Action') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds',
                                                 usernameVariable: 'AWS_ACCESS_KEY_ID',
                                                 passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir("${TERRAFORM_DIR}") {
                        script {
                            if (params.ACTION == 'apply') {
                                sh 'terraform init'
                                sh 'terraform apply -auto-approve -var-file=${TF_VAR_FILE}'
                            } else if (params.ACTION == 'destroy') {
                                sh 'terraform init'
                                sh 'terraform destroy -auto-approve -var-file=${TF_VAR_FILE}'
                            }
                        }
                    }
                }
            }
        }

        stage('Build & Push Images and Update ECS') {
            when {
                expression { params.ACTION == 'apply' }
            }
            stages {
                stage('Login to ECR') {
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'aws-creds',
                                                         usernameVariable: 'AWS_ACCESS_KEY_ID',
                                                         passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                            sh '''
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com
                            '''
                        }
                    }
                }

                stage('Build & Push Frontend Docker Image') {
                    steps {
                        script {
                            docker.build("${ECR_REPO_NAME}:${FRONTEND_IMAGE_TAG}", './Frontend')
                            sh '''
                            docker tag ${ECR_REPO_NAME}:${FRONTEND_IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPO_NAME}:${FRONTEND_IMAGE_TAG}
                            docker push ${ECR_REGISTRY}/${ECR_REPO_NAME}:${FRONTEND_IMAGE_TAG}
                            '''
                        }
                    }
                }

                stage('Build & Push Backend Docker Image') {
                    steps {
                        script {
                            docker.build("${ECR_REPO_NAME}:${BACKEND_IMAGE_TAG}", './Backend')
                            sh '''
                            docker tag ${ECR_REPO_NAME}:${BACKEND_IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPO_NAME}:${BACKEND_IMAGE_TAG}
                            docker push ${ECR_REGISTRY}/${ECR_REPO_NAME}:${BACKEND_IMAGE_TAG}
                            '''
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline finished successfully with ACTION = ${params.ACTION}"
        }
        failure {
            echo "Pipeline failed. ACTION = ${params.ACTION}"
        }
    }
}
