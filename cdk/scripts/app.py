#!/usr/bin/env python3

import os
import json
from aws_cdk import (
    aws_ec2 as ec2,
    core,
)

class Ec2MultiNodesStack(core.Stack):
    def __init__(self, scope: core.Construct, id: str, name: str, key_name: str, **kwargs):
        super().__init__(scope, id, **kwargs)

        cluster_name = 'dev-ec2-%s' % name

        # Instance type
        ec2_type = "t3.large"

        # Provide VPC
        vpc = ec2.Vpc(self,
            cluster_name,
            cidr="10.40.0.0/16",
            nat_gateways=0,
            subnet_configuration=[ec2.SubnetConfiguration(
                cidr_mask=26,
                name="Public",
                subnet_type=ec2.SubnetType.PUBLIC
            )]
        )

        # Configure Security Group
        sg = ec2.SecurityGroup(
                self,
                id="%s-sg" % cluster_name,
                vpc=vpc,
                security_group_name="%s-sg" % cluster_name
        )

        self.add_security_rules(sg)

        # We use the AWS official Ubuntu 18.04 LTS
        image = ec2.GenericLinuxImage({
            "ap-northeast-1": "ami-0ef85cf6e604e5650"
        })

        host_ips = []
        for i in range(1, 4):
            host = self.run_instance(ec2_type, i, image, cluster_name, key_name, sg, vpc)
            host_ips.append(host.instance_public_ip)
        host = self.run_instance(ec2_type, 4, image, cluster_name, key_name, sg, vpc, disk_size=200)
        host_ips.append(host.instance_public_ip)

        core.CfnOutput(self, "Output", value=json.dumps(host_ips))

    def add_security_rules(self, sg):
        sg.add_ingress_rule(
            peer=ec2.Peer.ipv4("10.40.0.0/16"),
            connection=ec2.Port.all_traffic()
        )
        sg.add_ingress_rule(peer=ec2.Peer.ipv4("0.0.0.0/0"), connection=ec2.Port.tcp(22))
        sg.add_ingress_rule(peer=ec2.Peer.ipv4("0.0.0.0/0"), connection=ec2.Port.tcp(80))
        sg.add_ingress_rule(peer=ec2.Peer.ipv4("0.0.0.0/0"), connection=ec2.Port.tcp(443))

    def run_instance(self, ec2_type, index, image, cluster_name, key_name, sg, vpc, disk_size=100):
        instance_name = "%s-%d" % (cluster_name, index)
        return ec2.Instance(self, instance_name,
                            instance_type=ec2.InstanceType(instance_type_identifier=ec2_type),
                            instance_name=instance_name,
                            machine_image=image,
                            vpc=vpc,
                            key_name=key_name,
                            vpc_subnets=ec2.SubnetSelection(subnet_type=ec2.SubnetType.PUBLIC),
                            private_ip_address="10.40.0.%d" % (index + 10),
                            security_group=sg,
                            block_devices=[
                                ec2.BlockDevice(device_name="/dev/sda1", volume=ec2.BlockDeviceVolume.ebs(disk_size))]
                            )

region='ap-northeast-1'

name = os.environ.get('NAME', '')
username = os.environ.get('USERNAME', os.environ.get('USER', 'N/A'))
key_name = os.environ.get('KEY_NAME', '')

if name == '':
    print("ERROR: Should provide NAME")
    exit(1)
if key_name == '':
    print("ERROR: Should provide KEY_NAME")
    exit(1)

app = core.App()

ec2_stack = Ec2MultiNodesStack(app, "dev-ec2-%s" % name, name, key_name, env=core.Environment(region=region))
core.Tag.add(ec2_stack, "owner", username)
core.Tag.add(ec2_stack, "clusterType", 'dev-ec2')

app.synth()