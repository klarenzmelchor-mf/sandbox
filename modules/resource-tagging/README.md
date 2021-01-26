# Resource Tagging Lambda Module

This Terraform Module can be used to deploy an [AWS Lambda](https://aws.amazon.com/lambda/) function that creates a custom tag to all resources. With this tag in-place on every resource, we will get 25% credit cost which is distributed quarterly from AWS. By default, this lambda function is triggered everyday at 12 midnight.




## How do you use this module?

* See the [root README](/README.md) for instructions on using Terraform modules in this repo.
* See [variables.tf](./variables.tf) for all the variables you can set on this module.





## What is AWS Lambda?

AWS Lambda lets you run code without provisioning or managing servers. You simply write your code in one of the 
supported languages (Python, JavaScript, Java, etc), use this module to upload that code to AWS Lambda, and AWS will 
execute that lambda function whenever you trigger it (there are many ways to trigger a lambda function, including 
manually in the UI, or on a scheduled basis, or via API calls through API Gateway, or via events such as an SNS 
message), without you having to run any servers. 

## Core concepts

For more info on AWS Lambda, check out [package-lambda](https://github.com/gruntwork-io/package-lambda).
