# Amazon Macie module

The resources created by this module are:

* KMS Key
* S3 Bucket

This module can be used to enable [Amazon Macie2](https://docs.aws.amazon.com/macie/latest/userguide/macie-migration.html). You can check out the full macie guide [here](https://docs.aws.amazon.com/macie/latest/user/macie-user-guide.pdf)

Amazon Macie2 is not supported yet with terraform. Attaching the S3 Bucket and KMS Key must be done **MANUALLY**.

## How do you use this module?

* See the [root README](/README.md) for instructions on using Terraform modules.
* See [variables.tf](./variables.tf) for all the variables you can set on this module.
* See [outputs.tf](./outputs.tf) for all the outputs you can use on this module.