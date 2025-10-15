# 🚀 Kukuk Technology Future GmbH - DevOps Abschlussprojekt

Dieses Projekt implementiert eine vollständige CI/CD-Pipeline für eine Microservice-Anwendung mit Spring Boot Backend und JavaScript Frontend, automatisiertem Deployment über Jenkins und Kubernetes.

## 📋 Projektübersicht

Das Projekt besteht aus:
- **Backend**: Spring Boot Anwendung (Java 17, Maven)
- **Frontend**: JavaScript/HTML Anwendung mit nginx
- **CI/CD**: Jenkins Pipeline mit automatisiertem Build, Test und Deployment
- **Container**: Docker Images für beide Services
- **Orchestrierung**: Kubernetes Deployments für dev und prod Umgebungen

## 🏗️ Projektstruktur

```
kukuk-devops-project/
├── backend/                    # Spring Boot Backend
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/kukuk/
│   │   │   │   ├── KukukBackendApplication.java
│   │   │   │   └── controller/
│   │   │   │       └── WelcomeController.java
│   │   │   └── resources/
│   │   │       ├── application.properties
│   │   │       ├── application-dev.properties
│   │   │       └── application-prod.properties
│   │   └── test/
│   ├── Dockerfile
│   └── pom.xml
├── frontend/                   # JavaScript Frontend
│   ├── index.html
│   ├── nginx.conf
│   ├── Dockerfile
│   └── package.json
├── k8s/                        # Kubernetes Manifests
│   ├── namespaces.yaml
│   ├── backend-deployment-dev.yaml
│   ├── backend-deployment-prod.yaml
│   ├── frontend-deployment-dev.yaml
│   ├── frontend-deployment-prod.yaml
│   ├── backend-service.yaml
│   ├── frontend-service.yaml
│   └── ingress.yaml
├── jenkins/                    # CI/CD Pipeline
│   └── Jenkinsfile
└── docs/                       # Dokumentation
    └── README.md
```

## 🔧 Technische Konfiguration

### Spring Boot Backend

**Ports:**
- Development: `8081`
- Production: `8080`

**Endpoints:**
- `GET /` - Willkommen dein kukuk-backend läuft
- `GET /health` - Health Check
- `GET /api/welcome` - API Welcome Endpoint

**Maven Profile Konfiguration:**
```xml
<profiles>
  <profile>
    <id>dev</id>
    <properties>
      <spring.profiles.active>dev</spring.profiles.active>
    </properties>
  </profile>
  <profile>
    <id>prod</id>
    <properties>
      <spring.profiles.active>prod</spring.profiles.active>
    </properties>
  </profile>
</profiles>
```

**Application Properties Unterschiede:**

| Eigenschaft | Development | Production |
|-------------|-------------|------------|
| `server.port` | 8081 | 8080 |
| `logging.level.root` | DEBUG | ERROR |
| `spring.jpa.hibernate.ddl-auto` | create-drop | validate |
| `spring.h2.console.enabled` | true | false |

### Frontend

**Port:** `8081`
**Technologie:** HTML5, CSS3, JavaScript, nginx
**Endpoints:**
- `GET /` - Hauptseite mit Willkommensnachricht
- `GET /health` - Health Check

## 🚀 CI/CD Pipeline

### Jenkins Pipeline Stages

1. **Checkout** - Git Repository auschecken
2. **Build Backend** - Maven Build mit aktivem Profil
3. **Build Frontend** - npm install und build
4. **Test Backend** - JUnit Tests ausführen
5. **Test Frontend** - Jest Tests ausführen
6. **Docker Build** - Parallele Image-Erstellung
7. **Docker Push** - Push zu Docker Hub
8. **Deploy to Dev** - Automatisches Dev-Deployment
9. **Manual Approval** - Manuelle Freigabe für Production
10. **Deploy to Prod** - Production Deployment
11. **Health Check** - Überprüfung der Deployments

### Pipeline Parameter

- `ENVIRONMENT`: dev oder prod
- `SKIP_TESTS`: Tests überspringen (boolean)

