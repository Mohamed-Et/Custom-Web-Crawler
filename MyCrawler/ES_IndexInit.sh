ESHOST="http://13.89.217.152:8300"

#add storm to path
export STORM_HOME=/datadrive/Project/apache-storm-2.1.0
export PATH=$PATH:$STORM_HOME/bin

#delete topology local
storm kill local -w 1

#ESCREDENTIALS="-u elastic:passwordhere"

# deletes and recreates a status index with a bespoke schema

#curl $ESCREDENTIALS -s -XDELETE "$ESHOST/status/" >  /dev/null
curl --location --request DELETE "$ESHOST/status"

echo "Deleted status index"

# http://localhost:9200/status/_mapping/status?pretty

echo "Creating status index with mapping"

#curl $ESCREDENTIALS -s -XPUT $ESHOST/status -H 'Content-Type: application/json' -d '
curl --location --request PUT "$ESHOST/status" --header 'Content-Type: application/json' --data-raw '{
	"settings": {
		"index": {
			"number_of_shards": 10,
			"number_of_replicas": 1,
			"refresh_interval": "5s"
		}
	},
	"mappings": {
			"dynamic_templates": [{
				"metadata": {
					"path_match": "metadata.*",
					"match_mapping_type": "string",
					"mapping": {
						"type": "keyword"
					}
				}
			}],
			"_source": {
				"enabled": true
			},
			"properties": {
				"key": {
					"type": "keyword",
					"index": true
				},
				"nextFetchDate": {
					"type": "date",
					"format": "dateOptionalTime"
				},
				"status": {
					"type": "keyword"
				},
				"url": {
					"type": "keyword"
				}
			}
	}
}'

# deletes and recreates a status index with a bespoke schema

#curl $ESCREDENTIALS -s -XDELETE "$ESHOST/metrics*/" >  /dev/null
#curl -s --location --request DELETE "$ESHOST/metrics"
curl -s -XDELETE "$ESHOST/metrics*/" >  /dev/null


echo ""
echo "Deleted metrics index"

#curl $ESCREDENTIALS -s -XPUT $ESHOST/_ilm/policy/7d-deletion_policy -H 'Content-Type:application/json' -d '
#curl -s -XPUT $ESHOST/_ilm/policy/7d-deletion_policy -H 'Content-Type:application/json' -d '
#{
#    "policy": {
#       "phases": {
#           "delete": {
#               "min_age": "7d",
#               "actions": {
#                   "delete": {}
#               }
#           }
#       }
#  }
#}
#'

echo "Creating metrics index with mapping"

# http://localhost:9200/metrics/_mapping/status?pretty
#curl --location --request PUT "$ESHOST/metrics" --header 'Content-Type: application/json' --data-raw '
curl -s -XPOST $ESHOST/_template/storm-metrics-template -H 'Content-Type: application/json' -d '
{
  "index_patterns": "metrics",
  "settings": {
    "index": {
      "number_of_shards": 1,
      "refresh_interval": "30s"
    },
    "number_of_replicas": 1
  },
  "mappings": {
      "_source":         { "enabled": true },
      "properties": {
          "name": {
            "type": "keyword"
          },
          "stormId": {
            "type": "keyword"
          },
          "srcComponentId": {
            "type": "keyword"
          },
          "srcTaskId": {
            "type": "short"
          },
          "srcWorkerHost": {
            "type": "keyword"
          },
          "srcWorkerPort": {
            "type": "integer"
          },
          "timestamp": {
            "type": "date",
            "format": "dateOptionalTime"
          },
          "value": {
            "type": "double"
          }
      }
  }
}'

# deletes and recreates a doc index with a bespoke schema

#curl $ESCREDENTIALS -s -XDELETE "$ESHOST/content*/" >  /dev/null
#curl -s -XDELETE "$ESHOST/content*/" >  /dev/null
#curl -s -XDELETE "$ESHOST/content/" >  /dev/null
curl --location --request DELETE "$ESHOST/content/"

echo ""
echo "Deleted content index"

echo "Creating content index with mapping"

#curl $ESCREDENTIALS -s -XPUT $ESHOST/content -H 'Content-Type: application/json' -d '
#curl -s -XPUT $ESHOST/content -H 'Content-Type: application/json' -d '
curl --location --request PUT "$ESHOST/content/" --header 'Content-Type: application/json' --data-raw '
{
	"settings": {
		"index": {
			"number_of_shards": 5,
			"number_of_replicas": 1,
			"refresh_interval": "60s"
		}
	},
	"mappings": {
			"_source": {
				"enabled": true
			},
			"properties": {
				"content": {
					"type": "text",
					"index": "true"
				},
				"host": {
					"type": "keyword",
					"index": "true",
					"store": true
				},
				"title": {
					"type": "text",
					"index": "true",
					"store": true
				},
				"descriptionEntreprise": {
              				"type": "text",
              				"index": "true",
              				"store": true
      				},
				"profilRecherche": {
              				"type": "text",
              				"index": "true",
              				"store": true
      				},
				"descriptionPoste": {
              				"type": "text",
              				"index": "true",
              				"store": true
      				},
				"all": {
              				"type": "text",
              				"index": "true",
              				"store": true
      				},
				"url": {
					"type": "keyword",
					"index": "false",
					"store": true
				}
			}
	}
}'

mvn clean package

storm jar target/crawler-1.0-SNAPSHOT.jar  org.apache.storm.flux.Flux --remote es-crawler.flux

