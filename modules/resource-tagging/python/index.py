import boto3
import os

servers = []

dict_tags = {}
#dict_tags["Key"] = "map-migrated"
#dict_tags["Value"] = "d-server-00l6aags6i42uj"
dict_tags["Key"] = os.environ.get("tag_key")
dict_tags["Value"] = os.environ.get("tag_key")

list_tags = []
list_tags.append(dict_tags)

list_ec2_ids = []


def tag_ec2():
    print("Tagging EC2 instances")
    ec2 = boto3.resource('ec2')
    servers = ec2.instances.all()

    for instance in servers:
        list_ec2_ids.append(instance.id)
        # tag EC2 instances
        instance.create_tags(Resources=list_ec2_ids, Tags=list_tags)

    print("-----------------------EC2 Instances-------------------------")
    for instance in servers:
        print("instance id: ", instance.id, " instance tags: ", instance.tags)
        print("")
    print("-------------------------------------------------------------")




def tag_ebs():
    print("Tagging EBS Volumes")
    ec2 = boto3.resource('ec2')
    volumes = ec2.volumes.all()

    for volume in volumes:
        volume.create_tags(Tags=list_tags)

    print("-----------------------EBS Volumes-------------------------")
    for volume in volumes:
        print("volume id: ", volume.id, " volume tags: ", volume.tags)
        print("")
    print("-------------------------------------------------------------")


def tag_elb():
    print("Tagging Loadbalancers")
    elb_client = boto3.client('elbv2')
    elbs = elb_client.describe_load_balancers()
    elb_list = elbs["LoadBalancers"] 

    for elb in elb_list:
        elb_client.add_tags(ResourceArns=[elb["LoadBalancerArn"]], Tags=list_tags)
        elb_tags = elb_client.describe_tags(ResourceArns=[elb["LoadBalancerArn"]])


        print("-----------------------EBS Volumes-------------------------")
        for elb_tag in elb_tags:
                print("elb arn: ", (elb_tag["TagDescriptions"][0]["ResourceArn"], " volume tags: ", elb_tag["TagDescriptions"][0]["Tags"]))
                print("")
        print("-------------------------------------------------------------")


def tag_rds():
    print("Tagging RDS's")
    rds_client = boto3.client('rds')
    rds = rds_client.describe_db_instances()
    rds_list = rds["DBInstances"]

    for rds_instance in rds_list:
        rds_client.add_tags_to_resource(ResourceName=rds_instance["DBInstanceArn"],Tags=list_tags)

    ## re-fetch the instances to get the update tags
    rds = rds_client.describe_db_instances()
    rds_list = rds["DBInstances"]

    print("-----------------------RDS Instance-------------------------")
    for rds_instance in rds_list:
        print("RDS arn: ", rds_instance["DBInstanceArn"], " RDS tags: ", rds_instance["TagList"])
        print("")
    print("-------------------------------------------------------------")


def tag_natGW():
    print("Tagging Nat Gateway")
    client = boto3.client('ec2')
    nat_gateway_list = client.describe_nat_gateways()
    for nat_gateway in nat_gateway_list['NatGateways']:
        client.create_tags(Resources=[nat_gateway["NatGatewayId"]], Tags=list_tags)

    print("-----------------------Nat Gateways-------------------------")
    nat_gateway_list = client.describe_nat_gateways()
    for nat_gateway in nat_gateway_list['NatGateways']:
        print("NatGatewayId: ", nat_gateway["NatGatewayId"], " NatGateway Tags: ", nat_gateway["Tags"])
        print("")
    print("-------------------------------------------------------------")


def tag_eip():
    print("Tagging EIPs")
    client = boto3.client('ec2')
    addresses_dict = client.describe_addresses()
    for eip_dict in addresses_dict['Addresses']:
        client.create_tags(Resources=[eip_dict['AllocationId']], Tags=list_tags)

    print("---------------------------EIPs------------------------------")
    for eip_dict in addresses_dict['Addresses']:
        print("EIP AllocationId: ", eip_dict["AllocationId"], " EIP Tags: ", eip_dict["Tags"])
        print("")
    print("-------------------------------------------------------------")


def tag_eks():
    print("Tagging EKS")
    eks_client = boto3.client('eks')
    eks_cluster_list = eks_client.list_clusters()

    for cluster in eks_cluster_list['clusters']:
        cluster_description = eks_client.describe_cluster(name=cluster)
        eks_client.tag_resource(resourceArn=cluster_description['cluster']['arn'], tags=dict_tags)


    print("------------------------------Tagging EKS----------------------------")
    eks_cluster_list = eks_client.list_clusters()
    for cluster in eks_cluster_list['clusters']:
        cluster_description = eks_client.describe_cluster(name=cluster)
        print("EKS Cluster arn:", cluster_description['cluster']['arn'],  " Tags: ", cluster_description['cluster']['tags'])
        print("")
    print("---------------------------------------------------------------------")


def tag_cloudwatch():
    print("Tagging CloudWatch. Alarms and Insight rules are the only components that supports tagging")
    cloudwatch_client = boto3.client('cloudwatch')
    cloudwatch_metric_alarms = cloudwatch_client.describe_alarms(AlarmTypes=['MetricAlarm'])
    cloudwatch_composite_alarms = cloudwatch_client.describe_alarms(AlarmTypes=['CompositeAlarm'])

    print("------------------------------Tagging Cloudwatch Metric Alarms if any----------------------------")
    metric_alarm_count = len(cloudwatch_metric_alarms['MetricAlarms'])
    i=0
    while i < metric_alarm_count:
       cloudwatch_client.tag_resource(ResourceARN=cloudwatch_metric_alarms['MetricAlarms'][i]['AlarmArn'], Tags=list_tags)
       metric_tags= cloudwatch_client.list_tags_for_resource(ResourceARN=cloudwatch_metric_alarms['MetricAlarms'][i]['AlarmArn'])
       print("Matric AlarmArn:", cloudwatch_metric_alarms['MetricAlarms'][i]['AlarmArn'],  " Tags: ", metric_tags['Tags'])
       i += 1
    print("-------------------------------------------------------------------------------------------------")

    print("")

    print("------------------------------Tagging Cloudwatch Composite Alarms if any----------------------------")
    print(cloudwatch_composite_alarms)
    composite_alarm_count = len(cloudwatch_composite_alarms['CompositeAlarms'])
    print(composite_alarm_count)
    ii=0
    while ii < composite_alarm_count:
       cloudwatch_client.tag_resource(ResourceARN=cloudwatch_composite_alarms['CompositeAlarms'][ii]['AlarmArn'], Tags=list_tags)
       composite_alarm_tags= cloudwatch_client.list_tags_for_resource(ResourceARN=cloudwatch_composite_alarms['CompositeAlarms'][ii]['AlarmArn'])
       #print(metric_tags['Tags'])
       print("Composite AlarmArn:", cloudwatch_composite_alarms['CompositeAlarms'][ii]['AlarmArn'],  " Tags: ", composite_alarm_tags['Tags'])
       ii += 1
    print("-------------------------------------------------------------------------------------------------")
    

def handler(event, context):

    # MAIN
    tag_ec2()
    print("")
    tag_ebs()
    print("")
    tag_elb()
    print("")
    tag_rds()
    print("")
    tag_natGW()
    print("")
    tag_eip()
    print("")
    tag_eks()
    print("")
    tag_cloudwatch()
    print("DONE!")