### Docker Images

- **Backend**: `andziallas/kukuk-backend:latest`
- **Frontend**: `andziallas/kukuk-frontend:latest`

## ☸️ Kubernetes Deployment

### Namespaces

- `dev` - Development Environment
- `prod` - Production Environment

### Services

- **Backend Service**: Port 8080, ClusterIP
- **Frontend Service**: Port 8081, ClusterIP

### Deployments

**Development:**
- Backend: 2 Replicas, 256Mi-512Mi Memory
- Frontend: 2 Replicas, 128Mi-256Mi Memory

**Production:**
- Backend: 3 Replicas, 512Mi-1Gi Memory
- Frontend: 3 Replicas, 256Mi-512Mi Memory

### Ingress

- **Dev**: `kukuk-dev.local`
- **Prod**: `kukuk-prod.local`

## 🛠️ Deployment-Schritte

### 1. Lokale Entwicklung

```bash
# Backend starten
cd backend
mvn spring-boot:run -Pdev

# Frontend starten
cd frontend
npm install
npm start
```

### 2. Docker Build (lokal)

```bash
# Backend Image
cd backend
docker build -t andziallas/kukuk-backend:latest .

# Frontend Image
cd frontend
docker build -t andziallas/kukuk-frontend:latest .
```

### 3. Kubernetes Deployment

```bash
# Namespaces erstellen
kubectl apply -f k8s/namespaces.yaml

# Development Deployment
kubectl apply -f k8s/backend-deployment-dev.yaml
kubectl apply -f k8s/frontend-deployment-dev.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-service.yaml

# Production Deployment
kubectl apply -f k8s/backend-deployment-prod.yaml
kubectl apply -f k8s/frontend-deployment-prod.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-service.yaml
```

### 4. Jenkins Pipeline

1. Repository in Jenkins konfigurieren
2. Credentials hinzufügen:
   - `docker-hub-credentials` (andziallas/[DOCKER_HUB_TOKEN])
   - `github-token` ([GITHUB_TOKEN])
   - `kubeconfig` (Kubernetes Cluster Config)
3. Pipeline mit Jenkinsfile erstellen
4. Build mit gewünschten Parametern starten

## 🔐 Credentials

### Docker Hub
- **Username**: `andziallas`
- **Token**: `[DOCKER_HUB_TOKEN]` (in Jenkins Credentials hinterlegt)

### GitHub
- **Username**: `adziallas`
- **Token**: `[GITHUB_TOKEN]` (in Jenkins Credentials hinterlegt)

## 📊 Monitoring & Health Checks

### Backend Health Endpoints
- `/health` - Basic health check
- `/actuator/health` - Spring Boot Actuator (dev only)

### Frontend Health Endpoints
- `/health` - nginx health check

### Kubernetes Health Checks
- **Liveness Probe**: Überprüft ob Container läuft
- **Readiness Probe**: Überprüft ob Container bereit ist

## 🎯 Projektziele erreicht

✅ **Projektstruktur**: Saubere Trennung in /backend, /frontend, /k8s, /jenkins, /docs  
✅ **Spring Boot Konfiguration**: application.properties für dev/prod mit Maven-Profilen  
✅ **CI/CD Pipeline**: Vollständiges Jenkinsfile mit allen erforderlichen Stages  
✅ **Kubernetes**: Deployments, Services, Namespaces für dev und prod  
✅ **Docker**: Multi-stage Builds für Backend und Frontend  
✅ **Dokumentation**: Umfassende README mit allen Konfigurationsdetails  

## 🚀 Nächste Schritte

1. **Git Repository erstellen** und Code hochladen
2. **Jenkins konfigurieren** mit den bereitgestellten Credentials
3. **Kubernetes Cluster** mit kubeconfig verbinden
4. **Pipeline testen** mit dev Environment
5. **Production Deployment** nach erfolgreichem Test

---

**Entwickelt für Kukuk Technology Future GmbH**  
**DevOps Engineering Abschlussprojekt**  
**Datum**: Oktober 2025
