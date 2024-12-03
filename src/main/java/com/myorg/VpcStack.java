package com.myorg;

import software.amazon.awscdk.CfnOutput;
import software.amazon.awscdk.Stack;
import software.amazon.awscdk.StackProps;
import software.amazon.awscdk.services.ec2.CfnEIP;
import software.amazon.awscdk.services.ec2.CfnNatGateway;
import software.amazon.awscdk.services.ec2.CfnSubnet;
import software.amazon.awscdk.services.ec2.Vpc;
import software.constructs.Construct;

public class VpcStack extends Stack {

    private Vpc vpc;

    public VpcStack(final Construct scope, final String id) {
        super(scope, id, null);
    }

    public VpcStack(final Construct scope, final String id, final StackProps props) {
        super(scope, id, props);

        vpc = Vpc.Builder.create(this, "Vpc01")
                .maxAzs(3)
                .natGateways(0)
                .build();

        CfnSubnet publicSubnet = (CfnSubnet) vpc.getPublicSubnets().get(0).getNode().getDefaultChild();

        CfnEIP eip = CfnEIP.Builder.create(this, "VpcElasticIP").build();

        CfnNatGateway natGateway = CfnNatGateway.Builder.create(this, "VpcNatGateway")
                .subnetId(publicSubnet.getRef())
                .allocationId(eip.getAttrAllocationId())
                .build();

        CfnOutput.Builder.create(this, "NatGatewayId")
                .value(natGateway.getAttrNatGatewayId())
                .exportName("NatGatewayId")
                .build();
    }

    public Vpc getVpc() {
        return vpc;
    }

}
