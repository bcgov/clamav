pipeline {
  agent any
  stages {
    stage('build clamav-build') {
      steps {
        echo "Building: clamav-build"
        openshiftBuild bldCfg: 'clamav-build', showBuildLogs: 'true'
        openshiftTag destStream: 'clamav', verbose: 'true', destTag: '$BUILD_ID', srcStream: 'clamav', srcTag: 'latest'
      }
    }
    stage('deploy to DEV') {
      steps {
        openshiftTag destStream: 'clamav', verbose: 'true', destTag: 'dev', srcStream: 'clamav', srcTag: '$BUILD_ID'
        notifyBuild('DEPLOYED:DEV')
      }
    }
    stage('deploy to TEST') {
      steps {
        script {
          try {
            timeout(time: 2, unit: 'MINUTES') {
              input "Deploy to TEST?"
              openshiftTag destStream: 'clamav', verbose: 'true', destTag: 'test', srcStream: 'clamav', srcTag: '$BUILD_ID'
              notifyBuild('DEPLOYED:TEST')
            }
          } catch (e) {
            notifyBuild('DEPLOYMENT:TEST ABORTED')
          }
        }
      }
    }
    stage('deploy to PROD') {
      steps {
        script {
          try {
            timeout(time: 2, unit: 'MINUTES') {
              input "Deploy to PROD?"
              openshiftTag destStream: 'clamav', verbose: 'true', destTag: 'prod', srcStream: 'clamav', srcTag: '$BUILD_ID'
              notifyBuild('DEPLOYED:PROD')
            }
          } catch (e) {
            notifyBuild('DEPLOYMENT:PROD ABORTED')
          }
        }
      }
    }
  }
}

def notifyBuild(String buildStatus = 'STARTED') {
  // build status of null means successful
  buildStatus =  buildStatus ?: 'SUCCESSFUL'

  // Default values
  def colorName = 'RED'
  def colorCode = '#FF0000'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL})"
  def details = """<p>STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
    <p>Check console output at "<a href="${env.BUILD_URL}">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>"</p>"""

  // Override default values based on build status
  if (buildStatus == 'STARTED' || buildStatus.startsWith("DEPLOYMENT")) {
    color = 'YELLOW'
    colorCode = '#FFFF00'
  } else if (buildStatus == 'SUCCESSFUL' || buildStatus.startsWith("DEPLOYED")) {
    color = 'GREEN'
    colorCode = '#00FF00'
  } else {
    color = 'RED'
    colorCode = '#FF0000'
  }

  // Send notifications
  //slackSend (color: colorCode, message: summary)
}
