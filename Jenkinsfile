pipeline {
    agent { label 'master' }

    environment {
        DOCKER_IMAGE = "sathish1102/insuranceapp"
        DOCKER_TAG = "${env.BUILD_NUMBER ?: 'latest'}"
        ANSIBLE_INVENTORY = 'ansible/inventory.yml'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Sathish-11/star-agile-insurance-project.git'
            }
        }

        stage('Build Application') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh """
                        echo \$PASS | docker login -u \$USER --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }
        stage('Setup Docker on dev nodes') {
            steps {
                sshagent(['ssh_key']) {
                    sh 'ansible-playbook -i ${ANSIBLE_INVENTORY} ansible/playbooks/setup_docker.yml --limit dev'
                }
            }
        }
        stage('Deploy Application on Dev Environment') {
            steps {
                sshagent(['ssh_key']) {
                    sh 'ansible-playbook -i ${ANSIBLE_INVENTORY} ansible/playbooks/deploy_app.yml --limit dev -e "docker_image=${DOCKER_IMAGE} docker_tag=${DOCKER_TAG}"'
                }
            }
        }
        stage('Setup Docker on stage nodes') {
            steps {
                sshagent(['ssh_key']) {
                    sh 'ansible-playbook -i ${ANSIBLE_INVENTORY} ansible/playbooks/setup_docker.yml --limit stage'
                }
            }
        }
        stage('Deploy Application on Stage Environment') {
            steps {
                sshagent(['ssh_key']) {
                    sh 'ansible-playbook -i ${ANSIBLE_INVENTORY} ansible/playbooks/deploy_app.yml --limit stage -e "docker_image=${DOCKER_IMAGE} docker_tag=${DOCKER_TAG}"'
                }
            }
        }

        stage('Setup Production Environment') {
            steps {
                sshagent(['ssh_key']) {
                    sh 'ansible-playbook -i ${ANSIBLE_INVENTORY} ansible/playbooks/setup_docker.yml --limit prod'
                }
            }
        }
        stage('Deploy Application on Production Environment') {
            steps {
                sshagent(['ssh_key']) {
                    sh 'ansible-playbook -i ${ANSIBLE_INVENTORY} ansible/playbooks/deploy_app.yml --limit prod -e "docker_image=${DOCKER_IMAGE} docker_tag=${DOCKER_TAG}"'
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Build ${env.BUILD_NUMBER} completed with status: ${currentBuild.currentResult}"
            }
        }
    }
}
