pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = "nguyentt07"
        IMAGE_NAME = "shoestore"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        SONAR_PROJECT_KEY = "shoestore"
        SONAR_PROJECT_NAME = "Shoestore"
        SONAR_PROJECT_VERSION = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        
        stage('Code Analysis with SonarQube') {
            steps {
                echo 'Running SonarQube analysis...'
                script {
                    // Cài đặt SonarQube Scanner nếu chưa có
                    sh 'dotnet tool install --global dotnet-sonarscanner --version 5.13.0'
                    
                    // Bắt đầu phân tích SonarQube
                    sh 'dotnet sonarscanner begin /key:"${SONAR_PROJECT_KEY}" /name:"${SONAR_PROJECT_NAME}" /version:"${SONAR_PROJECT_VERSION}" /d:sonar.host.url="http://localhost:9000" /d:sonar.login="admin" /d:sonar.password="Dnsdud00@@@@"'
                    
                    // Build project
                    sh 'dotnet build'
                    
                    // Kết thúc phân tích SonarQube
                    sh 'dotnet sonarscanner end /d:sonar.login="admin" /d:sonar.password="Dnsdud00@@@@"'
                }
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'dotnet test --no-build --verbosity normal'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    try {
                        sh 'docker --version'
                        sh 'docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} .'
                        sh 'docker tag ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest'
                        echo 'Docker image built successfully!'
                    } catch (Exception e) {
                        echo 'Docker build failed: ' + e.getMessage()
                        echo 'Please ensure Docker is installed and running on Jenkins server'
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
        
        stage('Push to Docker Hub') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                }
            }
            steps {
                echo 'Pushing to Docker Hub...'
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                        sh 'docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}'
                        sh 'docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest'
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo 'Build succeeded!'
            echo 'SonarQube analysis completed. Check: http://localhost:9000'
        }
        failure {
            echo 'Build failed!'
        }
        unstable {
            echo 'Build unstable - check Docker installation or SonarQube configuration'
        }
    }
}
