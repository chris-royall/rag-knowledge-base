# Deployment Documentation

## Prerequisites

- AWS CLI configured with appropriate permissions
- Make utility installed
- S3 bucket with your documents

## Quick Deployment

### 1. Configure Environment
```bash
cp config/config.example.env config/config.<env>.env
# Edit config.<env>.env with your settings
```

### 2. Deploy Stack
```bash
make all ENV=<env>
```

### 3. Get API Endpoint
```bash
make api-endpoint ENV=<env>
```

### 4. Manual Sync Required
⚠️ After deployment, you must manually sync your S3 documents to the Bedrock Knowledge Base using AWS Console or AWS CLI.

## Available Commands

```bash
# Complete deployment
make all ENV=<env>

# Individual operations
make clean                    # Clean build artifacts
make check-aws               # Verify AWS credentials
make validate                # Validate CloudFormation template
make deploy ENV=<env>        # Deploy infrastructure
make build                   # Build Lambda package
make update-function ENV=<env> # Update Lambda code only
make status ENV=<env>        # Show stack status
make api-endpoint ENV=<env>  # Display API endpoint URL
```

## Usage Examples

### Basic API Call
```bash
curl -X POST https://your-api-id.execute-api.region.amazonaws.com/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What is the main topic of the documentation?"}'
```

### Response Format
```json
{
  "answer": "Based on the documentation, the main topic is...",
  "urls": [
    "https://your-docs-site.com/document1",
    "https://your-docs-site.com/document2"
  ]
}
```

## Troubleshooting

### Common Issues

1. **Multi-AZ Validation Error**: Ensure instance count ≥2 when multi-AZ is enabled
2. **AWS Credentials**: Run `make check-aws` to verify configuration
3. **S3 Bucket**: Ensure bucket exists before deployment
4. **Manual Sync**: Documents won't be available until manual sync is performed

### Validation Commands

- `make validate` - Check CloudFormation template syntax
- `make check-aws` - Verify AWS CLI configuration
- `make status ENV=<env>` - Check deployment status