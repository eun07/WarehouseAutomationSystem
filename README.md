# Build Warehouse Automation Management System 
![image](https://cdn.discordapp.com/attachments/898818056451665950/1022056580553900052/unknown.png)
# Overview
## Scenario
>Charile Donut store sell their products on the online website. Customer can buy the donut just one click on the website. If products are available on the inventory, stock decreases and customer can success to purchase. Famous Youtuber have uploaded Charile Donut advertisement video on youtube. Order has been increasing by advertisement. If stock is out on the warehouse, send supply request on the manufacturing factory(Legacy System). Request is accepted by factory, stock have been increased automatically few minutes later.
## Requirements
1. Customer can purchase the product with just one click. Stock would decrease. <br>

2. If products are out of stock, send request to manufacturing factory.<br>
3.  When the factory has accepted request for supply, stock have been increased few minutes later.<br>
4. If all products are out of stock, send email to advertisement team to stop advertising.
## Resource
### AWS
- Lambda, API Gateway, NAT Gateway, RDS(MYSQL), SQS, SNS, SES
### IaC
- Terraform
## Architecture
![image](https://cdn.discordapp.com/attachments/898818056451665950/1022057260215709766/Project3_Arch_Diagram.drawio.png)

<!-- ### Step 1: Data Production
***✔ API Gateway to Lambda***

When **Lambda** is triggered by **API Gateway** , **Lambda** put the data on the **Kinesis Data Stream** record that collected from sensor.
 

### Step 2: Data Pipeline
***✔ Kiensis Data Stream to Kiensis Firehose***

The data that is streaming on the **Kinesis Data Stream** send the streaming data to **Kinesis Firehose**. 
The data on the **Kinesis Firehose** arrived at the **Open Search Service** and **S3** for back up.

### Step 3: Storing on S3 to lambda

***✔ S3 to Lambda***
 
 When the data are stored at **S3** and if the speicific data value excceds the threshold,
  **Lambda** would send the discord webhook alarm.


### Step 4: Visualization
***✔ Firehose to Open Search Service & Open Search Dashboard***

Since the data is arrived at open search service from **Kinesis Firehose**, the new document is created on the open search index,
 which is mapping based on data field type. The mapping data on the **Open Search Service** can be visualized on the 
 **Open Search Dashboard**. -->

<br>

## Install Requirements
- AWS Root Account 
- AWS CLI Install and AWS Credintial Configure setting
- Git Install
- Terraform Install

## Deployment
1. Make and move the new directory. Git Clone Github Repository on the directory.
    ```
    git clone https://github.com/eun07/WarehouseAutomationSystem.git
    ```
2. Change Directory to terraform Dierctory.
    ```
    cd terraform
    ```
3. On the Command line, run it thorugh with a command such as :
    ```
    terraform init
    ```

4. On the command line, deploy on the AWS with a command such as :
   <br>
  It will take about 15 minutes to deploy on the AWS.
    ```
    terraform apply
    ```
5. When the Deployment is completed, you can see on the AWS Management Console.


## How it works
> If client clicks to buy donut on the endpoint, send request on the Lambda through API Gateway. Sales-Lambda sends request on the stock database. If the product is out of stock, SNS is published by sales-lambda. SQS got the messages from SNS and stock-lambda consumes messages on the SQS. Stock-lambda sends request to increase stock on legacy system with callback stock-increase-lambda. Legacy System calls stock-increase-lambda and labmda sends request on the stock database to increase. Finally, stock is updated automatically when product is out of stock.


## Clean up

On the terraform directory exeucte command such as : <br>
It will take about 5 mintues to clean up resource.
```
terraform destroy
```



## Architecture Resource 
<br>

**💡 Domain Driven**<br>
A domain-driven approach was used to design this architecture, which models the system using architecture viewpoints to cater to the requirements of client. In this architecture, there are three aggregators that are purchase, stock management, and advertisement. 

**💡 Domain Analysis**<br>

✔️**Purchase**

Customer can purchase the product on the sales API Gateway Endpoint. If they are in stock, sales API Lambda sends purchase request to database. If products are out of stock, sales API Lambda publishes message that contains supply request message on the SNS topic. 

✔️**Stock management**

If SNS topic has been published by Lambda, subscribers got the messages from SNS. For consuming messages, SQS will trigger stock Lambda. stock Lambda is function that calls Legacy Factory system with stock-increase Lambda Callback URL. 

Stock Lambda send request using HTTP API Method to Legacy Factory System with stock-increase-lambda API Gateway Endpoint. When stock-increase-lambda is called, stock-increase-lambda send supply request to database.

✔️**Advertisement**

The one of the subscriber also got the out of stock messages from SNS. Lambda is triggered by SQS, execute SES to send email to advertisement team.

**💡 Micro Service Architecture**
First, we need to handle amounts of traffic when orders are increasing. In addition, we don’t execute the code all-time. We just want to execute when the stock message is published. Therefore, we use AWS Lambda, which enables us handle amounts of traffic and can be executed on-demand method. 

Second, we need message queue system that store message safely until consuming. Thus, we use AWS SQS, which enables to store messages safely and decouple dependency of each system. <br>

Third, we need the notification system to send messages the other systems not just one system, so we use AWS SNS, which enables to fanout messages lots of subscriber.


## The purpose of Architecture
We have built this architecture based on Micro Service, also designed various AWS serverless resource on our architecture. In building AWS managed serverless resource, we can take some advantages that server management, handle amounts of traffic, attach new system easily, and prevent affection of failure.

