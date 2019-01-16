# main certification

Beginner cert:
[https://www.microsoft.com/en-us/learning/exam-az-100.aspx](https://www.microsoft.com/en-us/learning/exam-az-100.aspx)



# Create a free account:

[https://azure.microsoft.com/en-gb/](https://azure.microsoft.com/en-gb/)
[https://azure.microsoft.com/en-us/pricing/calculator/](https://azure.microsoft.com/en-us/pricing/calculator/)



## IAAS, PAAS, SAAS


### IIAS
               | IAAS | PAAS | SAAS |
---------------|--------------------------------------
Application    |      |      |  x   |
Data           |      |      |  x   |
Runtime        |      |  x   |  x   |
Middleware     |      |  x   |  x   |
OS             |      |  x   |  x   |
Virtualisation |  x   |  x   |  x   |
Servers        |  x   |  x   |  x   |
Storage        |  x   |  x   |  x   |
Networking     |  x   |  x   |  x   |



## Terminologies

### Subscription 

[https://blogs.msdn.microsoft.com/uk_faculty_connection/2017/03/22/comparing-azure-to-aws-a-quick-guide-to-the-key-differences/](https://blogs.msdn.microsoft.com/uk_faculty_connection/2017/03/22/comparing-azure-to-aws-a-quick-guide-to-the-key-differences/)


In AWS you have one AWS account, and all resources created inside that account, will be charged against that account's billing info.

In Azure, you're Azure account can house multiple subscriptions. Each Subscription has it's own billing info. 

A subscription can only be associated with only one Directory (aka Azure AD)

### Directory (aka Azure AD)

This is the Azure equivalent of AWS IAM. 

A Directory can be attached to multiple subscriptions. 

Can be extended on premise using the AD connect service. 


### Resource Group

This is a collecitions of objects that makes up a service. E.g. in AWS, that could be an ASG, ELB, instances, and rds instance. 

This makes it easier to do a housekeeping. E.g. decommision a service by deleting the corresponding resource group.

A Resource group is attached to a Subscription, this helps with billing and access permissions. 

You have to specify a resource group whenever you create a new resource , e..g virtual machine.

A resource must always be associated to exactly resource group. However you can change a resource's resource group. 


When you create a resource group, you need to specify a region. That's becuase resource group contains metadata that needs to be stored somewhere. 

A resource group is also linked to exactly one Subscription, this helps with billing. 


### Virtual Machine

same as EC2. 


### Azure Resource Manager

Same as AWS Cloudformation. The ARM templates are written in json. 

If you manually create a resoure, then you can still pull obtain the json file that was generated behind the scenes, by clicking on the deployment details, then selecting the 'deployment details' link. Then you'll download a zip file. This zip file contains code for performing the deployment in a number of ways including powershell script, and json ARM file. 


### Virtual Network

Same as AWS VPC. You can create a new network when creating a new virtual machine!!!

Like AWS VPCs, Virtual Networks have one or more 'subnets'.


### Network Security Group

Same as AWS Seecurity Groups. It can be applied to an interface, subnet, or both. 


### Azure storage blob

Same as AWS S3. 

Here are some terminologies

Hot storage = fast access storage

cold storage = slower access storage

archival storage = same as aws glacier = takes a number of days to retrieve, ideal for infrequently accessed. 

### Azure Marketplace

Similar to aws ami marketplace. 

[https://azuremarketplace.microsoft.com/en-us](https://azuremarketplace.microsoft.com/en-us)

### Azure App Services

A service for just running your apps and storing app data. 


### Regions and Availability Zones

Same as AWS Regions and Availability Zones

[https://azure.microsoft.com/en-us/global-infrastructure/services/?products=all&regions=non-regional,united-kingdom-south,united-kingdom-west,us-west](https://azure.microsoft.com/en-us/global-infrastructure/services/?products=all&regions=non-regional,united-kingdom-south,united-kingdom-west,us-west)


### Cloud init

Same as aws userdata

### Tags

Same as aws tags. However tags have it's very own page for reveiwing tags and filtering through them. 

### Locks

Same thing as AWS Termination protection

### Monitor

Looks like equivalent to aws cloudwatch. 


### Dashboards  

This is a bit like bookmarking various Azure pages/widgets (by clicking on the pin icons). Those pinned items gets attached to the currently active dashboard. Dashbaords are essentially folders for storring your pinned items, and lets you visually see them. 


# Availability Sets

This is a 







