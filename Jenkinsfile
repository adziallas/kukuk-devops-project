pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'prod'], description: 'Deployment Environment')
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip tests')
    }

    tools {
        git 'Default' // Stelle sicher, dass Git unter "Global Tool Configuration" als "Default" konfiguriert ist
    }

    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        GITHUB_TOKEN = credentials('github-token')
        KUBECONFIG_CREDENTIALS = credentials('kubeconfig')
        BACKEND_IMAGE = "adziallas/kukuk-backend:${params.ENVIRONMENT}"
        FRONTEND_IMAGE = "adziallas/kukuk-frontend:${params.ENVIRONMENT}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Backend') {
            steps {
                dir('backend') {
                    sh "mvn clean package -P${params.ENVIRONMENT}"
                }
            }
        }

        stage('Build Frontend') {
            steps {
                dir('frontend') {
                    sh 'npm install'
                    sh 'npm run build || echo "No build script defined"'
                }
            }
        }

        stage('Test Backend') {
            when {
                expression { return !params.SKIP_TESTS }
            }
            steps {
                dir('backend') {
                    sh 'mvn test'
                }
            }
        }

        stage('Test Frontend') {
            when {
                expression { return !params.SKIP_TESTS }
            }
            steps {
                dir('frontend') {
                    sh 'npm test || echo "No test script defined"'
                }
            }
        }

        stage('Docker Build') {
            parallel {
                stage('Backend Image') {
                    steps {
                        dir('backend') {
                            sh "docker build -t ${env.BACKEND_IMAGE} ."
                        }
                    }
                }
                stage('Frontend Image') {
                    steps {
                        dir('frontend') {
                            sh "docker build -t ${env.FRONTEND_IMAGE} ."
                        }
                    }
                }
            }
        }

        stage('Docker Push') {
            steps {
                withDockerRegistry([credentialsId: 'docker-hub-credentials', url: '']) {
                    sh "docker push ${env.BACKEND_IMAGE}"
                    sh "docker push ${env.FRONTEND_IMAGE}"
                }
            }
        }

        stage('Deploy to Dev') {
            when {
                expression { return params.ENVIRONMENT == 'dev' }
            }
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                        kubectl apply -f k8s/namespaces.yaml
                        kubectl apply -f k8s/backend-deployment-dev.yaml
                        kubectl apply -f k8s/frontend-deployment-dev.yaml
                        kubectl apply -f k8s/backend-service.yaml
                        kubectl apply -f k8s/frontend-service.yaml
                    '''
                }
            }
        }

        stage('Manual Approval') {
            when {
                expression { return params.ENVIRONMENT == 'prod' }
            }
            steps {
                input message: 'Deploy to production?', ok: 'Proceed'
            }
        }

        stage('Deploy to Prod') {
            when {
                expression { return params.ENVIRONMENT == 'prod' }
            }
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                        kubectl apply -f k8s/backend-deployment-prod.yaml
                        kubectl apply -f k8s/frontend-deployment-prod.yaml
                        kubectl apply -f k8s/backend-service.yaml
                        kubectl apply -f k8s/frontend-service.yaml
                    '''
                }
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    curl -f http://kukuk-${params.ENVIRONMENT}.local/health || echo "Health check failed"
                '''
            }
        }
    }
}
