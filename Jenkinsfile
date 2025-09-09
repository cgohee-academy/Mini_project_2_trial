// Jenkinsfile - Mini Project 2 (Sandbox version)
pipeline {
  agent any

  environment {
    REGISTRY = "docker-host:5000"
    IMAGE_NAME = "${REGISTRY}/shift-scheduler"
    KUBE_CONFIG_CREDENTIALS_ID = 'kubeconfig-creds'
    REGISTRY_CREDENTIALS_ID    = 'cgohee-academy'   // must exist in Jenkins credentials
  }

  options {
    skipDefaultCheckout(false)
  }

  stages {
    stage('Checkout') {
      steps {
        ansiColor('xterm') {
          timestamps {
            checkout scm
            script {
              // Short git commit hash for tagging images
              def commit = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
              env.GIT_COMMIT_SHORT = commit
            }
          }
        }
      }
    }

    stage('Build & Push Image') {
      steps {
        ansiColor('xterm') {
          timestamps {
            script {
              def tag = "${env.BUILD_NUMBER}-${env.GIT_COMMIT_SHORT}"
              env.IMAGE_TAG = tag

              docker.withRegistry("http://${REGISTRY}", REGISTRY_CREDENTIALS_ID) {
                def img = docker.build("${IMAGE_NAME}:${tag}", "--pull .")
                img.push()
                img.push("build-${env.BUILD_NUMBER}")
              }
            }
          }
        }
      }
    }

    stage('Prepare Kubernetes Manifests') {
      steps {
        ansiColor('xterm') {
          timestamps {
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
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        ansiColor('xterm') {
          timestamps {
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
      }
    }

    stage('Post-deploy Checks') {
      steps {
        ansiColor('xterm') {
          timestamps {
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
