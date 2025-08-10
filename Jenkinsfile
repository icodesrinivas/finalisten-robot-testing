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
                    // Find all .robot files, excluding __init__.robot files which are not test cases
                    def testFiles = findFiles(glob: 'FinalistenTestCases/**/*.robot', excludes: '**/__init__.robot')

                    // Loop through each test file and execute it
                    for (file in testFiles) {
                        sh """
                            # Activate the virtual environment for each test run
                            source venv/bin/activate
                            echo "Running test case: ${file.path}"
                            robot --variable CHROME_OPTIONS:"add_argument('--headless');add_argument('--no-sandbox');add_argument('--disable-gpu');add_argument('--window-size=1920,1080')" --name "${file.name.take(file.name.lastIndexOf('.'))}" --outputdir "results/${file.name.take(file.name.lastIndexOf('.'))}" --xunit "${file.name}-results.xml" "${file.path}"
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
