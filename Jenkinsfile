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

                def reportContent = "Test Execution Report\n"
                reportContent += "---------------------\n"
                reportContent += "Total Test Cases: ${testResults?.totalCount ?: 0}\n"
                reportContent += "Passed Test Cases: ${testResults?.passCount ?: 0}\n"
                reportContent += "Failed Test Cases: ${testResults?.failCount ?: 0}\n"

                if (testResults?.failCount > 0) {
                    reportContent += "\nFailed Test Cases Details:\n"
                    testResults.failedTests.each { test ->
                        reportContent += "- ${test.name} (Error: ${test.errorDetails ?: 'No error details available'})\n"
                    }
                } else {
                    reportContent += "\nAll tests passed!\n"
                }

                def timestamp = new Date().format('yyyyMMdd_HHmmss')
                def fileName = "test_report_${timestamp}.txt"

                writeFile file: fileName, text: reportContent
            }
        }
    }
}