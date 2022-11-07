pipeline {

    agent any

    options {
        timeout(time: 2, unit: 'HOURS')
        buildDiscarder(logRotator(daysToKeepStr: '30', artifactDaysToKeepStr: '2', numToKeepStr: '100'))
        timestamps()
    }

    parameters {
        choice choices: ['localhost'], description: 'The cluster where the App should be deployed to.', name: 'CLUSTER'
        
        string defaultValue: 'carrental', description: 'Name of the Kubernetes namespace to use for deployment.<br/><strong>The namespace should be dedicated to this deployment. <span style="color:red">If it already exists, it will be deleted.</span></strong>', name: 'NS'

        string defaultValue: '', description: 'Name of the Helm release. If it\'s blank, the namespace will be used as the release name.', name: 'RELEASE_NAME'

        string defaultValue: 'main', description: 'Git branch name', name: 'GIT_BRANCH'

        booleanParam defaultValue: true, description: 'If set, deploys a minimal instance that requires less resources at the cost of high availability.', name: 'MINI'

    }

    stages {
        stage('Clone required repos') {
            steps {
                ws("deploy_carrental") {
                    git(
                        changelog: false,
                        poll: false,
                        url: 'https://github.com/martikan/carrental_CI-CD',
                        branch: '${GIT_BRANCH}'
                    )
                }
            }
        }

        stage('Deploy Application') {
            steps {
                ws("deploy_carrental") {
                    script {

                        pwd

                        ls -al

                        sh '''#!/bin/bash
                            env -0 | sort -z | tr '\\0' '\\n'
                            chmod +x "${WORKSPACE}/ci/deploy_carrental.sh"
                        '''
                        
                        echo "Deploying Application to namespace ${env.NS} on cluster ${env.CLUSTER} ..."

                        if (params.CLUSTER == "localhost") {
                            unset KUBECONFIG
                        }

                        sh "${WORKSPACE}/ci/deploy_cds.sh"

                        echo "Application has been deployed to ${env.CLUSTER}"
                    }
                }
            }
        }
    }

    post {
        success {
            ws('deploy_carrental') {
                archiveArtifacts allowEmptyArchive: true, artifacts: 'carrental_deployment.json'

                script {
                    def props = readJSON file: 'carrental_deployment.json'
                    def cluster_name = params.NS

                    currentBuild.description = "<a href=${props['ui_url']}>${cluster_name} (${props['cds_version']})</a>"

                    def userCauses = currentBuild.getBuildCauses('hudson.model.Cause$UserIdCause')
                    if (userCauses) {
                        currentBuild.description += "<br/>deployed by <em>" + userCauses.get(0).userName + "</em>"
                    }
                }
            }
        }
    }

}
