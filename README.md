# Aim

To implement rancher 2.4.3 k3s install on aws using terraform, following the rancher k3s instructions [Installing Rancher on a Kubernetes Cluster](https://rancher.com/docs/rancher/v2.x/en/installation/k8s-install/). The instructions say that you should use an AWS Network Load Balancer (NLB), and provides instructions [here](https://rancher.com/docs/rancher/v2.x/en/installation/options/nlb/). My plan was to implement a two node k3s configuration behind an AWS load balancer, which is an ideal, minimal k3s configuration with fault tolerance. I also provide a single node deploy, which is perfect for development, etc.

# Issue with an AWS Network Load Balancer and k3s

## Incorrect rancher instructions for k3s
 
The rancher [instructions](https://rancher.com/docs/rancher/v2.x/en/installation/options/nlb/) for creating the Network Load Balancer are incorrect for k3s. The issues:

* The health check settings are misleading and not required. We are implementing a TCP load balancer (connect to a port) and its not concerned with any protocols such as HTTP/HTTPS. Furthermore this health check causes the targets to be shown as unhealthy, because of the use of the treafik ingress controller, and will mislead that things are not working correctly.
* The target group for HTTPS (443) should be directed to port 443 on the ec2 nodes and not port 80.

What you will see on your web browser is connection to port 80 on the load balancer, which will be redirected to https (443). Your load balancer needs to allow both ports (on just 443 if you prefer).

Lets look at treafik and why health check shows unhealthy: traefik requires a hostname to connect to the rancher service in k8s. With the AWS NLB, it tries to probe the `/healthz` endpoint to check the service is there, which does not work as the NLB has no way of passing the hostname through to treafik, and thus treafik never directs requests to the rancher service. So the NLB never detects good targets, and this misleads you to believe all is not well. However, if you have your dns setup correctly to point to the aws nlb (alias record), and you use that to access rancher, then treafik will connect you through, and all will work as expected.

I reported the issue [here](https://github.com/rancher/rancher/issues/26977). Treafik is documented [here](https://docs.traefik.io/). A way to test treafik is routing requests is shown [here](https://docs.traefik.io/getting-started/quick-start/). Specifically this `curl` command:

```
curl -H Host:rancher.yourdomain http://aws-lb-dns-name
```

# Terraform

## Settings

Adapt the settings in `variables.tf` to your requirements. Important ones:

* rancher_dns_name - dns name for your rancher.
* aws_region - aws region (default eu-west-1).
* key_pair - already defined ec2 ssh keypair to use. So you can ssh into the ec2 instances for troubleshooting, etc.
* lb_internal - whether nlb is internal (true or false; default false).
* prefix - prefix for resource names. Allows you to deploy multiple stacks, including a mix of types (but keep the prefix unique across types).

There are more settings, but these are the basic ones.

## DNS for the rancher url

You will need to define the dns record for your rancher url. Then you will need to wait for the dns to propagate out (its a good idea to set the ttl to a low value so that it is propagated as quickly as possible). DNS is not included in the stack as you are unlikly to be using aws dns (route53).

## AWS credentials

I have refrained from hard coding these in the terraform as its bad practice. These should be defined in the shell by [environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html), etc.

## Rancher deployment

As we probably know, deployments in kubernetes are asynchronos; that is when we deploy, the api responds immediatly, but the deployment/s are still rolling out.

The case is also the same for the ec2 instance/s that host rancher/kubernetes. When these instances are deployed, we define a thing called userdata; this is linux commands to run on the instances when they are created. The userdata is used to install rancher. With the aws api, and thus terraform, when the ec2 instances are rolled out, the userdata is still deploying, and then also kubernetes within the instance is also still rolling out deployments.

Then we need to wait for the targets to become healthy in the k8s service (load balancer), which can take time.

Finally we need to wait for the dns name for rancher to propogate across the internet to your client.

When I first developed the stacks, you would need to wait for all of above to complete. Now the stack waits for rancher to pass health checks (become healthy/live). Thus you only need for your dns to propogate.

## Installs into the default vpc

To keep things simple, the deploys are deployed into the default vpc. If you require a specific vpc, consider adapting `vpc.tf`, and adding a variable for it.

## Configurations

Two configurations, following rancher instructions for deploy on k3s.

### Single node

As a result of the issues with treafik, I decided to implement a single node deploy of k3s without an AWS NLB, to prove that my setup was working. This is in the `single-node` sub directory. I decided to keep it, as it may be useful to have a minimal, single node deployment for development, etc.

### NLB with 2 nodes

This is the k3s minimum fault tolerant configuration recommended by rancher. You will find this deploy in the `nlb-2-nodes` sub directory.

## Prefix

I introduced a prefix for aws resource names. This allows you to deploy multiple stacks in the same aws account, using different prefixes. 

You can mix the deployment types, as long as the prefix is unique.

You probably want to keep the prefix as short as possible; maybe 2 or 3 characters.

## Wait for rancher health check to pass

The deploys will wait for the health check for rancher to return `ok`. This may take 6 minutes or so, based on the default instance types, so be patient!

# Jenkins pipeline

I also included a Jenkinsfile pipeline, which will allow you to do these deploys from Jenkins. 

Since Jenkins keeps previous builds, you can see what has been created/destroyed in the past, and can use this to track deployments, and then tear them down as required.

A prequisite for deploying via Jenkins is for the terraform binary to be installed in the Jenkins server. 

This is a fairly simple deploy; trying to keep things simple. You could adapt it to use different Jenkins agents or even use the terraform Jenkins plugin. Feel free to adapt to your needs via a github fork, etc. 

If you want to be really cool, deploy jenkins as a k8s deployment and then use k8s cloud agents!