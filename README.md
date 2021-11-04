# What is this and how does it help me?
This script will read from the ECE Deployments API and capture all the deployment details for every unique cluster, convert the output to bulk load into Elasticsearch, and load it into a server of your choosing. This allows for extremely robust reporting on all the clusters a customer has in ECE.

#Requirements
- An ECE environment
- jq (Download here: https://stedolan.github.io/jq/download/)
- A target Elasticsearch cluster to load data to
- Linux

#Setup
- Install jq
- Copy the script locally and modify appropriate source and target variables
