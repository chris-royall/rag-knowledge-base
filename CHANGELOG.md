# Changelog

All notable changes to the RAG Knowledge Base project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025/12/20

### Added

- Automatic synchronization of documents from S3 to OpenSearch using Amazon Bedrock Knowledge Base after deployment.

## [1.1.1] - 2025/12/20

### Changed
- Updated AWS resource tagging strategy by replacing the `Version` tag with standardized operational tags.

## [1.1.0] - 2025/12/13

### Added
- Optional Cognito JWT authorization for API Gateway
- Configuration parameters for User Pool ID and App Client ID
- Updated documentation for authorization setup and usage examples

## [1.0.1] - 2025/12/11

### Fixed
- Removed duplicate URLs in chat API response when documents are cited multiple times
- Updated visual documentation images

## [1.0.0] - 2025/12/11

### Added
- Initial release of RAG Knowledge Base system
- Complete AWS infrastructure deployment via CloudFormation
- Amazon OpenSearch Service integration for vector storage
- Amazon Bedrock Knowledge Base with automated document processing
- Lambda-based chat API with configurable chatbot personality
- API Gateway HTTP endpoint with CORS support
- Multi-AZ OpenSearch deployment options with validation
- Configuration-driven design with environment-specific settings
- CloudWatch logging and monitoring
- Custom OpenSearch index creation via Lambda function
- S3 document storage integration
- Citation processing with URL generation
- Built-in security features (IAM roles, encryption, HTTPS)
- Makefile automation for deployment and management
- Support for multiple foundation models
- Professional documentation with architecture diagrams
