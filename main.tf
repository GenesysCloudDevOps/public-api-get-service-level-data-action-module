resource "genesyscloud_integration_action" "action" {
    name           = var.action_name
    category       = var.action_category
    integration_id = var.integration_id
    secure         = var.secure_data_action
    
    contract_input  = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "description" = "Service level for a specific queue.",
        "properties" = {
            "interval" = {
                "description" = "Interval",
                "type" = "string"
            },
            "mediaType" = {
                "description" = "Valid values: callback, chat, cobrowse, email, message, screenshare, voice",
                "enum" = [
                    "callback",
                    "chat",
                    "cobrowse",
                    "email",
                    "message",
                    "screenshare",
                    "voice"
                ],
                "type" = "string"
            },
            "queueId" = {
                "description" = "The queue ID.",
                "type" = "string"
            }
        },
        "required" = [
            "interval",
            "queueId",
            "mediaType"
        ],
        "title" = "Get Service Level",
        "type" = "object"
    })
    contract_output = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "properties" = {
            "denominator" = {
                "type" = "number"
            },
            "numerator" = {
                "type" = "number"
            },
            "ratio" = {
                "type" = "number"
            },
            "target" = {
                "type" = "number"
            }
        },
        "type" = "object"
    })
    
    config_request {
        request_template     = "{\"groupBy\":[\"queueId\"], \"interval\":\"$${input.interval}\", \"filter\": {\"type\":\"and\",\"predicates\": [{\"dimension\": \"queueId\",\"value\": \"$${input.queueId}\"}, {\"dimension\": \"mediaType\",\"value\": \"$${input.mediaType}\"}]}, \"metrics\": [\"oServiceLevel\"]}"
        request_type         = "POST"
        request_url_template = "/api/v2/analytics/conversations/aggregates/query"
        headers = {
			Content-Type = "application/json"
		}
    }

    config_response {
        success_template = "$${stats}"
        translation_map = { 
			stats = "$.results[0].data[0].metrics[0].stats"
		}
        translation_map_defaults = {       
			stats = "{}"
		}
    }
}