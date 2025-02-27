# CloudWatch Alerts

##### Terraform module to enable CloudWatch alerts

Sends alerts when CPU usage goes above ${cpu_threshold} percent.

Usage
-----

Create the CloudWatch alerts for the specified EC2 instances

```hcl-terraform
module "softnas_monitoring" {
  source = "../modules/cloudwatch_alerts"

  name               = "${terraform.workspace}-softnas-alerts"
  ec2_instance_ids   = "${module.user_nfs_softnas.ec2_instance_ids}"
  ec2_instance_names = "${module.user_nfs_softnas.ec2_instance_names}"
  cpu_threshold      = 80
  email         = "analytics-platform-tech@digital.justice.gov.uk"

  tags = "${var.tags}"
}
```

Parameters
-----------
| Name                                 | Type     | Description                               |
| ------------------------------------ | -------- | ----------------------------------------- |
| `name`                (**Required**) | `string` | Name of the resources |
| `ec2_instance_names`  (**Required**) | `list`   | Names of the EC2 instances to monitor |
| `ec2_instance_ids`    (**Required**) | `list`   | IDs of the EC2 instances to monitor |
| `email`               (**Required**) | `string` | email address where alerts are sent to |
| `tags`                (**Required**) | `map`    | Tags to attach to resources |
| `cpu_threshold`                      | `number` | CPU usage threashold (percentage) which triggers the alert (**default `80`**) |
