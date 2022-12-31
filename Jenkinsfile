/* import shared library */
@Library('shared-library')_

pipeline {
     environment {
       ID_DOCKER = "abdoulayedevops"
       IMAGE_NAME = "static-website"
       IMAGE_TAG = "latest"
       APP_NAME = "abdoulaye"
       STG_API_ENDPOINT = "ip10-0-0-3-ceo82c0mjkegg872cf00-1993.direct.docker.labs.eazytraining.fr"
       STG_APP_ENDPOINT = "ip10-0-0-3-ceo82c0mjkegg872cf00-8090.direct.docker.labs.eazytraining.fr"
       PROD_API_ENDPOINT = "ip10-0-0-4-ceo82c0mjkegg872cf00-1993.direct.docker.labs.eazytraining.fr"
       PROD_APP_ENDPOINT = "ip10-0-0-4-ceo82c0mjkegg872cf00-8090.direct.docker.labs.eazytraining.fr"
       INTERNAL_PORT = "80"
       EXTERNAL_PORT = "8090"
       CONTAINER_IMAGE = "${ID_DOCKER}/${IMAGE_NAME}:${IMAGE_TAG}"

     }
     agent none
     stages {
         stage('Build image') {
             agent any
             steps {
                script {
                  sh 'docker build -t ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG .'
                }
             }
        }
       
        stage('Run container based on builded image') {
            agent any
            steps {
               script {
                 sh '''
                    echo "Clean Environment"
                    docker rm -f $IMAGE_NAME || echo "container does not exist"
                    docker run --name $IMAGE_NAME -d -p ${EXTERNAL_PORT}:${INTERNAL_PORT} ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
                    sleep 5
                 '''
               }
            }
       }
       
       stage('Test image') {
           agent any
           steps {
              script {
                sh '''
                    curl http://172.17.0.1:${EXTERNAL_PORT} | grep -q "Dimension Abdoulaye"
                '''
              }
           }
      }
       
      stage('Clean Container') {
          agent any
          steps {
             script {
               sh '''
                 docker stop $IMAGE_NAME
                 docker rm $IMAGE_NAME
               '''
             }
          }
     }

      stage('Save Artefact') {
          agent any
          steps {
             script {
               sh '''
                 docker save  ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG > /tmp/static-website.tar                 
               '''
             }
          }
     }          
          
     stage ('Login and Push Image on docker hub') {
        agent any
        environment {
           DOCKERHUB_PASSWORD  = credentials('dockerhub_abdoulayedevops')
        }            
          steps {
             script {
               sh '''
                   echo $DOCKERHUB_PASSWORD_PSW | docker login -u $ID_DOCKER --password-stdin
                   docker push ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
               '''
             }
          }
      }    
     
      stage('STAGING - Deploy app') {
           when {
              expression { GIT_BRANCH == 'origin/develop' }
            }
      agent any
      steps {
          script {
            sh """
              echo  {\\"your_name\\":\\"${APP_NAME}\\",\\"container_image\\":\\"${CONTAINER_IMAGE}\\", \\"external_port\\":\\"${EXTERNAL_PORT}\\", \\"internal_port\\":\\"${INTERNAL_PORT}\\"}  > data.json 
              curl -X POST http://${STG_API_ENDPOINT}/staging -H 'Content-Type: application/json'  --data-binary @data.json 2>&1 | grep "200"
            """
          }
        }
     }
          
     stage('PRODUCTION - Deploy app') {
       when {
              expression { GIT_BRANCH == 'origin/master' }
            }
      agent any

      steps {
          script {
            sh """
               curl -X POST http://${PROD_API_ENDPOINT}/prod -H 'Content-Type: application/json' -d '{"your_name":"${APP_NAME}","container_image":"${CONTAINER_IMAGE}", "external_port":"${EXTERNAL_PORT}", "internal_port":"${INTERNAL_PORT}"}' 2>&1 | grep "200"
               """
          }
        }
     }
    }       
     
  post {
       always {
       script {
         slackNotifier currentBuild.result
     }
    }
   }
  }
