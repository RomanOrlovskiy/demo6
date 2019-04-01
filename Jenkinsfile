pipeline {

  environment {
    registry = "quitequiet/broadleaf-site-hsqldb-app"
    registryCredential = "dockerhub-account"
    dockerImage = ""
  }

  //Using dynamic nodes from EC2 plugin
  agent {
      label "centos"
  }

  tools {
        maven 'Maven 3.6.0'
  }

  stages {

    //Retrieve updated code in the application, build it and deploy the image to my dockerhub account
    stage('Cloning Git repo with broadleaf application') {
      steps {
        git branch: 'test', url: 'https://github.com/RomanOrlovskiy/DemoSite.git'
      }
    }

    stage ('Initialize') {
        steps {
            sh '''
                echo "PATH = ${PATH}"
                echo "M2_HOME = ${M2_HOME}"
            '''
        }
    }

    stage ('Build artifact') {
        steps {
            ansiColor('xterm') {
                sh 'mvn -Dmaven.test.failure.ignore=true clean package'
            }
        }
    }

    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build registry + ":$BUILD_NUMBER"
        }
      }
    }

    stage('Deploy Image') {
      steps{
         script {
            docker.withRegistry( '', registryCredential ) {
            dockerImage.push()
          }
        }
      }
    }

    stage('Remove Unused docker image') {
      steps{
        sh "docker rmi $registry:$BUILD_NUMBER"
      }
    }

    //Infrastructure creation and provision
    stage("Checkout git repo") {
         steps {
         git branch: "master", url: "https://github.com/RomanOrlovskiy/demo6.git"
        }
    }

    stage("Set Terraform path") {
         steps {
            script {
                def tfHome = tool name: "Terraform"
                env.PATH = "${tfHome}:${env.PATH}"
            }
            sh "terraform --version"
        }
    }

    stage("Create infrastructure with Terraform") {
        steps {
                sh "terraform init"
                sh "terraform destroy -auto-approve"
                sh "terraform apply -auto-approve"
        }
    }

    stage("Provision the infrastructure with Ansible"){
        steps {
            ansiColor('xterm') {
             sshagent(['a887d653-859f-499d-9c8e-7d5bf47565c7']) {
                ansiblePlaybook(
                    playbook: 'playbook.yml',
                    inventory: 'ec2.py',
                    extras: '--flush-cache',
                    colorized: true)
                }
            }
        }
    }

    //Creating the docker swarm and deploying my stack
    stage("Deploy swarm stack") {
        steps {
            sshagent(['a887d653-859f-499d-9c8e-7d5bf47565c7']) {
                    sh "./docker-deploy-stack.sh"
            }
        }
    }
  }
}
