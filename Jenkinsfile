// Jenkinsfile (declarative) - Mini Project 2
pipeline {
  agent any

  environment {
    REGISTRY = "docker.io/cgohee/shift-scheduler"   

    IMAGE_NAME = "${REGISTRY}/shift-scheduler"

    KUBE_CONFIG_CREDENTIALS_ID = 'kubeconfig-creds'    
    REGISTRY_CREDENTIALS_ID    = 'registry-creds'     
  }

  options {
    ansiColor('xterm')
    skipDefaultCheckout(false)
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        script {
          // Short git commit hash for tagging images
          GIT_COMMIT_SHORT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        }
      }
    }

    stage('Build & Push Image') {
      steps {
        script {
          // Build image tag = Jenkins build number + git short hash
          def tag = "${env.BUILD_NUMBER}-${GIT_COMMIT_SHORT}"
          env.IMAGE_TAG = tag

          docker.withRegistry("https://${REGISTRY}", REGISTRY_CREDENTIALS_ID) {
            def img = docker.build("${IMAGE_NAME}:${tag}", "--pull .")
            img.push()
            // Optional: also push a build tag
            img.push("build-${env.BUILD_NUMBER}")
          }
        }
      }
    }

    stage('Prepare Kubernetes Manifests') {
      steps {
        sh '''
          mkdir -p .ci-manifests
          IMAGE_FULL="${IMAGE_NAME}:${IMAGE_TAG}"

          # Replace placeholder IMAGE_PLACEHOLDER in deployments
          sed "s|IMAGE_PLACEHOLDER|${IMAGE_FULL}|g" k8s/deployment-stable.yaml > .ci-manifests/deployment-stable.yaml
          sed "s|IMAGE_PLACEHOLDER|${IMAGE_FULL}|g" k8s/deployment-canary.yaml > .ci-manifests/deployment-canary.yaml

          cp k8s/namespace.yaml .ci-manifests/
          cp k8s/pvc.yaml .ci-manifests/
          cp k8s/service.yaml .ci-manifests/
        '''
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        withCredentials([file(credentialsId: KUBE_CONFIG_CREDENTIALS_ID, variable: 'KUBECONFIG_FILE')]) {
          sh '''
            export KUBECONFIG="${KUBECONFIG_FILE}"

            kubectl apply -f .ci-manifests/namespace.yaml
            kubectl apply -f .ci-manifests/pvc.yaml -n shift-scheduler-ns
            kubectl apply -f .ci-manifests/service.yaml -n shift-scheduler-ns
            kubectl apply -f .ci-manifests/deployment-stable.yaml -n shift-scheduler-ns
            kubectl apply -f .ci-manifests/deployment-canary.yaml -n shift-scheduler-ns
          '''
        }
      }
    }

    stage('Post-deploy Checks') {
      steps {
        withCredentials([file(credentialsId: KUBE_CONFIG_CREDENTIALS_ID, variable: 'KUBECONFIG_FILE')]) {
          sh '''
            export KUBECONFIG="${KUBECONFIG_FILE}"
            echo "=== Deployments ==="
            kubectl -n shift-scheduler-ns get deploy
            echo "=== Pods ==="
            kubectl -n shift-scheduler-ns get pods -o wide
            echo "=== Services ==="
            kubectl -n shift-scheduler-ns get svc
            echo "=== PVC ==="
            kubectl -n shift-scheduler-ns get pvc
          '''
        }
      }
    }
  }

  post {
    success {
      echo "✅ Pipeline finished successfully. Image: ${IMAGE_NAME}:${IMAGE_TAG}"
    }
    failure {
      echo "❌ Pipeline failed."
    }
  }
}
