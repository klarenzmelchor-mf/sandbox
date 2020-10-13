# Inspector module

The resources created by this module are:

* Assessment Targets.
* Assessment Template.
* Inspector IAM Role.
* Cloudwatch Event Rule.

This module can be used to enable [Inspector](https://docs.aws.amazon.com/inspector/latest/userguide/inspector_introduction.html).

By default, Network Reachability, CVE, CIS and Security Best Practices rule packages are enabled in this module. The ARNs of these packages were different per regions. See [Amazon Inspector ARNs](https://docs.aws.amazon.com/inspector/latest/userguide/inspector-arns.html)

## How do you use this module?

* See the [root README](/README.md) for instructions on using Terraform modules.
* See [variables.tf](./variables.tf) for all the variables you can set on this module.
* See [outputs.tf](./outputs.tf) for all the outputs you can use on this module.