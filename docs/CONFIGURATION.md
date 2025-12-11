# Configuration Documentation

## Configuration-Driven Design

### Configuration File Structure

```
config/
├── config.example.env
├── config.local.env
├── config.dev.env
├── config.staging.env
└── config.prod.env
```

### How Configuration Works

1. **Copy the template**: `cp config/config.example.env config/config.<env>.env`
2. **Customize parameters**: Edit your environment-specific config file
3. **Deploy with config**: `make all ENV=<env>` automatically loads the config
4. **No code changes needed**: All customization happens through configuration

## Configuration Parameters

Configure your deployment by editing `config/config.<env>.env`. Here's what each parameter does:

### AWS Environment
- **REGION**: AWS region where resources will be deployed
- **AWS_PROFILE**: AWS CLI profile to use for deployment
- **STACK_NAME**: CloudFormation stack name (must be unique)
- **DOCS_BASE_URL**: Public URL where your documents are hosted

### OpenSearch Configuration

#### Basic Settings
- **OPEN_SEARCH_INSTANCE_COUNT**: Number of OpenSearch instances
  - Must be 1 for single-AZ deployments
  - Must be ≥2 for multi-AZ deployments (validation enforced)
- **OPEN_SEARCH_INSTANCE_TYPE**: Instance type

#### Multi-AZ Settings (Choose One Setup)

**Setup 1: Single-AZ**
```env
OPEN_SEARCH_ZONE_AWARENESS_ENABLED=false
OPEN_SEARCH_MULTI_AZ_WITH_STANDBY_ENABLED=false
OPEN_SEARCH_INSTANCE_COUNT=1
```
- Single instance in one AZ
- Lowest cost option
- Good for development/testing
- Risk: No fault tolerance

**Setup 2: Multi-AZ**
```env
OPEN_SEARCH_ZONE_AWARENESS_ENABLED=true
OPEN_SEARCH_MULTI_AZ_WITH_STANDBY_ENABLED=false
OPEN_SEARCH_AVAILABILITY_ZONE_COUNT=2
OPEN_SEARCH_INSTANCE_COUNT=2
```
- Instances distributed across multiple AZs
- Higher availability
- **Required**: Instance count must be ≥2 when Multi-AZ enabled

**Setup 3: Multi-AZ with Standby (High Availability)**
```env
OPEN_SEARCH_ZONE_AWARENESS_ENABLED=true
OPEN_SEARCH_MULTI_AZ_WITH_STANDBY_ENABLED=true
OPEN_SEARCH_AVAILABILITY_ZONE_COUNT=2
OPEN_SEARCH_INSTANCE_COUNT=2
```
- Active instances + standby instances
- Maximum reliability and fault tolerance
- Highest cost option

### EBS Storage Configuration
- **OPEN_SEARCH_EBS_ENABLED**: Use EBS (persistent) vs instance store (ephemeral)
- **OPEN_SEARCH_EBS_VOLUME_TYPE**: EBS volume type (gp3, gp2, io1, io2)
- **OPEN_SEARCH_EBS_VOLUME_SIZE**: Volume size in GB
- **OPEN_SEARCH_EBS_IOPS**: IOPS for gp3/io1/io2 volumes
- **OPEN_SEARCH_EBS_THROUGHPUT**: Throughput in MB/s for gp3 volumes

### Application Configuration
- **BUCKET_NAME**: S3 bucket for knowledge base documents
- **INDEX_NAME**: OpenSearch index name for vectors

### Bedrock Models
- **BEDROCK_OPENSEARCH_MODEL**: Embedding model for converting text to vectors
- **BEDROCK_KNOWLEDGE_BASE_MODEL**: Generation model for creating responses

### Chatbot Personality
- **CHAT_BOT_ROLE**: Role description (e.g., "Technical Documentation Assistant")
- **CHAT_BOT_OBJECTIVE**: Primary purpose (e.g., "Help developers understand API documentation")
- **CHAT_BOT_TONE**: Communication style (e.g., "Professional and concise")
- **CHATBOT_BEHAVIOR_RULES**: Behavioral constraints (e.g., "Always cite sources, admit when unsure")

## Configuration Examples

### Example 1: Development Environment
```env
# config/config.dev.env
REGION=us-east-1
AWS_PROFILE=dev-profile
STACK_NAME=mycompany-rag-dev
BUCKET_NAME=mycompany-docs
DOCS_BASE_URL=https://dev-docs.mycompany.com

# Minimal OpenSearch for cost savings
OPEN_SEARCH_INSTANCE_COUNT=1
OPEN_SEARCH_INSTANCE_TYPE=t3.small.search
OPEN_SEARCH_ZONE_AWARENESS_ENABLED=false
OPEN_SEARCH_EBS_VOLUME_SIZE=10

# Development chatbot personality
CHAT_BOT_ROLE="Development Documentation Assistant"
CHAT_BOT_TONE="Casual and helpful for internal team use"
```

### Example 2: Highly Available Environment
```env
# config/config.prod.env
REGION=us-west-2
AWS_PROFILE=prod-profile
STACK_NAME=mycompany-rag-prod
BUCKET_NAME=mycompany-docs
DOCS_BASE_URL=https://docs.mycompany.com

# High-availability OpenSearch
OPEN_SEARCH_INSTANCE_COUNT=3
OPEN_SEARCH_INSTANCE_TYPE=m6g.large.search
OPEN_SEARCH_ZONE_AWARENESS_ENABLED=true
OPEN_SEARCH_MULTI_AZ_WITH_STANDBY_ENABLED=true
OPEN_SEARCH_AVAILABILITY_ZONE_COUNT=3
OPEN_SEARCH_EBS_VOLUME_SIZE=100

# Professional chatbot personality
CHAT_BOT_ROLE="Customer Support Documentation Assistant"
CHAT_BOT_TONE="Professional and precise for customer-facing use"
```

### Example 3: Different Use Cases

**Legal Document Assistant:**
```env
CHAT_BOT_ROLE="Legal Document Research Assistant"
CHAT_BOT_OBJECTIVE="Help lawyers find relevant case law and legal precedents"
CHAT_BOT_TONE="Formal and precise with legal terminology"
CHATBOT_BEHAVIOR_RULES="Always cite specific documents and sections. Never provide legal advice, only reference existing documentation."
```

**Technical Support Bot:**
```env
CHAT_BOT_ROLE="Technical Support Knowledge Assistant"
CHAT_BOT_OBJECTIVE="Help support agents quickly find troubleshooting information"
CHAT_BOT_TONE="Clear and action-oriented for quick problem resolution"
CHATBOT_BEHAVIOR_RULES="Provide step-by-step solutions when available. Always include relevant documentation links."
```

## Configuration Validation

The system includes built-in validation to prevent common configuration errors:

- **Multi-AZ Validation**: Automatically checks that instance count ≥2 when multi-AZ is enabled
- **Template Validation**: `make validate` checks CloudFormation template syntax
- **AWS Credentials**: `make check-aws` verifies AWS CLI configuration
- **Parameter Consistency**: CloudFormation validates parameter combinations