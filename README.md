# 🌦️ Kubernetes Weather Application

A containerized weather application deployed and managed using **Kubernetes and Helm**.

The application provides a simple user experience where users can create an account, log in, and search for weather information by city.

---

## 📌 Project Overview

This project demonstrates the deployment of a multi-component weather application on Kubernetes, with authentication, weather services, database persistence, and Kubernetes-based service management.

### Application Flow

```text
User
 │
 ▼
┌──────────────────────┐
│    Weather Web UI    │
└──────────┬───────────┘
           │
           ▼
     ┌─────────────┐
     │     Auth    │
     │ Sign Up/Login│
     └──────┬──────┘
            │
            ▼
     ┌─────────────┐
     │   Weather   │
     │    Service  │
     └──────┬──────┘
            │
            ▼
      External Weather
           API

        MySQL
          ▲
          │
       Backend
```

### Typical User Journey

1. Open the weather application.
2. Create an account using **Sign Up**.
3. Log in using the registered username and password.
4. Enter a city name, for example `Cairo`.
5. The application retrieves and displays the weather information for the requested city.

---

## 🏗️ Architecture

The application is organized into multiple components:

| Component | Responsibility |
|---|---|
| **UI** | Web interface used by the end user |
| **Auth Service** | User registration and authentication |
| **Weather Service** | Retrieves weather information based on the requested city |
| **MySQL** | Stores application/user-related data |
| **Kubernetes** | Container orchestration and service management |
| **Helm** | Application packaging and Kubernetes deployment management |

---

## 🛠️ Technologies Used

### Application

- Frontend / Web UI
- Backend services
- Authentication
- MySQL
- External Weather API

### DevOps & Infrastructure

- **Docker**
- **Kubernetes**
- **Helm**
- **Linux**
- **Kubernetes Services**
- **ConfigMaps**
- **Secrets**
- **StatefulSet**
- **Persistent Storage**
- **Health Checks / Probes**
- **Ingress**

---

## ☸️ Kubernetes Implementation

The application is deployed using Kubernetes resources that provide:

- Container orchestration
- Service discovery
- Internal service communication
- Application configuration
- Secret management
- Database persistence
- Health monitoring
- Traffic routing

The Kubernetes configuration is available under:

```text
kubernetes/
```

---

## ⎈ Helm Deployment

The project also includes a Helm chart for packaging and managing the application deployment.

Helm provides a more maintainable and reusable way to deploy the Kubernetes resources compared with managing individual manifests manually.

Helm configuration is available under:

```text
weatherapp.helm/
```

### Why Helm?

Instead of applying multiple Kubernetes YAML files individually, the application can be managed as a single Helm release.

This makes it easier to:

- Install the application
- Upgrade deployments
- Manage configuration
- Reuse Kubernetes manifests
- Maintain different deployment values
- Roll back releases when required

---

## 🔐 Authentication

The application includes an authentication component that supports:

### Sign Up

Users can create a new account through the application.

### Login

Registered users can authenticate using their credentials before accessing the weather functionality.

The authentication service communicates with the backend/database components running inside the Kubernetes environment.

---

## 🌤️ Weather Service

After authentication, users can enter a city name such as:

```text
Cairo
```

The weather service processes the request and retrieves the corresponding weather information from the configured weather API.

Example workflow:

```text
User enters "Cairo"
        │
        ▼
Weather Service
        │
        ▼
External Weather API
        │
        ▼
Weather Data
        │
        ▼
Web UI
```

---

## 🗄️ MySQL & Persistent Data

The project uses **MySQL** as the database component.

The database is deployed as a Kubernetes workload and is designed to maintain data beyond the lifecycle of an individual container.

The project includes:

```text
mysql-init/
```

for database initialization-related configuration.

---

## 🔒 Configuration & Secrets

Sensitive configuration such as application credentials and API-related values should be supplied through Kubernetes configuration mechanisms rather than hard-coded directly into application manifests.

The project uses Kubernetes concepts such as:

- `ConfigMap`
- `Secret`

> ⚠️ Never commit real API keys, passwords, tokens, or other sensitive credentials to the Git repository.

---

## 🚀 Deployment

### Prerequisites

Make sure the following tools are installed:

```bash
docker --version
kubectl version --client
helm version
```

You also need access to a Kubernetes cluster.

