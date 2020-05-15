pipeline {

   parameters {
    choice(name: 'action', choices: 'create\ndestroy', description: 'Create/update or destroy stack.')
    choice(name: 'deploy', choices: 'single-node\nelb-2-nodes\nnlb-2-nodes', description: 'Deployment type.')
    string(name: 'prefix', defaultValue : '', description: "Prefix for AWS resources so you can create multiple stacks.")
    string(name: 'ec2_instance_type', defaultValue : 't3a.medium', description: "k8s node instance type.")
    string(name: 'ec2_key_pair', defaultValue : 'spicysomtam-aws4', description: "k8s node ssh keypair.")
    string(name: 'url_ingress_cidrs', defaultValue : '0.0.0.0/0', description: "rancher url ingress cidrs; space delimited list.")
    string(name: 'ssh_ingress_cidrs', defaultValue : '0.0.0.0/0', description: "server ssh ingress cidrs; space delimited list.")
    string(name: 'mysql_instance_type', defaultValue : 'db.t2.micro', description: "mysql db instance type.")
    string(name: 'mysql_password', defaultValue : 'ajzk8(Lpmz', description: "Mysql password.")
    choice(name: 'helm_repo', choices: 'latest\nstable\nalpha', description: 'In essence, release of rancher to install.')
    string(name: 'rancher_dns_name', defaultValue : 'rancher.alastair-munro.com', description: "The dns name for your rancher.")
    string(name: 'credential', defaultValue : 'jenkins', description: "Jenkins credential that provides the AWS access key and secret.")
    string(name: 'region', defaultValue : 'eu-west-1', description: "AWS region.")
  }

  options {
    disableConcurrentBuilds()
    timeout(time: 1, unit: 'HOURS')
    withAWS(credentials: params.credential, region: params.region)
    ansiColor('xterm')
  }

  agent { label 'master' }

  stages {

    stage('Setup') {
      steps {
        script {
          if (params.prefix == '') {
            currentBuild.displayName = "#" + env.BUILD_NUMBER + " " + params.action + " UNKNOWN-" + params.deploy
            error("Prefix not defined!")
          }

          currentBuild.displayName = "#" + env.BUILD_NUMBER + " " + params.action + " " + params.prefix + "-" + params.deploy
          plan = params.prefix + "-" + params.deploy + '.plan'
        }
      }
    }

    stage('TF Plan') {
      when {
        expression { params.action == 'create' }
      }
      steps {
        script {
          withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
            credentialsId: params.credential, 
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',  
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {

            ingress = '["' + params.url_ingress_cidrs.replaceAll(/\s+/,'\",\"') + '"]'
            ssh_ingress = '["' + params.ssh_ingress_cidrs.replaceAll(/\s+/,'\",\"') + '"]'

            sh """
              cd ${params.deploy}
              terraform init
              terraform workspace new ${params.prefix} || true
              terraform workspace select ${params.prefix}
              terraform plan \
                -var prefix=${params.prefix} \
                -var aws_region=${params.region} \
                -var inst-type=${params.ec2_instance_type} \
                -var 'rancher-ingress-cidrs=${ingress}' \
                -var 'ssh-ingress-cidrs=${ssh_ingress}' \
                -var key-pair=${params.ec2_key_pair} \
                -var mysql-password='${params.mysql_password}' \
                -var mysql-instance-class=${params.mysql_instance_type} \
                -var rancher-helm-repo=${params.helm_repo} \
                -var rancher-dns-name=${params.rancher_dns_name} \
                -out ${plan}
            """
          }
        }
      }
    }

    stage('TF Apply') {
      when {
        expression { params.action == 'create' }
      }
      steps {
        script {
          input "Create terraform stack ${params.prefix}-${params.deploy} in aws?" 

          withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
            credentialsId: params.credential, 
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',  
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {

            sh """
              cd ${params.deploy}
              terraform apply -input=false -auto-approve ${plan}
            """

            if (params.deploy == 'single-node') {
              println "Don't forget to setup the dns for https://" + params.rancher_dns_name + " to be either the server_public_ip or point to the server_public_dns."
            } else {
              println "Don't forget to setup the dns for https://" + params.rancher_dns_name + " to point to the lb_dns_name."
            }
          }
        }
      }
    }

    stage('TF Destroy') {
      when {
        expression { params.action == 'destroy' }
      }
      steps {
        script {
          input "Destroy terraform stack ${params.prefix}-${params.deploy} in aws?" 

          withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
            credentialsId: params.credential, 
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',  
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {

            sh """
              cd ${params.deploy}
              terraform workspace select ${params.prefix}
              terraform destroy -auto-approve
            """
          }
        }
      }
    }

  }

}