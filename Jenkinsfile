pipeline {
  agent any

  // Parameter für manuelle Steuerung beim Start des Builds
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
      description: 'Docker Hub Zugangsdaten (PAT)',
      credentialType: 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl'
    )
  }

  // Globale Umgebungsvariablen für Bildnamen
  environment {
    DOCKER_USERNAME = 'andziallas'
    DOCKER_IMAGE_BACKEND = "${DOCKER_USERNAME}/kukuk-backend"
    DOCKER_IMAGE_FRONTEND = "${DOCKER_USERNAME}/kukuk-frontend"
  }

  stages {

    // Git-Checkout des Projekts
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    // Backend kompilieren (Spring Boot)
    stage('Build Backend') {
      steps {
        dir('backend') {
          sh 'mvn clean compile'
        }
      }
    }

    // Frontend bauen (React oder ähnliches)
    stage('Build Frontend') {
      steps {
        dir('frontend') {
          sh 'npm install'
          sh 'npm run build'
        }
      }
    }

    // Backend-Tests ausführen (optional)
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

    // Frontend-Tests ausführen (optional, Fehler werden ignoriert)
    stage('Test Frontend') {
      when {
        expression { return !params.SKIP_TESTS }
      }
      steps {
        dir('frontend') {
          sh 'npm test || true'
        }
      }
    }

    // Docker-Login, Build und Push zu Docker Hub
    stage('Docker Build and Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_TOKEN', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
          sh 'docker build -t $DOCKER_IMAGE_BACKEND:latest ./backend'
          sh 'docker build -t $DOCKER_IMAGE_FRONTEND:latest ./frontend'
          sh 'docker push $DOCKER_IMAGE_BACKEND:latest'
          sh 'docker push $DOCKER_IMAGE_FRONTEND:latest'
        }
      }
    }

    // Docker Compose Umgebung starten (Datei liegt im Hauptverzeichnis)
    stage('Docker Compose Up') {
      steps {
        sh '''
