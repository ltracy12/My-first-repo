pipeline {

    agent any

    environment {
        docker_id = credentials('docker_id')
        docker_pw = credentials('docker_pw')
        APP_NAME = "myapp1"
    }
    
    stages {

        stage('Check system version') {
            steps {
                sh '''
                    uname -a
                    id
                    pwd
                    ls -la
                '''
            }
        }//end stage

        stage ('Build Docker image') {
            steps{
                sh '''
                    alias docker="docker -H 192.168.19.1:2375"
                    docker login -u $docker_id -p $docker_pw
                    docker build -t lelemao2010/myapp1 .
                    docker images
                    docker push lelemao2010/myapp1 .
                '''
            }
        }//end stage

        stage ('Deploy to Kubernetes') {
            steps{
                sh '''
                    alias kubectl='/usr/local/bin/kubectl  --kubeconfig="/opt/kind-config/config"'
                    kubectl apply -f Deployment.yaml
                    sleep 20
                    kubectl get pod
                    
                '''
            }
        }//end stage
    }
}
