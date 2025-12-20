# RAG Knowledge Base Makefile

# Environment-specific configuration
ENV ?= local
CONFIG_FILE := config/config.$(ENV).env
include $(CONFIG_FILE)

# Configuration
TEMPLATE_FILE := template.yaml
LAMBDA_ZIP := bedrock_function.zip
BUILD_DIR := build

# AWS Profile Configuration
# Usage: make deploy AWS_PROFILE=myprofile
# Or set default: make deploy (uses default profile)
AWS_CLI_PROFILE := $(if $(AWS_PROFILE),--profile $(AWS_PROFILE),)

## Deploy everything (initial deployment)
all: clean check-aws validate deploy knowledge-base-sync build update-function status api-endpoint
	@echo "Complete deployment finished"

## Clean build artifacts
clean:
	@echo "Cleaning build artifacts"
	@rm -rf $(BUILD_DIR) $(LAMBDA_ZIP) response.json
	@echo "Clean complete"

## Check AWS CLI and credentials
check-aws:
	@echo "Checking AWS CLI and credentials for profile: $(AWS_PROFILE)"
	@command -v aws >/dev/null 2>&1 || { echo "AWS CLI is not installed"; exit 1; }
	@aws sts get-caller-identity $(AWS_CLI_PROFILE) >/dev/null 2>&1 || { echo "AWS credentials not configured for profile: $(AWS_PROFILE)"; exit 1; }
	@echo "AWS CLI and credentials OK for profile: $(AWS_PROFILE)"

## Validate CloudFormation template
validate:
	@echo "Validating CloudFormation template"
	@aws cloudformation validate-template \
		--template-body file://$(TEMPLATE_FILE) \
		--region $(REGION) \
		$(AWS_CLI_PROFILE) > /dev/null
	@echo "Template validation passed"

## Deploy CloudFormation stack
deploy:
	@echo "Deploying CloudFormation stack"
	@aws cloudformation deploy \
		--template-file $(TEMPLATE_FILE) \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
		--parameter-overrides \
			StackName=$(STACK_NAME) \
			Environment=$(ENV) \
			Application=$(APPLICATION) \
			Owner=$(OWNER) \
			BucketName=$(BUCKET_NAME) \
			IndexName=$(INDEX_NAME) \
			LogLevel=$(LOG_LEVEL) \
			BedrockOpenSearchModel=$(BEDROCK_OPENSEARCH_MODEL) \
			BedrockKnowledgeBaseModel=$(BEDROCK_KNOWLEDGE_BASE_MODEL) \
			OpenSearchInstanceCount=$(OPEN_SEARCH_INSTANCE_COUNT) \
			OpenSearchInstanceType=$(OPEN_SEARCH_INSTANCE_TYPE) \
			OpenSearchZoneAwarenessEnabled=$(OPEN_SEARCH_ZONE_AWARENESS_ENABLED) \
			OpenSearchMultiAZWithStandbyEnabled=$(OPEN_SEARCH_MULTI_AZ_WITH_STANDBY_ENABLED) \
			OpenSearchAvailabilityZoneCount=$(OPEN_SEARCH_AVAILABILITY_ZONE_COUNT) \
			OpenSearchEBSEnabled=$(OPEN_SEARCH_EBS_ENABLED) \
			OpenSearchEBSVolumeType=$(OPEN_SEARCH_EBS_VOLUME_TYPE) \
			OpenSearchEBSVolumeSize=$(OPEN_SEARCH_EBS_VOLUME_SIZE) \
			OpenSearchEBSIops=$(OPEN_SEARCH_EBS_IOPS) \
			OpenSearchEBSThroughput=$(OPEN_SEARCH_EBS_THROUGHPUT) \
			ChatBotRole=$(CHAT_BOT_ROLE) \
			ChatBotObjective=$(CHAT_BOT_OBJECTIVE) \
			ChatBotTone=$(CHAT_BOT_TONE) \
			ChatBotBehaviorRules=$(CHATBOT_BEHAVIOR_RULES) \
			DocsBaseUrl=$(DOCS_BASE_URL) \
			AuthorizationEnabled=$(AUTHORIZATION_ENABLED) \
			UserPoolId=$(USER_POOL_ID) \
			UserPoolClientId=$(USER_POOL_CLIENT_ID) \
		$(AWS_CLI_PROFILE) >/dev/null 2>&1
	@echo "Stack deployment complete"

