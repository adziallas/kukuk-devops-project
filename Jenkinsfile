pipeline {
  agent any

  parameters {
    choice(
      name: 'ENVIRONMENT',
      choices: ['dev', 'prod'],
      description: 'Zielumgebung für Build und Deployment'
    )
    booleanParam(
      name: 'SKIP_TESTS',
      defaultValue: false,
      description: 'Tests überspringen (true = nur Build & Deploy)'
    )
    credentials(
      name: 'DOCKER_HUB_TOKEN',
      description: 'Docker Hub Zugangsdaten',
      credentialType: 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl'
    )
  }

  environment {
    DOCKER_USERNAME = 'andziallas'
    DOCKER_IMAGE_BACKEND = "${DOCKER_USERNAME}/kukuk-backend"
    DOCKER_IMAGE_FRONTEND = "${DOCKER_USERNAME}/kukuk-frontend"
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
          sh 'mvn clean compile'
        }
      }
    }

    stage('Build Frontend') {
      steps {
        dir('frontend') {
          sh 'npm install'
          sh 'npm run build'
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
          sh 'npm test || true' // optional: Fehler ignorieren
        }
      }
    }

    stage('Docker Build & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_TOKEN', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
          sh 'docker build -t $DOCKER_IMAGE_BACKEND:latest ./backend'
          sh 'docker build