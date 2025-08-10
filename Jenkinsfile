pipeline {
    agent any

    parameters {
        string(name: 'TEST_CASE_FILE', defaultValue: 'FinalistenTestCases/contact/open_contact_create.robot', description: 'The path to the .robot file to execute.')
    }

    stages {
        stage('Checkout') {
            steps {
                // This will check out the code from the repository configured in the Jenkins job
                checkout scm
            }
        }

        stage('Setup and Run Robot Test') {
            steps {
                script {
                    sh """
                        # Create and activate a virtual environment
                        python3 -m venv venv
                        source venv/bin/activate

                        # Install dependencies
                        pip install -r requirements.txt

                        # Run the test
                        echo "Running test case: ${params.TEST_CASE_FILE}"
                        robot "${params.TEST_CASE_FILE}"
                    """
                }
            }
        }
    }

    post {
        always {
            // This publishes the robot framework results after every run
            robot 'output.xml'
        }
    }
}
