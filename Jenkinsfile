podTemplate(containers: [
    containerTemplate(name: 'python', image: 'ubuntu:22.04', command: 'sleep', args: '99d')

  ]) {
 node(POD_LABEL) {
    
    def GIT_REPO = 'https://github.com/Polinkaly/supertrac_public.git'
    def WORKDIR = '/home/jenkins/my_project'
    def DISTDIR = '/home/jenkins/my_project/dist/*'
    def BUILDDIR = '/home/jenkins/my_buld'
    def SSH_CREDENTIALS_ID = '40f198be-bb5c-48ef-a189-b0ed037086bf'
    def REMOTE_HOST = 'root@10.26.0.32'
    def REMOTE_DIR = '/root'
    def IMAGE_NAME = 'trac'
    def IMAGE_TAG = 'latest'
  

  
      stage('Clean Workspace') {
    container('python') {
            sh "rm -rf ${WORKDIR} 2> /dev/null"
            sh "apt update"
            sh "apt install -y git"
    }
      }
      stage('Prepare Workspace') {
         container('python') {
            sh "mkdir -p ${WORKDIR}"
            sh "mkdir -p ${BUILDDIR}"
         }
      }
    
      stage('Clone repository') {
         container('python') {
            sh "git clone ${GIT_REPO} ${WORKDIR}"
         }
      }
    
      stage('Resolve dependencies') {
         container('python') {
            sh "cd ${WORKDIR} && python3 -m venv .venv"
            sh "cd  ${WORKDIR} && source .venv/bin/activate && pip3 install -r requirements-release.txt"
         }
      }
    
      stage('Run tests') {
        container('python') {
            sh "cd  ${WORKDIR} && source .venv/bin/activate && python3 -c 'import trac.tests as test; test.test_suite()'"
        }
      }
    
      stage('Build application') {
        container('python') {
            sh "cd ${WORKDIR} && python3 -m venv .venv"
            sh "cd  ${WORKDIR} && source .venv/bin/activate && pip3 install wheel"
            sh "cd  ${WORKDIR} && source .venv/bin/activate && python3 setup.py bdist_wheel "
            sh "cp -rf ${DISTDIR} ${BUILDDIR}"
    
        }
      }
    
      stage('Prepare and archive files') {
         container('python') {
            sh "cd ${WORKDIR} && tar -czf package.tar.gz Dockerfile start.sh .htpasswd dist/*.whl"
         }
      }
    
      stage('Transfer Files') {
     container('python') {
            sshagent([SSH_CREDENTIALS_ID]) {
              sh "scp -o StrictHostKeyChecking=no ${WORKDIR}/package.tar.gz ${REMOTE_HOST}:${REMOTE_DIR}"
            }    
     }
      }
    
      stage('Deploy Docker image') {
       container('python') {
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
