# EMR with Prometheus & Grafana
Setting up an example EMR cluster monitored by Prometheus & Grafana using terraform and packer.

Based on [AWS Big Data blog](https://aws.amazon.com/blogs/big-data/monitor-and-optimize-analytic-workloads-on-amazon-emr-with-prometheus-and-grafana/). 

### Prometheus & Grafana image
Go to ./packer and build the image
```
export AWS_PROFILE=private
packer build image.json
```

### Terraform
Create a file test.tfvars
```
public_subnet_id = "..."
ssh_key_name     = "..."
cidr_access      = "..."
bucket_name      = "..."
```

Then use terraform to deploy the Grafana/Prometheus AMI created by packer as well as a long-running EMR cluster.

```
cd terraform
terraform init
terraform apply -var-file=test.tfvars
```

### Explore
Terraform will output the Grafana DNS. Go there and check the eight configured dashboards.
