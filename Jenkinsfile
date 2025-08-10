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

        stage('Run Robot Test') {
            steps {
                script {
                    // It is a good practice to use a relative path
                    // In Jenkins workspace the project root is the root of the repository
                    sh """
                        echo "Running test case: ${params.TEST_CASE_FILE}"
                        source dsaenv/bin/activate
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
