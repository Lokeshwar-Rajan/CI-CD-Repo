pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        ECR_REGISTRY = "521926169182.dkr.ecr.us-east-1.amazonaws.com"
        FRONTEND_REPO = "my-frontend"
        BACKEND_REPO = "my-backend"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/Lokeshwar-Rajan/CI-CD-Repo.git'
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds',
                                                 usernameVariable: 'AWS_ACCESS_KEY_ID',
                                                 passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws configure set default.region ${AWS_REGION}

                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                    '''
                }
            }
        }

        stage('Build Backend Image') {
            steps {
                sh '''
                    docker build -t ${ECR_REGISTRY}/${BACKEND_REPO}:latest ./Backend
                '''
            }
        }

        stage('Push Backend Image') {
            steps {
                sh '''
                    docker push ${ECR_REGISTRY}/${BACKEND_REPO}:latest
                '''
            }
        }

        stage('Build Frontend Image') {
            steps {
                sh '''
                    docker build -t ${ECR_REGISTRY}/${FRONTEND_REPO}:latest ./Frontend
                '''
            }
        }

        stage('Push Frontend Image') {
            steps {
                sh '''
                    docker push ${ECR_REGISTRY}/${FRONTEND_REPO}:latest
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Build and Push completed successfully!'
        }
        failure {
            echo '❌ Build failed!'
        }
    }
}