## Sync Knowledge Base documents to OpenSearch
knowledge-base-sync:
	@echo "Fetching Knowledge Base ID and Data Source ID"
	$(eval KNOWLEDGE_BASE_ID := $(shell aws cloudformation describe-stacks \
  		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		--query "Stacks[0].Outputs[?OutputKey=='KnowledgeBaseId'].OutputValue" \
		--output text \
		$(AWS_CLI_PROFILE)))
	$(eval DATA_SOURCE_ID := $(shell aws cloudformation describe-stacks \
  		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		--query "Stacks[0].Outputs[?OutputKey=='DataSourceId'].OutputValue" \
		--output text \
		$(AWS_CLI_PROFILE) | cut -d'|' -f2))

	@echo "Starting Knowledge Base sync..."
	$(eval JOB_ID := $(shell aws bedrock-agent start-ingestion-job \
		--knowledge-base-id $(KNOWLEDGE_BASE_ID) \
		--data-source-id $(DATA_SOURCE_ID) \
		--region $(REGION) \
		--query 'ingestionJob.ingestionJobId' \
		--output text \
		$(AWS_CLI_PROFILE)))
	@while true; do \
		JOB_STATUS=$$(aws bedrock-agent get-ingestion-job \
			--knowledge-base-id $(KNOWLEDGE_BASE_ID) \
			--data-source-id $(DATA_SOURCE_ID) \
			--ingestion-job-id $(JOB_ID) \
			--region $(REGION) \
			--query 'ingestionJob.status' \
			--output text \
			$(AWS_CLI_PROFILE)); \
		if [ "$$JOB_STATUS" = "COMPLETE" ]; then \
			break; \
		fi; \
		if [ "$$JOB_STATUS" = "FAILED" ]; then \
			echo "ERROR: Knowledge Base sync failed!"; \
			break; \
		fi; \
		sleep 5; \
	done
	@echo "Knowledge Base sync completed"

## Build function code and dependencies
build:
	@echo "Building Lambda function package..."
	@mkdir -p $(BUILD_DIR)
	@zip -j $(BUILD_DIR)/$(LAMBDA_ZIP) functions/bedrock_function.py
	@echo "Build complete. Deployment package: $(BUILD_DIR)/$(LAMBDA_ZIP)"

## Update Lambda function code directly
update-function:
	@echo "Fetching Bedrock Function ARN"
	$(eval FUNCTION_ARN := $(shell aws cloudformation describe-stacks \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		--query 'Stacks[0].Outputs[?OutputKey==`BedrockFunctionArn`].OutputValue' \
		--output text \
		$(AWS_CLI_PROFILE)))
	@echo "Updating Lambda function code"
	
	@aws lambda update-function-code \
		--function-name $(FUNCTION_ARN) \
		--zip-file fileb://$(BUILD_DIR)/$(LAMBDA_ZIP) \
		--region $(REGION) \
		$(AWS_CLI_PROFILE) >/dev/null 2>&1
	@echo "Lambda function code updated"

## Show stack status
status:
	@echo "Stack status"
	@aws cloudformation describe-stacks \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		--query 'Stacks[0].StackStatus' \
		--output text \
		$(AWS_CLI_PROFILE)

## Show API endpoint
api-endpoint:
	@echo "API endpoint"
	@aws cloudformation describe-stacks \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		--query 'Stacks[0].Outputs[?OutputKey==`BedrockApiEndpoint`].OutputValue' \
		--output text \
		$(AWS_CLI_PROFILE)

