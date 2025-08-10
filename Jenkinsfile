pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // This will check out the code from the repository configured in the Jenkins job
                checkout scm
            }
        }

        stage('Setup Environment') {
            steps {
                sh """
                    # Create and activate a virtual environment
                    python3 -m venv venv
                    source venv/bin/activate

                    # Install dependencies
                    pip install -r requirements.txt
                """
            }
        }

        stage('Run Robot Tests Sequentially') {
            steps {
                script {
                    def filePath = 'FinalistenTestCases/contact/open_contact_create.robot'
                    def fileName = filePath.split('/').last()
                    def suiteName = fileName.take(fileName.lastIndexOf('.'))

                    sh """
                        # Activate the virtual environment for each test run
                        source venv/bin/activate
                        echo "Running single test case: ${filePath}"
                        robot --variable CHROME_OPTIONS:"add_argument('--headless');add_argument('--no-sandbox');add_argument('--disable-gpu');add_argument('--window-size=1920,1080')" --name "${suiteName}" --outputdir "results/${suiteName}" --xunit "${fileName}-results.xml" "${filePath}"
                    """
                }
            }
        }
    }

    post {
        always {
            script {
                // Clean up previous results and archive new ones
                archiveArtifacts artifacts: 'results/**/*', allowEmptyArchive: true
                junit 'results/**/*.xml'

                def testResults = currentBuild.rawBuild.getAction(hudson.tasks.test.AbstractTestResultAction.class)?.result

                def subject = "Jenkins Pipeline Build ${currentBuild.fullDisplayName} - ${currentBuild.result}"
                def body = """
                    <p>Build Status: <b>${currentBuild.result}</b></p>
                    <p>Build URL: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                    <p>Test Results Summary:</p>
                    <table border="1" style="border-collapse: collapse;">
                        <tr>
                            <th>Total Tests</th>
                            <th>Passed</th>
                            <th>Failed</th>
                        </tr>
                        <tr>
                            <td>${testResults?.totalCount ?: 0}</td>
                            <td>${testResults?.passCount ?: 0}</td>
                            <td>${testResults?.failCount ?: 0}</td>
                        </tr>
                    </table>
                """

                if (testResults?.failCount > 0) {
                    body += """
                        <p>Failed Test Cases:</p>
                        <table border="1" style="border-collapse: collapse;">
                            <tr>
                                <th>Test Name</th>
                                <th>Error Message</th>
                            </tr>
                    """
                    testResults.failedTests.each { test ->
                        body += """
                            <tr>
                                <td>${test.name}</td>
                                <td>${test.errorDetails ?: 'No error details available'}</td>
                            </tr>
                        """
                    }
                    body += "</table>"
                }

                emailext (
                    to: 'srinivas8862@gmail.com',
                    subject: subject,
                    body: body,
                    mimeType: 'text/html'
                )
            }
        }
    }
}