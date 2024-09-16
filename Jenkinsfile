def label = "mypod-${UUID.randomUUID().toString()}"
podTemplate(label: label, cloud: 'kubernetes', containers: [
    containerTemplate(name: 'maven', image: 'maven:3.6.3-openjdk-17', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'kubectl', image: 'registry.cn-beijing.aliyuncs.com/citools/kubectl:self-1.17', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'node', image: 'node:lts', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'golang', image: 'golang:1.15', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'docker', image: 'docker:27.2.1', ttyEnabled: true, command: 'cat'),
  ],
namespace: 'jenkins',
nodeSelector: 'build',
workspaceVolume: hostPathWorkspaceVolume(hostPath: "/home/vagrant/test"),
volumes: [
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
    hostPathVolume(mountPath: '/root/.m2', hostPath: '/home/vagrant/test/m2'),
    secretVolume(secretName: 'cacerts', mountPath: '/etc/pki/ca-trust/extracted/java/'),
],
) {
    node(label) {

        def COMMIT_ID = "a1b1c1"
        def HARBOR_ADDRESS = "harbor.cs.com"
        def REGISTRY_DIR = "test1"
        def IMAGE_NAME = "alpine"
        def NAMESPACE = "jenkins" 
        def TAG = "v2"
 
        stage('Get a Maven Project') {
            // git 'https://github.com/yunhai20082008/spring-boot-api-project-seed.git'
            git 'https://github.com/yunhai20082008/test-jenkins-maven.git'
            container('maven') {
                stage('Build a Maven project') {
                    sh """   
                        echo ${COMMIT_ID}
                    """ 
                }
            }
        }
        stage('SonarQube Analysis') {
            container('maven') {
                withSonarQubeEnv() {
                sh """
                    mvn clean verify sonar:sonar -Dsonar.projectKey=go -Dsonar.projectName='go' \
                        -Dsonar.host.url=https://sonarqube.cs.com \
                        -Dsonar.token=sqp_7b50c6b7e239c378e1d342837b14f59900635d08
                """
                }
            }
        }
        stage('Docker build for creating image') { 
            withCredentials([[$class: 'UsernamePasswordMultiBinding',
                credentialsId: 'HARBOR_ACCOUNT',
                usernameVariable: 'HARBOR_USER_USR',
                passwordVariable: 'HARBOR_USER_PSW']]) {
                    container(name: 'docker') {
                        sh """
                        echo ${HARBOR_USER_USR} ${HARBOR_USER_PSW} ${TAG}
                        docker build -t ${HARBOR_ADDRESS}/${REGISTRY_DIR}/${IMAGE_NAME}:${TAG} .
                        docker login -u ${HARBOR_USER_USR} -p ${HARBOR_USER_PSW} ${HARBOR_ADDRESS}
                        docker push ${HARBOR_ADDRESS}/${REGISTRY_DIR}/${IMAGE_NAME}:${TAG}
                        """ 
                    }
                }
        }
        stage('DEPLOY') { 
            withCredentials([file(credentialsId: 'KUBECONFIG', variable: 'MY_KUBECONFIG')]) {
                container(name: 'kubectl') {
                    sh """
                        echo ${COMMIT_ID}
                        mkdir -p ~/.kube
                        cp ${MY_KUBECONFIG} ~/.kube/config
                        kubectl get pod -A
                        /usr/local/bin/kubectl --kubeconfig $MY_KUBECONFIG set image deploy -l app=${IMAGE_NAME} ${IMAGE_NAME}=${HARBOR_ADDRESS}/${REGISTRY_DIR}/${IMAGE_NAME}:${TAG} -n $NAMESPACE 
                    """ 
                }
            }
        }
        stage('Get a Maven Project11111') {
            container('node') {
                stage('Build a Maven project') {
                    // mvn -B clean install -DskipTests
                    sh """   
                        sleep 600
                    """ 
                }
            }
        }    
    
    }
}
