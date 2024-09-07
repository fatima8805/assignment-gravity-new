pipeline{
    agent any
    environment{
        IMAGE_TAG = "${BUILD_NUMBER}"
        AWS_ACCOUNT_ID="account-id"
        AWS_DEFAULT_REGION="ap-south-1"
        IMAGE_REPO_NAME="repo-name"
    }
    options {
      buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '7', numToKeepStr: '10')
      retry(3)
      timestamps()
      throttleJobProperty categories: [], limitOneJobWithMatchingParams: false, maxConcurrentPerNode: 2, maxConcurrentTotal: 2, paramsToUseForLimit: '', throttleEnabled: true, throttleOption: 'project'
    }
    stages{
        stage('Git Checkout Stage') {
            steps{
                git branch: 'main', url: 'https://github.com/fatima8805/assignment-gravity.git'
            }
        }
        stage('Build Stage') {
            steps{
                sh 'mvn clean install'
            }
        }
        stage('SonarQube Analysis Stage') {
            steps{
                withSonarQubeEnv('sonar') { 
                    sh "mvn clean verify sonar:sonar -Dsonar.projectKey=key_name"
                }
            }
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar' 
                }
            } 
        }
        stage('Build docker Image') {
            steps{
                sh 'docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:IMAGE_TAG .'
            }
        }
        stage('Push to ECR') {
            steps{
                withCredentials([aws(credentialsId: "awsCred", region: "ap-south-1")]) {
                script {
                  sh 'aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com'
                  sh 'docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:IMAGE_TAG'
                  }
                }
            }
        }
        stage('Deploy Stage') {
            steps{
                sh 'docker run -itd -p <host_port>:<container_port> ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:IMAGE_TAG'
            }
        } 
      }
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}