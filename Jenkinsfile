pipeline {
    agent { label 'pyy' }
    
   environment {
        GIT_REPO = 'https://github.com/Polinkaly/supertrac_public.git'
        WORKDIR = '/home/jenkins/my_project'
        DISTDIR = '/home/jenkins/my_project/dist/*'
        BUILDDIR = '/home/jenkins/my_buld'
		SSH_CREDENTIALS_ID = '40f198be-bb5c-48ef-a189-b0ed037086bf'
		REMOTE_HOST = 'root@10.26.0.32'
		REMOTE_DIR = '/root'
		IMAGE_NAME = 'trac'
        IMAGE_TAG = 'latest'
    }
        
       stage('Clean Workspace') {
            steps {
                script {
                    // Подготовка рабочего каталога в контейнере агента
                    sh "rm -rf ${WORKDIR} 2> /dev/null"
                }
            }
        }
       stage('Prepare Workspace') {
            steps {
                script {
                    // Подготовка рабочего каталога в контейнере агента
                    sh "mkdir -p ${WORKDIR}"
                    sh "mkdir -p ${BUILDDIR}"
                }
            }
        }
        
        stage('Clone repository') {
            steps {
                script {
                    // Клонирование репозитория в рабочий каталог в контейнере агента
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
                    // Переход в каталог с репозиторием и сборка приложения
                    // Предполагается, что в репозитории есть Dockerfile
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
				     sh "cd ${WORKDIR} && tar -czf package.tar.gz Dockerfile dist/*.whl"
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
