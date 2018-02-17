#!groovy

pipeline {
  agent {
    label 'mac-mini'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Building lingohub CLI') {
      steps {
        sh "swift build -c release -Xswiftc -static-stdlib"
      }
    }

    stage('Installing lingohub CLI') {
      when {
        expression {
          env.BRANCH_NAME == 'master'
        }
      }
      steps {
        sh "cp -f .build/x86_64-apple-macosx10.10/release/LingoHubCLI /usr/local/bin/lingohub"
        sh "lingohub -v"
      }
    }
    
  }

  post {
    always {
      sh 'rm -rf .build/'
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