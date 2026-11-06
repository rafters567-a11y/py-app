pipeline {
    agent any
    environment {
        IMAGE = "py-app"
        TAG   = "${env.BUILD_NUMBER}"
    }
    options {
        timeout(time: 15, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    triggers { pollSCM('H/2 * * * *') }

    stages {
        stage('Clone') {
            steps { checkout scm }
        }
        stage('Validate') {
            steps {
                sh 'docker run --rm -v "$PWD":/src -w /src python:3.11-slim python -m py_compile app.py'
            }
        }
        stage('Build image') {
            steps {
                sh 'docker build -t ${IMAGE}:${TAG} -t ${IMAGE}:latest .'
                sh 'docker images ${IMAGE}'
            }
        }
        stage('Smoke test') {
            steps {
                sh '''
                    docker rm -f smoke 2>/dev/null || true
                    docker run -d --name smoke -p 8001:8000 ${IMAGE}:${TAG}
                    sleep 4
                    curl -f http://localhost:8001/
                '''
            }
            post { always { sh 'docker rm -f smoke || true' } }
        }
    }

    post {
        failure {
            mail to: 'rafters567@gmail.com',
                 subject: "FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: "The build failed.\n\nConsole output: ${env.BUILD_URL}console"
        }
        always { sh 'docker image prune -f' }
    }
}
