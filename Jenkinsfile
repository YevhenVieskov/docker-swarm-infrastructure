// Jenkinsfile
String credentialsId = 'awsCredentials'
properties([pipelineTriggers([githubPush()])])
pipeline {
  
  environment {
    tf_s3              = 'infrastructure/s3_tfstate'
    iac                = './iac'     
    plan_file          = 'plan.tfplan'
    AWS_DEFAULT_REGION ="us-west-2"        
  }

  agent any
  options {
    disableConcurrentBuilds()
  }

  stages{

    stage("Checkout") {
      steps {
        git credentialsId: 'github-ssh-key', url: 'https://github.com/YevhenVieskov/docker-swarm-infrastructure.git', branch: 'main'

      }
    }
    
    stage('Tools versions') {
      steps {
        sh '''
          terraform --version
          aws --version          
          docker --version
        '''
      }
    }

    stage('Initialisation network and security related infrastructure with TF') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'vieskovtf', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh '''
            echo "#---> Initialisation and validation network infrastructure with TF..."
            cd ${WORKSPACE}/$iac
            terraform init && terraform validate
            
          '''
        }
      }
    }

    stage('Create network and security related infrastructure with TF') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'vieskovtf', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh '''
            echo "#---> Create network and security network infrastructure with TF..."
            cd ${WORKSPACE}/$iac            
            #terraform apply -target aws_route53_zone.main -auto-approve           
            terraform apply -auto-approve
          '''
        }
      }
    }
	
	stage('Create list of output variables with TF') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'vieskovtf', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh '''
            echo "#---> Create network and security network infrastructure with TF..."
            cd ${WORKSPACE}/$iac        
                       
            terraform output
			      terraform output -json
          '''
        }
      }
    }
    
    stage("Approve") {
      steps { approve('Do you want to destroy your infrastructure?') }
		}

    stage('Destroy network and security related infrastructure with TF') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'vieskovtf', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh '''
            echo "#---> Destroy network and security related infrastructure with TF..."
            cd ${WORKSPACE}/$iac
            
            terraform destroy -auto-approve
          '''
        }
      }
    } //stage destroy  

  }  //stages   

} //pipeline


def approve(msg) {
	timeout(time:1, unit:'DAYS') {
		input(msg)     
	}
}




