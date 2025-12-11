# Monitoring & Observability Documentation

## Overview

The system implements detailed logging across all components with dedicated CloudWatch Log Groups for comprehensive monitoring and troubleshooting.

## CloudWatch Log Groups

### `/aws/lambda/{StackName}-bedrock-function`
**Purpose**: Main chat API Lambda function monitoring

**Log Content**:
- Request validation and parsing
- Bedrock API calls and responses
- Citation processing and URL generation
- Error handling and debugging information
- Performance metrics (message length, response times)

### `/aws/lambda/{StackName}-index-creator`
**Purpose**: OpenSearch index creation Lambda monitoring

**Log Content**:
- Index creation success/failure status
- OpenSearch API interactions
- Custom Resource lifecycle events
- Index configuration validation

### `/aws/opensearch/{StackName}`
**Purpose**: OpenSearch domain operations monitoring

**Log Content**:
- Query performance analysis
- Indexing operation monitoring
- General OpenSearch application events
- Cluster health status

### `/aws/bedrock/{StackName}`
**Purpose**: Bedrock Knowledge Base operations monitoring

**Log Content**:
- Document ingestion and processing
- Embedding generation operations
- Knowledge base sync activities
- Model invocation logs
