
  
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

  stages {
      stage('Clean Workspace') {
        steps {
          script {
            sh "rm -rf ${WORKDIR} 2> /dev/null"
          }
        }
      }
      stage('Prepare Workspace') {
        steps {
          script {
            sh "mkdir -p ${WORKDIR}"
            sh "mkdir -p ${BUILDDIR}"
          }
        }
      }
    
      stage('Clone repository') {
        steps {
          script {
            sh "git clone ${GIT_REPO} ${WORKDIR}"
          }
        }
      }
    
      stage('Resolve dependencies') {
        steps {
          script {
            sh "cd ${WORKDIR} && python3 -m venv .venv"
            sh "cd  ${WORKDIR} && source .venv/bin/activate && pip3 install -r requirements-release.txt"
    
          }
        }
      }
    
      stage('Run tests') {
        steps {
          script {
            sh "cd  ${WORKDIR} && source .venv/bin/activate && python3 -c 'import trac.tests as test; test.test_suite()'"
          }
        }
      }
    
      stage('Build application') {
        steps {
          script {
            sh "cd ${WORKDIR} && python3 -m venv .venv"
            sh "cd  ${WORKDIR} && source .venv/bin/activate && pip3 install wheel"
            sh "cd  ${WORKDIR} && source .venv/bin/activate && python3 setup.py bdist_wheel "
            sh "cp -rf ${DISTDIR} ${BUILDDIR}"
    
          }
        }
      }
    
      stage('Prepare and archive files') {
        steps {
          script {
            sh "cd ${WORKDIR} && tar -czf package.tar.gz Dockerfile start.sh .htpasswd dist/*.whl"
          }
        }
      }
    
      stage('Transfer Files') {
        steps {
          script {
            sshagent([SSH_CREDENTIALS_ID]) {
              sh "scp -o StrictHostKeyChecking=no ${WORKDIR}/package.tar.gz ${REMOTE_HOST}:${REMOTE_DIR}"
            }
          }
        }
      }
    
      stage('Deploy Docker image') {
        steps {
          script {
            sshagent([SSH_CREDENTIALS_ID]) {
              sh "ssh ${REMOTE_HOST} 'cd ${REMOTE_DIR}'"
              sh "ssh ${REMOTE_HOST} 'tar -xzf package.tar.gz'"
              sh "ssh ${REMOTE_HOST} 'docker stop ${IMAGE_NAME} || true'"
              sh "ssh ${REMOTE_HOST} 'docker rm ${IMAGE_NAME} || true'"
              sh "ssh ${REMOTE_HOST} 'docker image rm ${IMAGE_NAME} || true'"
              sh "ssh ${REMOTE_HOST} 'docker exec faf18903f0e8 bash -c \"psql -U postgres -c \\\"drop database trac;\\\"\"' || true"
              sh "ssh ${REMOTE_HOST} 'docker exec faf18903f0e8 bash -c \"psql -U postgres -c \\\"create database trac;\\\"\"'"
              sh "ssh ${REMOTE_HOST} 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -f Dockerfile .'"
              sh "ssh ${REMOTE_HOST} 'docker run -d --name ${IMAGE_NAME} -p 8000:8000 ${IMAGE_NAME}:${IMAGE_TAG}'"
            }
          }
        }
      }
    }
  }
}
