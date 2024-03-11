podTemplate{
    node(POD_LABEL) {
        stage('Get a Maven project') {
            container('ubuntu') {
                stage('Build a Maven project') {
                    sh 'echo URA!'
                }
            }
        }
    }
}
