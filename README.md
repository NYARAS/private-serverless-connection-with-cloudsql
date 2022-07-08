# How to create a private Serverless connection with CloudSQL

By default, services are connected to each other via public IPs. In most cases, it’s advised to use private IPs instead. Private IP addresses let devices connect within the same network, without the need to connect to the public internet. This offers an additional layer of protection, making it more difficult for an external host or user to establish a connection.

## The problem
The Private IP access pattern has been build with Infrastructure as a Service (IaaS) in mind (i.e. virtual machines, VPC, etc). This means that this isn’t so straightforward to implement if you’re using Serverless services.

Examples of Serverless compute services within Google Cloud are:

- App Engine Standard Environment
- Cloud Functions
- Cloud Run

## The solution
To solve this problem, Google released a network component that is called Serverless VPC Access. This connector makes it possible for you to connect directly to your VPC network from Serverless environments.

We are using the Serverless VPC Access Connector to create a connection to a CloudSQL database via Private IP. Note that this is not limited to CloudSQL only. Once you have setup the Serverless VPC Access Connector, it is possible to connect to any resources that are available within your VPC.

In this doc, I’ll guide you using step by step procedures in setting this up for Google App Engine Standard Environment.

## Prerequisites:
* Authenticated [Google Cloud SDK](https://cloud.google.com/sdk/docs/install), alternatively Cloud Shell.
* Enough GCP permissions to create networks and perform deployments.

## Step 1: Create an VPC with networks
For the purpose of article, I’m going to create a new VPC with a subnet in europe-west1.
Please note that this is not required since you can also reuse your own VPC or the Google Provided Default VPC.

```
gcloud compute networks create private-cloud-sql \
--subnet-mode custom
```

In Google Cloud, a VPC is global, but we still need to create subnets to deploy resources in the different Cloud region.

This command creates an subnet in the VPC we created earlier for europe-west1:

```
gcloud compute networks subnets create private-europe-west1 \
--description=europe-west1\ subnet \
--range=192.168.1.0/24 \
--network=private-cloud-sql \
--region=europe-west1
```

## Step 2: Create a Serverless VPC Access Connector
After we’ve created a VPC with a subnet, we can continue by creating a Serverless VPC Access Connector. We can use the following GCloud command to do this.

```
gcloud compute networks vpc-access connectors create connector-europe-west1 \
  --network=private-cloud-sql \
  --region=europe-west1 \
  --range=10.8.0.0/28
```

Note: This command uses some defaults for the number of instances as well as the instance type. Since this could limit your network throughput between your VPC and the Serverless products, it’s recommended to [override these properties](https://cloud.google.com/sdk/gcloud/reference/compute/networks/vpc-access/connectors/create).

## Step 3: Setup Private Access Connection
The CloudSQL instances are deployed in a VPC that Google Manages. To use Cloud SQL instances via private IP in your VPC, we need to setup a VPC peering connection with the ‘servicenetworking’ network.

If this is the first time you interact with service networking, you have to enable the API via:

```
gcloud services enable servicenetworking.googleapis.com
```

To setup a VPC Peering connection, we first need to reserve an IP range that can be used. We can do this by executing the following command:

```
gcloud compute addresses create google-managed-services-private-cloud-sql \
--global \
--purpose=VPC_PEERING \
--prefix-length=16 \
--network=private-cloud-sql
```

This sets up an auto-generated IP address range based on a prefix, it’s also possible to [specify the range yourself](https://cloud.google.com/sdk/gcloud/reference/compute/addresses/create#ADDRESS).

Now that we have an IP range, we can use this to setup a VPC peering connecting with the ‘service networking’ project:

```
gcloud services vpc-peerings connect \
--service=servicenetworking.googleapis.com \
--ranges=google-managed-services-private-cloud-sql \
--network=private-cloud-sql
```
Note: This step is specifically for connecting with Cloud SQL over private IP. It can be skipped if you are not connecting with CloudSQL.

## Step 4: Create a Cloud SQL Instance
Now that we created the necessary network infrastructure, we are ready to create a CloudSQL Database instance.

Using this command, we create a new PostgreSQL database with private ip, in the VPC network we provisioned earlier. In this example, I’ve used ‘secretpassword’ as the root password. For production workloads, I’d recommend using [Google Secret Manager ](https://cloud.google.com/secret-manager) or [IAM authentication](https://cloud.google.com/sql/docs/postgres/authentication).

```
gcloud beta sql instances create private-postgres \
--region=europe-west1 \
--root-password=secretpassword \
--database-version=POSTGRES_13 \
--no-assign-ip \
--network=private-cloud-sql \
--cpu=2 \
--memory=4GB \
--async
```
This operation takes a few minutes. After that, a database can be created in the newly provisioned CloudSQL instance.

```
gcloud sql databases create test --instance private-postgres
```

## Step 5: Configure your App Engine Application
Now that we created the correct networking configuration and the (PostgreSQL) Database has been created, it’s time to update the configuration of our App Engine application.

To update the configuration of an App Engine Application, we need to change the app.yaml file. This file is located in the root of the project.

The result could look as follows (don’t forget to replace the values for the VPC connector and the database):

```yaml
runtime: nodejs16

vpc_access_connector:
# Format: projects/YOUR_PROJECT_NAME/locations/YOUR_REGION/connectors/YOUR_VPC_CONNECTOR_NAME
 name: # FILL_IN_YOUR_CONNECTOR_NAME
 egress_setting: all-traffic

env_variables:
  PGHOST: # FILL_IN_YOUR_CLOUD_SQL_PRIVATE_IP
  PGUSER: postgres
  PGDATABASE: # FILL_IN_YOUR_DB_NAME
  PGPASSWORD: # FILL_IN_YOUR_PASSWORD
  PGPORT: 5432

```
