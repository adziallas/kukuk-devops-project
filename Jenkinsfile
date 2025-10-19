pipeline {
  agent any

  environment {
    DOCKER_REGISTRY = 'docker.io'
    DOCKER_USERNAME = 'andziallas'
    DOCKER_IMAGE_BACKEND = "${DOCKER_USERNAME}/kukuk-backend"
    DOCKER_IMAGE_FRONTEND = "${DOCKER_USERNAME}/kukuk-frontend"
    GITHUB_TOKEN = credentials('git-push-token')
  }

  parameters {
    choice(name: 'ENVIRONMENT', choices: ['dev', 'prod'], description: 'Target environment')
    booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip tests')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        script {
          env.GIT_COMMIT_SHORT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
          env.BUILD_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT_SHORT}"
        }
      }
    }

    stage('Build Backend') {
      steps {
        dir('backend') {
          sh "mvn clean compile -P${params.ENVIRONMENT} -DskipTests=${params.SKIP_TESTS}"
        }
      }
    }

    stage('Build Frontend') {
      steps {
        dir('frontend') {
          sh "npm install"
          sh "npm run build"
        }
      }
    }

    stage('Test Backend') {
      when { not { params.SKIP_TESTS } }
      steps {
        dir('backend') {
          sh "mvn test -P${params.ENVIRONMENT}"
        }
      }
      post {
        always {
          publishTestResults testResultsPattern: 'backend/target/surefire-reports/*.xml'
        }
      }
    }

    stage('Test Frontend') {
      when { not { params.SKIP_TESTS } }
      steps {
        dir('frontend') {
          sh "npm test -- --coverage --watchAll=false"
        }
      }
      post {
        always {
          publishTestResults testResultsPattern: 'frontend/coverage/lcov.info'
        }
      }
    }

    stage('Docker Build') {
      parallel {
        stage('Build Backend Image') {
          steps {
            dir('backend') {
              script {
                def backendImage = "${DOCKER_IMAGE_BACKEND}:${BUILD_TAG}"
                sh """
                  docker build -t ${backendImage} .
                  docker tag ${backendImage} ${DOCKER_IMAGE_BACKEND}:latest
                """
                env.BACKEND_IMAGE = backendImage
              }
            }
          }
        }
        stage('Build Frontend Image') {
          steps {
            dir('frontend') {
              script {
                def frontendImage = "${DOCKER_IMAGE_FRONTEND}:${BUILD_TAG}"
                sh """
                  docker build -t ${frontendImage} .
                  docker tag ${frontendImage} ${DOCKER_IMAGE_FRONTEND}:latest
                """
                env.FRONTEND_IMAGE = frontendImage
              }
            }
          }
        }
      }
    }

    stage('Docker Push') {
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'docker-hub-token', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh """
              echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin
              docker push ${BACKEND_IMAGE}
              docker push ${DOCKER_IMAGE_BACKEND}:latest
              docker push ${FRONTEND_IMAGE}
              docker push ${DOCKER_IMAGE_FRONTEND}:latest
            """
          }
        }
      }
    }

    stage('Docker Up') {
      steps {
        sh "docker-compose -f docker/docker-compose.yml up -d"
      }
    }

    stage('Health Check') {
      steps {
        script {
          sh """
            echo 'Checking frontend...'
            curl -sSf http://localhost:3000 || echo 'Frontend nicht erreichbar'

            echo 'Checking backend...'
            curl -sSf http://localhost:8080/api/health || echo 'Backend nicht erreichbar'
          """
        }
      }
    }
  }

  post {
    always {
      sh """
        docker rmi ${BACKEND_IMAGE} || true
        docker rmi ${FRONTEND_IMAGE} || true
      """
    }
    success {
      echo 'Pipeline erfolgreich abgeschlossen'
    }
    failure {
      echo 'Pipeline fehlgeschlagen'
    }
    cleanup {
      cleanWs()
    }
  }
}
