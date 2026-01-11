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
                    // Use a shell command to find the test files, excluding __init__.robot
                    def testFiles = sh(script: '''find FinalistenTestCases -name '*.robot' -not -name '__init__.robot' -not -path '*/keywords/*' ''', returnStdout: true).trim().split('\n')

                    // Loop through each test file path and execute it
                    for (filePath in testFiles) {
                        // Extract file name and suite name from the path for reporting
                        def fileName = filePath.split('/').last()
                        def suiteName = fileName.take(fileName.lastIndexOf('.'))

                        sh """
                            # Activate the virtual environment for each test run
                            source venv/bin/activate
                            echo "Running test case: ${filePath}"
                            robot --variable CHROME_OPTIONS:"add_argument('--headless');add_argument('--no-sandbox');add_argument('--disable-gpu');add_argument('--window-size=1920,1080')" --name "${suiteName}" --outputdir "results/${suiteName}" --xunit "${fileName}-results.xml" "${filePath}" || true
                        """
                    }
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

                def reportContent = "Test Execution Report\n"
                reportContent += "---------------------\n"
                reportContent += "Total Test Cases: ${testResults?.totalCount ?: 0}\n"
                reportContent += "Passed Test Cases: ${testResults?.passCount ?: 0}\n"
                reportContent += "Failed Test Cases: ${testResults?.failCount ?: 0}\n"

                if (testResults?.failCount > 0) {
                    reportContent += "\nPlease check the Jenkins build artifacts for detailed failure information.\n"
                    reportContent += "View the Robot Framework HTML reports in the archived results.\n"
                } else {
                    reportContent += "\nAll tests passed!\n"
                }

                def timestamp = new Date().format('yyyyMMdd_HHmmss')
                def fileName = "test_report_${timestamp}.txt"

                writeFile file: fileName, text: reportContent

                // Send email notification
                def buildStatus = currentBuild.result ?: 'SUCCESS'
                def subject = "Robot Framework Test Results - ${buildStatus} - Build #${env.BUILD_NUMBER}"
                def body = """
                    <h2>Robot Framework Test Execution Report</h2>
                    <p><strong>Build:</strong> #${env.BUILD_NUMBER}</p>
                    <p><strong>Status:</strong> ${buildStatus}</p>
                    <p><strong>Date:</strong> ${timestamp}</p>
                    
                    <h3>Test Results Summary:</h3>
                    <ul>
                        <li><strong>Total Test Cases:</strong> ${testResults?.totalCount ?: 0}</li>
                        <li><strong>Passed:</strong> <span style="color: green;">${testResults?.passCount ?: 0}</span></li>
                        <li><strong>Failed:</strong> <span style="color: red;">${testResults?.failCount ?: 0}</span></li>
                    </ul>
                    
                    <p><strong>Jenkins Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                    <p><strong>Test Report:</strong> <a href="${env.BUILD_URL}artifact/${fileName}">${fileName}</a></p>
                    
                    <hr/>
                    <pre>${reportContent}</pre>
                """

                emailext (
                    to: 'srinivas8862@gmail.com',
                    subject: subject,
                    body: body,
                    mimeType: 'text/html',
                    attachLog: true,
                    compressLog: true
                )
            }
        }
    }
}