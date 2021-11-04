# What is this and how does it help me?
This script will read from the ECE Deployments API and capture all the deployment details for every unique cluster, convert the output to bulk load into Elasticsearch, and load it into a server of your choosing. This allows for extremely robust reporting on all the clusters a customer has in ECE and is especially helpful when you have hundreds of clusters.

# Requirements
- An ECE environment
- jq (Download here: https://stedolan.github.io/jq/download/)
- A target Elasticsearch cluster to load data to
- Linux

# Setup
- Install jq
- Copy the script locally and modify appropriate source and target variables

# Example Result
You can do so much more than this, but a simple dashboard shows top clusters by ram used with a breakdown of ECE node types used along with version breakdown.

<img width="1642" alt="Screen Shot 2021-11-04 at 5 00 40 PM" src="https://user-images.githubusercontent.com/38725582/140419985-d9c6f9eb-6639-4c54-8db9-bd43792ce8ae.png">
