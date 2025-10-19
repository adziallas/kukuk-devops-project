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

    // Frontend bauen (React oder ähnliches