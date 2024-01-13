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
                withAWS(credentials: 'daniel-creds') {
                    sh 'aws sts get-caller-identity'
                    script {
                        sh 'pwd'
                        // sh 'cd ./iac && terraform plan -out=tfplan'
                    }
                }
                
            }
        }
        stage('Terraform Apply') {
            steps {
                withAWS(credentials: 'daniel-creds') {
                    sh 'aws sts get-caller-identity'
                    script {
                        sh 'pwd'
                        // sh 'cd ./iac && terraform apply -auto-approve tfplan'
                    }
                }
            }
        }
        stage('Upload State to S3') {
            steps {
                withAWS(credentials: 'daniel-creds') {
                    sh 'aws sts get-caller-identity'
                    script {
                        // sh "cd ./iac && aws s3 cp terraform.tfstate s3://daniel-lab-state-bucket/${env.BUILD_NUMBER}/"
                        sh 'pwd'
                    }
                }
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