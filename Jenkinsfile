
  
def GIT_REPO = 'https://github.com/Polinkaly/supertrac_public.git'
def WORKDIR = '/home'
def DISTDIR = '/home/dist/*'
def BUILDDIR = '/home/my_buld'
def SSH_CREDENTIALS_ID = '40f198be-bb5c-48ef-a189-b0ed037086bf'
def REMOTE_HOST = 'root@10.26.0.32'
def REMOTE_DIR = '/root'
def IMAGE_NAME = 'trac'
def IMAGE_TAG = 'latest'

podTemplate(yaml: '''
              apiVersion: v1
              kind: Pod
              spec:
                containers:
                - name: ubuntu
                  image: ubuntu:latest
''') {
    node(POD_LABEL) {
        stage('Run shell') {
            sh 'echo hello world'
        }
    }
}

