# Dynamic EC2 Scaling with SQS Backlog

This project implements a cost-efficient, automated scaling architecture on AWS using **Terraform**. It leverages an Amazon SQS queue as a buffer and dynamically adjusts the number of EC2 instances based on the volume of messages waiting to be processed.

## Architecture Overview

The system is designed to maintain **Zero Cost** when idle by scaling the infrastructure down to zero instances when the queue is empty.

* **SQS Queue**: Acts as the message broker for incoming tasks.
* **Auto Scaling Group (ASG)**: Manages a fleet of `t2.micro` instances.
* **CloudWatch Alarms**: Monitors the `ApproximateNumberOfMessagesVisible` metric.
* **Scaling Policies**: 
    * **Scale Out**: Adds 1 instance when the queue has > 10 messages.
    * **Scale In**: Removes 1 instance when the queue is empty (0 messages).

* **VPC & Networking**: A custom VPC with a public subnet, Internet Gateway, and Route Table for direct internet access.

##  Deployment

### Prerequisites
* Terraform installed.
* AWS CLI configured with valid credentials.

### Steps
1.  **Initialize Terraform**:
    ```bash
    terraform init
    ```
2.  **Review the execution plan**:
    ```bash
    terraform plan
    ```
3.  **Deploy the infrastructure**:
    ```bash
    terraform apply
    ```

## Testing the Scaling Logic

### 1. Simulate High Load (Scale Out)
To trigger the alarm and launch an EC2 instance, send more than 10 messages to the queue using PowerShell:

```powershell
$queueUrl = aws sqs get-queue-url --queue-name "app-processing-queue" --query "QueueUrl" --output text
1..15 | ForEach-Object {
    aws sqs send-message --queue-url $queueUrl --message-body "Test message $_"
}



Monitor Scaling Status

aws cloudwatch describe-alarms --alarm-names "high-sqs-backlog" --query "MetricAlarms[*].StateValue"


Check EC2 Instances

aws ec2 describe-instances `
    --filters "Name=instance-state-name,Values=running,pending" `
    --query "Reservations[*].Instances[*].{ID:InstanceId,Status:State.Name}"

Verify Auto Scaling Group Capacity

aws autoscaling describe-auto-scaling-groups `
    --auto-scaling-group-names "app-asg" `
    --query "AutoScalingGroups[0].{Nome:AutoScalingGroupName, Desejada:DesiredCapacity, Min:MinSize, Max:MaxSize, Instancias:Instances[].InstanceId}" `
    --output table
	
	
Scaling Group Activities

aws autoscaling describe-scaling-activities `
    --auto-scaling-group-name "app-asg" `
    --query "Activities[*].{Time:StartTime, Status:StatusCode, Cause:Cause}" `
    --output table
	
Check Scaling Policies History
	
aws autoscaling describe-policies `
    --auto-scaling-group-name "app-asg" `
    --query "ScalingPolicies[*].{Nome:PolicyName, Ajuste:ScalingAdjustment, Tipo:AdjustmentType}" `
    --output table
	
	
Check Alarm State

aws  cloudwatch describe-alarms `
    --alarm-names "high-sqs-backlog" `
    --query "MetricAlarms[*].{Name:AlarmName, State:StateValue, Reason:StateReason}"
	
	
Purge Queue (Clear Messages)

aws sqs purge-queue --queue-url $queueUrl
	
Verify Message Count

aws sqs get-queue-attributes `
    --queue-url $queueUrl `
    --attribute-names ApproximateNumberOfMessages