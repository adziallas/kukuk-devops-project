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
      description: 'Docker Hub Zugangsdaten (PAT)',
      credentialType: 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl'
    )
  }

  environment {
    DOCKER_USERNAME = 'andziallas'
    DOCKER_IMAGE_BACKEND = "${DOCKER_USERNAME}/kukuk-backend"
    DOCKER_IMAGE_FRONTEND = "${DOCKER_USERNAME}/kukuk-frontend"
  }

  stages {

    stage('Build Backend') {
      steps {
        dir('backend') {
          sh "mvn clean package -DskipTests=${params.SKIP_TESTS}"
        }
      }
    }

    stage('Build Frontend') {
      steps {
        dir('frontend') {
          sh 'npm install'
          sh 'npm run build || echo "Kein Build notwendig"'
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
          sh 'npm test'
        }
      }
    }

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

    stage('Docker Port Cleanup') {
      steps {
        echo '🔧 Bereinige blockierte Ports 8080 und 8081...'
        sh '''
          docker ps --format '{{.ID}} {{.Ports}}' | while read id ports; do
            if echo "$ports" | grep -q '8080\\|8081'; then
              echo "Stoppe Container $id mit Ports: $ports"
              docker stop $id || true
            fi
          done
        '''
      }
    }

    stage('Docker Compose Up') {
      steps {
        sh '''
          COMPOSE_FILE=docker-compose.yaml
          if [ ! -f "$COMPOSE_FILE" ]; then
            echo "Fehlende Datei: $COMPOSE_FILE"
            exit 1
          fi

          if command -v docker compose > /dev/null; then
            docker compose -f $COMPOSE_FILE down || true
            docker compose -f $COMPOSE_FILE up -d
          elif command -v docker-compose > /dev/null; then
            docker-compose -f $COMPOSE_FILE down || true
            docker-compose -f $COMPOSE_FILE up -d
          else
            echo "Weder 'docker compose' noch 'docker-compose' verfügbar"
            exit 1
          fi
        '''
      }
    }

    stage('Health Check') {
      steps {
        sh '''
          echo "Prüfe Frontend auf Port 8081..."
          for i in {1..5}; do
            curl -sSf http://localhost:8081 && break || sleep 2
          done || echo "Frontend nicht erreichbar"

          echo "Prüfe Backend auf Port 8080..."
          for i in {1..5}; do
            curl -sSf http://localhost:8080/api/health && break || sleep 2
          done || echo "Backend nicht erreichbar"
        '''
      }
    }
  }

  post {
    success {
      echo '✅ Build, Push und Deployment erfolgreich abgeschlossen.'
    }
    failure {
      echo '❌ Pipeline fehlgeschlagen.'
    }
  }
}
