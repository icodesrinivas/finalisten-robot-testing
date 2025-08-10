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
                    def testFiles = sh(script: "find FinalistenTestCases -name '*.robot' -not -name '__init__.robot'", returnStdout: true).trim().split('\n')

                    // Loop through each test file path and execute it
                    for (filePath in testFiles) {
                        // Extract file name and suite name from the path for reporting
                        def fileName = filePath.split('/').last()
                        def suiteName = fileName.take(fileName.lastIndexOf('.'))

                        sh """
                            # Activate the virtual environment for each test run
                            source venv/bin/activate
                            echo "Running test case: ${filePath}"
                            robot --variable CHROME_OPTIONS:"add_argument('--headless');add_argument('--no-sandbox');add_argument('--disable-gpu');add_argument('--window-size=1920,1080')" --name "${suiteName}" --outputdir "results/${suiteName}" --xunit "${fileName}-results.xml" "${filePath}"
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up previous results and archive new ones
            archiveArtifacts artifacts: 'results/**/*', allowEmptyArchive: true
            junit '*-results.xml'
        }
    }
}
