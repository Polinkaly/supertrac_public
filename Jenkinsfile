podTemplate(containers: [
    containerTemplate(name: 'ubuntu', image: 'ubuntu:latest', command: 'sleep', args: '99d'),
  ]) {

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
