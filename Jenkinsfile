#!groovy

// The name consists of the job's name and the build number.
// It is used to name the docker container and should be unique.
def name = "${env.JOB_NAME}-${BUILD_NUMBER}".replaceAll("/","-")

pipeline {
  agent {
    // The label of the jenkins slave node
    label 'aws-build-node'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Building lingohub CLI') {
      steps {
        sh "docker run --name ${name} -v ${env.WORKSPACE}:/app swift swift build -c release -Xswiftc -static-stdlib"
      }
    }
  }

  post {
    always {
      // Stops and deletes container
      sh "docker stop ${name} && docker rm ${name}"
    }
    success {
      notifyBuild()
    }
    failure {
      notifyBuild('ERROR')
    }
  }
}

def notifyBuild(String buildStatus = 'SUCCESSFUL') {
  buildStatus = buildStatus

  def colorName = 'RED'
  def colorCode = '#FF0000'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def changeSet = getChangeSet()
  def message = "${subject} \n ${changeSet}"

  if (buildStatus == 'SUCCESSFUL') {
    color = 'GREEN'
    colorCode = '#00FF00'
  } else {
    color = 'RED'
    colorCode = '#FF0000'
  }

  slackSend (color: colorCode, message: message)
}

@NonCPS
def getChangeSet() {
  return currentBuild.changeSets.collect { cs ->
    cs.collect { entry ->
        "* ${entry.author.fullName}: ${entry.msg}"
    }.join("\n")
  }.join("\n")
}