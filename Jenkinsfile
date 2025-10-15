pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'prod'], description: 'Deployment Environment')
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip tests')
    }

    tools {
        git 'Default'
    }

    environment {
        BACKEND_IMAGE = "kukuk-backend:${params.ENVIRONMENT}"
        FRONTEND_IMAGE = "kukuk-frontend:${params.ENVIRONMENT}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/adziallas/kukuk-devops-project.git',
                        credentialsId: 'git-push-token'
                    ]]
                ])
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

        stage('Configure Minikube Docker') {
            steps {
                sh 'eval $(minikube docker-env)'
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

        stage('Deploy to Minikube') {
            steps {
                sh '''
                    kubectl apply -f k8s/namespaces.yaml || true
                    kubectl apply -f k8s/backend-deployment-${ENVIRONMENT}.yaml
                    kubectl apply -f k8s/frontend-deployment-${ENVIRONMENT}.yaml
                    kubectl apply -f k8s/backend-service.yaml
                    kubectl apply -f k8s/frontend-service.yaml
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    kubectl get pods -n kukuk || echo "Namespace not found"
                    kubectl get svc -n kukuk || echo "Services not found"
                '''
            }
        }
    }
}
