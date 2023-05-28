FROM jenkins/jenkins:lts

USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins "ssh-slaves slack \
greenballs workflow-aggregator metrics docker-plugin \
docker-workflow docker-swarm ssh-agent aws-credentials pipeline-aws git ansible \
jaxb aws-java-sdk-minimal jackson2-api junit pipeline-model-definition pipeline-rest-api \
pipeline-model-api docker-java-api aws-java-sdk-minimal echarts-api github-api aws-java-sdk-ec2 \
aws-java-sdk-cloudformation matrix-project"
                                  
#Groovy post-init script
COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/init.groovy