Examples:

- Minikube
- Kind
- Docker Desktop Kubernetes
- Amazon EKS
- Other Kubernetes-compatible clusters

---

## 📦 Deploy Using Kubernetes

Clone the repository:

```bash
git clone https://github.com/Ebrahimabdelmonem1/k8s-course-lab.git
cd k8s-course-lab
```

Review the Kubernetes manifests:

```bash
ls kubernetes/
```

Apply the required resources:

```bash
kubectl apply -f kubernetes/
```

Check the deployed workloads:

```bash
kubectl get pods
kubectl get services
kubectl get deployments
```

For database-related workloads:

```bash
kubectl get statefulsets
```

---

## ⎈ Deploy Using Helm

Navigate to the Helm chart:

```bash
cd weatherapp.helm
```

Install the application:

```bash
helm install weatherapp .
```

Verify the Helm release:

```bash
helm list
```

Check the Kubernetes resources:

```bash
kubectl get pods
kubectl get services
```

---

## 🔄 Upgrade the Application

After modifying Helm configuration or Kubernetes templates:

```bash
helm upgrade weatherapp .
```

Verify the release:

```bash
helm status weatherapp
```

---

## 🧹 Remove the Deployment

To uninstall the Helm release:

```bash
helm uninstall weatherapp
```

---

## 🔍 Useful Kubernetes Commands

Check all pods:

```bash
kubectl get pods
```

Check services:

```bash
kubectl get svc
```

Check deployments:

```bash
kubectl get deployments
```

Check StatefulSets:

```bash
kubectl get statefulsets
```

Check ingress:

```bash
kubectl get ingress
```

Inspect a specific pod:

```bash
kubectl describe pod <pod-name>
```

View application logs:

```bash
kubectl logs <pod-name>
```

---

## 🧪 Health & Troubleshooting

When troubleshooting the application, start by checking the overall Kubernetes state:

```bash
kubectl get pods -o wide
```

Then inspect services:

```bash
kubectl get svc
```

Check logs:

```bash
kubectl logs <pod-name>
```

And inspect failing resources:

```bash
kubectl describe pod <pod-name>
```

This helps identify common issues such as:

- Container startup failures
- Image pull errors
- Service connectivity problems
- Incorrect configuration
- Missing secrets
- Database connectivity issues
- Failed health probes

---

## 📁 Repository Structure

```text
k8s-course-lab/
│
├── UI/
│   └── Frontend application
│
├── auth/
│   └── Authentication service
│
├── weather/
│   └── Weather service
│
├── weatherapp/
│   └── Application-related components
│
├── mysql-init/
│   └── MySQL initialization
│
├── kubernetes/
│   └── Kubernetes manifests
│
├── weatherapp.helm/
│   └── Helm chart
│
├── demo.sh
│   └── Demo/deployment helper script
│
└── .gitignore
```

---

## 🎯 Key DevOps Concepts Demonstrated

This project was built to practice real-world DevOps and Kubernetes concepts, including:

- Containerized application deployment
- Kubernetes workload management
- Kubernetes service discovery
- Microservice communication
- Stateful workloads
- Persistent data
- Configuration management
- Secret management
- Application health checks
- Ingress-based routing
- Helm-based application packaging
- Kubernetes troubleshooting
- Linux-based administration

---

## 📸 Application Demo

### Application Workflow

```text
┌─────────────┐
│    Sign Up  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│    Login    │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ Enter City Name │
│     "Cairo"     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Weather Service │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Today's Weather │
└─────────────────┘
```

---

## 💡 What I Learned

Through this project, I strengthened my practical experience with:

- Deploying applications on Kubernetes
- Managing multi-component applications
- Working with StatefulSets and persistent data
- Connecting services inside a Kubernetes cluster
- Managing application configuration and secrets
- Troubleshooting Kubernetes workloads
- Packaging Kubernetes applications using Helm
- Understanding the difference between raw Kubernetes manifests and Helm-based deployments

---

## 👨‍💻 Author

**Ebrahim Abdelmonem**

DevOps Engineer | Cloud & Infrastructure

GitHub:  
https://github.com/Ebrahimabdelmonem1

---

## ⭐ Project

If you find this project useful or interesting, feel free to explore the repository and the implementation.

**Built as a hands-on DevOps & Kubernetes project.**
