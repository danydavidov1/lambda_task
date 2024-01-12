pipeline {
    agent any
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('Build Function') {
            steps {
                script {
                    sh 'pip3 install -r requirements.txt -t ./lambda_code'
                }
            }
            
        }
        stage('Terraform Init') {
            steps {
                script {
                    sh 'terraform init'
                }
            }
        }
        stage('Terraform Plan') {
            steps {
                script {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
        stage('Upload State to S3') {
            steps {
                script {
                    sh "aws s3 cp terraform.tfstate s3://daniel-lab-state-bucket/${env.BUILD_NUMBER}/"
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}