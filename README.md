Provisioning script for kubernetes to Scaleway (using Terraform).
=====

How to use:

1. Generate SSH keys for Scaleway and add it to the security section in Scaleway.
2. Issue a token from your scaleway account.
3. Create a Kubernetes token for terraform.tfvars.
   You can use ` python -c 'import random; print "%0x.%0x" % (random.SystemRandom().getrandbits(3*8), random.SystemRandom().getrandbits(8*8))' ` 
3. Update terraform.tfvars with appropriate configuration values.
4. Run "terraform plan" to review provisioning
5. Run "terraform apply" to provision your kubernetes cluster.
6. Get config file from master by running "scp -i privatekey root@masterip:/etc/kubernetes/admin.conf .
7. Run locally a proxy for accessing the cluster UI with "kubectl --kubeconfig ./admin.conf proxy"
