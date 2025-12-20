# Deployment Documentation

## Prerequisites

- AWS CLI configured with appropriate permissions
- Make utility installed
- S3 bucket with your documents
- Cognito User Pool and App Client (if enabling authorization)

## Quick Deployment

```bash
make all ENV=<env>
```

## Available Commands

```bash
# Complete deployment
make all ENV=<env>

# Individual operations
make clean                      # Clean build artifacts
make check-aws                  # Verify AWS credentials
make validate                   # Validate CloudFormation template
make deploy ENV=<env>           # Deploy infrastructure
make knowledge-base-sync        # Sync Knowledge Base
make build                      # Build Lambda package
make update-function ENV=<env>  # Update Lambda code only
make status ENV=<env>           # Show stack status
make api-endpoint ENV=<env>     # Display API endpoint URL
```

## Usage Examples

### API Call with Cognito Authorization
```bash
curl -X POST https://your-api-id.execute-api.region.amazonaws.com/chat \
  -H 'Authorization: Bearer <ACCESS_TOKEN>' \
  -H "Content-Type: application/json" \
  -d '{"message": "What is the main topic of the documentation?"}'
```

### API Call without Authorization
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
5. **Authorization Issues**: Ensure Cognito User Pool and App Client exist before deployment and verify `USER_POOL_ID` and `USER_POOL_CLIENT_ID` are correct

### Validation Commands

- `make validate` - Check CloudFormation template syntax
- `make check-aws` - Verify AWS CLI configuration
- `make status ENV=<env>` - Check deployment status