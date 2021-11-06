
##########EDIT THESE VARIABLES############

##ECE##
#Generate an ECE API Key and put it here, https://www.elastic.co/guide/en/cloud-enterprise/current/ece-restful-api-authentication.html
api_key=M2N6UjlYd0J3WXl2WkJ4bmo0SHU6bThSTXIwazVSSG05QnJCVkY4XzJmUQ==

#IP:PORT for an ECE management node
ece_management_ip_port=172.31.94.62:12400

##TARGET CLUSTER TO STORE RESULTS##
#ADDRESS/IP:PORT, example https://ece-deployment-dashboard.es.us-central1.gcp.cloud.es.io:9243
target_cluster=https://ece-deployment-dashboard.es.us-central1.gcp.cloud.es.io:9243

#User and password for target cluster
user_pass=elastic:6gkkDMG3YJuGB2IRxfXLTWoz

##Index name where you want to store results
index_name=cluster_details

##########STOP EDITING HERE############

#just in case script exited early...
echo ""
echo "Clean up..."
#cleanup
rm bulk_load.json2 2> /dev/null
rm bulk_load.json 2> /dev/null

echo ""
echo "...done"
echo ""

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
   echo ""
   echo $idx_meta
   curl -XGET http://${ece_management_ip_port}/api/v1/deployments/$i/apm/apm -H "Authorization: ApiKey ${api_key}" 2>/dev/null
   echo ""
   echo $idx_meta
   curl -XGET http://${ece_management_ip_port}/api/v1/deployments/$i/appsearch/appsearch -H "Authorization: ApiKey ${api_key}" 2>/dev/null
   echo ""
   echo $idx_meta
   curl -XGET http://${ece_management_ip_port}/api/v1/deployments/$i/elasticsearch/elasticsearch -H "Authorization: ApiKey ${api_key}" 2>/dev/null
   echo ""
   echo $idx_meta
   curl -XGET http://${ece_management_ip_port}/api/v1/deployments/$i/enterprise_search/enterprise_search -H "Authorization: ApiKey ${api_key}" 2>/dev/null
   echo ""
   echo $idx_meta
   curl -XGET http://${ece_management_ip_port}/api/v1/deployments/$i/kibana/kibana -H "Authorization: ApiKey ${api_key}" 2>/dev/null


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

echo ""
echo "Waiting 5 seconds for Elasticsearch commit interval before trying to delete or update..."
sleep 5
echo ""
echo "...done"
echo ""


echo ""
echo "Remove resources that were not found..."
#Remove resources not foud
curl --user $user_pass -H "Content-Type: application/x-ndjson" -XPOST "$target_cluster/$index_name/_delete_by_query" -d' 
{ "query": 
        { "match": { "errors.code.keyword": "deployments.deployment_resource_not_found"} 
        } 
}'
echo ""
echo "...done"
echo ""

echo ""
echo "Waiting 5 seconds for Elasticsearch commit interval before trying to delete or update..."
sleep 5
echo ""
echo "...done"
echo ""


echo ""
echo "Add common cluster name field to different document types pass 1..."
curl --user $user_pass -H "Content-Type: application/x-ndjson" -XPOST "$target_cluster/$index_name/_update_by_query" -d' 
{
 "query": {
   "match_all": {}
 }
,
 "script": {
  "lang": "painless",
   "source": "if (ctx._source.info.cluster_name != null ) { ctx._source.cluster_name_combined = ctx._source.info.cluster_name;}"
  }
}'

echo ""
echo "Waiting 5 seconds for Elasticsearch commit interval before trying to delete or update..."
sleep 5
echo ""
echo "...done"
echo ""

echo ""
echo "Add common cluster name field to different document types pass 2"
curl --user $user_pass -H "Content-Type: application/x-ndjson" -XPOST "$target_cluster/$index_name/_update_by_query" -d' 
{
 "query": {
   "match_all": {}
 }
,
 "script": {
  "lang": "painless",
   "source": "if (ctx._source.info.name != null ) { ctx._source.cluster_name_combined = ctx._source.info.name;}"
  }
}'

echo ""
echo "...done"
echo ""


echo ""
echo "Clean up..."
#cleanup
rm bulk_load.json2 2> /dev/null
rm bulk_load.json 2> /dev/null

echo ""
echo "...done"
echo ""
