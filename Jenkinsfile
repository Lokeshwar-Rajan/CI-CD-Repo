pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Choose Terraform action: apply (provision) or destroy (delete)')
    }

    environment {
        AWS_REGION = 'us-east-1'
        AWS_CREDENTIALS = 'aws-creds'
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
            stage('Fetch ECR Repo URL') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'aws-creds',
                                                 usernameVariable: 'AWS_ACCESS_KEY_ID',
                                                 passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
            sh '''
                ECR_REPO=$(aws ecr describe-repositories --repository-names my-app --query "repositories[0].repositoryUri" --output text)
                echo "✅ ECR Repo: $ECR_REPO"
                echo "ECR_REPO=$ECR_REPO" > ecr_env
            '''
        }
    }
}

stage('Build Docker Images') {
    steps {
        dir('Frontend') {
            sh "docker build -t frontend:latest ."
        }

        dir('Backend') {
            sh "docker build -t backend:latest ."
        }
    }
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
                stage('Tag & Push Docker Images') {
    steps {
        script {
            def ECR_REPO = readFile('ecr_env').trim().split('=')[1]
            sh """
                # Tag and push frontend
                docker tag frontend:latest ${ECR_REPO}:frontend-latest
                docker push ${ECR_REPO}:frontend-latest

                # Tag and push backend
                docker tag backend:latest ${ECR_REPO}:backend-latest
                docker push ${ECR_REPO}:backend-latest
            """
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
