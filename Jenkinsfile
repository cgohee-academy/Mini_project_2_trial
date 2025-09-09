pipeline {
  agent any

  environment {
    REGISTRY = "docker-host:5000"
    IMAGE_NAME = "${REGISTRY}/shift-scheduler"
    KUBE_CONFIG_CREDENTIALS_ID = 'kubeconfig-creds'
    REGISTRY_CREDENTIALS_ID    = 'dock-registry-creds'
  }

  options { skipDefaultCheckout(false) }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        script {
          env.GIT_COMMIT_SHORT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        }
      }
    }

    stage('Build & Push Image') {
      steps {
        script {
          def tag = "${env.BUILD_NUMBER}-${env.GIT_COMMIT_SHORT}"
          env.IMAGE_TAG = tag
          def imageFull = "${IMAGE_NAME}:${tag}"

          // build with build-arg to embed version into image
          docker.withRegistry("http://${REGISTRY}", REGISTRY_CREDENTIALS_ID) {
            def img = docker.build("${IMAGE_NAME}:${tag}", "--build-arg IMAGE_VERSION=${tag} .")
            img.push()
          }
        }
      }
    }

    stage('Prepare Kubernetes Manifests') {
      steps {
        sh '''
          mkdir -p .ci-manifests
          IMAGE_FULL="${IMAGE_NAME}:${IMAGE_TAG}"
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
            kubectl -n shift-scheduler-ns get svc -n shift-scheduler-ns || true
            echo "=== PVC ==="
            kubectl -n shift-scheduler-ns get pvc
          '''
        }
      }
    }
  }

  post {
    success { echo "✅ Pipeline finished: ${IMAGE_NAME}:${IMAGE_TAG}" }
    failure { echo "❌ Pipeline failed." }
  }
}
