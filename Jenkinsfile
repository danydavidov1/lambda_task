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
                sh 'pwd && ls'
                sh 'aws sts get-caller-identity'    
                sh 'cd ./iac && terraform plan -out=tfplan'
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    try {
                        sh 'aws sts get-caller-identity'
                        sh 'cd ./iac && terraform apply -auto-approve tfplan'
                    } catch (Exception e) {
                        sh 'cd ./iac && terraform destory -auto-approve'
                    }
                }
                
            }
        }
        stage('Upload State to S3') {
            steps {
                script {
                    try {
                        sh 'aws sts get-caller-identity'
                        sh "cd ./iac && aws s3 cp terraform.tfstate s3://daniel-lab-state-bucket/${env.BUILD_NUMBER}/"
                    } catch (Exception e) {
                        sh """
                            mkdir -p /tmp/tfstate/${env.BUILD_NUMBER}
                            cd ./iac && cp terraform.tfstate /tmp/tfstate/${env.BUILD_NUMBER}/
                        """
                        echo "faild to upload terraform state to bucket, state location on agent: /tmp/tfstate/${env.BUILD_NUMBER}/"
                    }
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