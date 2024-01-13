pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
    }
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('Build Function') {
            steps {
                script {
                    sh '/var/lib/jenkins/.local/bin/pip3 install -r requirements.txt -t ./lambda_code'
                }
            }
            
        }
        stage('Terraform Init') {
            steps {
                script {
                    sh ' cd ./iac && terraform init'
                }
            }
        }
        stage('Terraform Plan') {
            steps {
                sh 'pwd'
                sh 'aws sts get-caller-identity'    
                // sh 'cd ./iac && terraform plan -out=tfplan'
            }
        }
        stage('Terraform Apply') {
            steps {
                sh 'aws sts get-caller-identity'
                sh 'pwd'
                // sh 'cd ./iac && terraform apply -auto-approve tfplan'
            }
        }
        stage('Upload State to S3') {
            steps {
                sh 'aws sts get-caller-identity'
                // sh "cd ./iac && aws s3 cp terraform.tfstate s3://daniel-lab-state-bucket/${env.BUILD_NUMBER}/"
                sh 'pwd'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        failure {
            withAWS(credentials: 'daniel-creds') {
                    sh 'aws sts get-caller-identity'
                    script {
                        sh "cd ./iac && terraform apply -auto-approve"
                    }
                }
        }
    }
}