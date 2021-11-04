# ece_deployment_dashboard
Extract deployment data from ECE and load it into Kibana for analysis and dashboarding

## SETUP
jq is required to convert newlines and whitespaces for the extracted json paylod to single line for the ES _bulk api.
Download it here. https://stedolan.github.io/jq/

Edit variables below and run script.

Use the logging and monitoring cluster within ECE for access to even more interesting data.


```
##ECE##
#Generate an ECE API Key and put it here, https://www.elastic.co/guide/en/cloud-enterprise/current/ece-restful-api-authentication.html
api_key=MzBzVTVud0JoX1RYRnZpb1pveHQ6ZlF5X3NERjZSbzJlNW0xYjBNRWNidw

#IP:PORT for an ECE management node
ece_management_ip_port=172.31.87.74:12400

##TARGET CLUSTER TO STORE RESULTS##
#ADDRESS/IP:PORT
target_cluster=http://03658eed83a144219eca839e72061874.34.227.22.102.ip.es.io:9200

#User and password for target cluster
user_pass=elastic:STlruuveDtVvQhHFewwAJmw2

##Index name where you want to store results
index_name=cluster_details

##START
#load all unique cluster ID's into an array
cluster_ids=(`curl -XGET http://${ece_management_ip_port}/api/v1/deployments -H "Authorization: ApiKey ${api_key}" 2>/dev/null | grep -B1 -e '"name" : "' | grep '"id"' | cut -c 15- | cut -c -32`)


echo ""
echo "Extract ECE Metadata and convert for ES bulk load..."
#create bulk load file
idx_meta="{\"index\" : { \"_index\" : \"$index_name\" } }"
for i in "${cluster_ids[@]}"
do
   : 
   echo ""
   echo $idx_meta
   curl -XGET http://${ece_management_ip_port}/api/v1/deployments/$i/apm/main-apm -H "Authorization: ApiKey ${api_key}" 2>/dev/null
   echo ""
   echo $idx_meta
   curl -XGET http://${ece_management_ip_port}/api/v1/deployments/$i/appsearch/main-appsearch -H "Authorization: ApiKey ${api_key}" 2>/dev/null
   echo ""
   echo $idx_meta
   curl -XGET http://${ece_management_ip_port}/api/v1/deployments/$i/elasticsearch/main-elasticsearch -H "Authorization: ApiKey ${api_key}" 2>/dev/null
   echo ""
   echo $idx_meta
   curl -XGET http://${ece_management_ip_port}/api/v1/deployments/$i/enterprise_search/main-enterprise_search -H "Authorization: ApiKey ${api_key}" 2>/dev/null
   echo ""
   echo $idx_meta
   curl -XGET http://${ece_management_ip_port}/api/v1/deployments/$i/kibana/main-kibana -H "Authorization: ApiKey ${api_key}" 2>/dev/null

done >> bulk_load.json

./jq-linux64 -c . bulk_load.json >> bulk_load.json2

echo ""
echo "...done"
echo ""

echo "Delete and re-create index..."
#delete prior index
curl --user $user_pass -X DELETE "$target_cluster/$index_name" 2>/dev/null

#create new index
curl --user $user_pass -X PUT "$target_cluster/$index_name" 2>/dev/null
echo ""
echo "...done"
echo ""

echo ""
echo "Data Load..."
#load data
curl --user $user_pass -s -H "Content-Type: application/x-ndjson" -XPOST $target_cluster/_bulk --data-binary "@bulk_load.json2"
echo ""
echo "...done"
echo ""

#wait for ES commit interval before trying to delete
sleep 5

echo ""
echo "Clean up..."
#cleanup
rm bulk_load.json2 2> /dev/null
rm bulk_load.json 2> /dev/null
#delete records with no resource found
curl --user $user_pass -s -H "Content-Type: application/x-ndjson" -XPOST $target_cluster/$index_name/_delete_by_query -d' { "query": { "match": { "errors.code.keyword": "deployments.deployment_resource_not_found" } } } '
echo ""
echo "...done"
echo ""
```
