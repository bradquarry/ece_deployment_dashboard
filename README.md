# Create ECE Deployment Dashboard
This script will read all of the deployed resources out of the Elastic Cloud Enterprise deployments API, format and bulk load the results into Elasticsearch, and then create a new field in each document called cluster_name_combined for aggregations across the different document types for each resource.

NOTE: This script is new as of Nov 4th 2021 and has only been tested in lab conditions for versions 1.0 to 2.12 of ECE

# Requirements
- An ECE environment
- jq (Download here: https://stedolan.github.io/jq/download/)
- A target Elasticsearch cluster to load data
- Linux

# Instructions
1. Install jq-linix64 in the same directory at the script
2. Copy the script locally and modify appropriate variables at the start of the script
3. If you encounter errors or hangs while runnint the script re-check your variables
4. Create Kibana index patters for the index you created
5. When visualizating data use the common field cluster_name_combined

# Example dashboard you can create
You can do so much more than this, but a simple dashboard shows top clusters by ram used with a breakdown of ECE node types used along with version breakdown.

<img width="1642" alt="Screen Shot 2021-11-04 at 5 00 40 PM" src="https://user-images.githubusercontent.com/38725582/140419985-d9c6f9eb-6639-4c54-8db9-bd43792ce8ae.png">
