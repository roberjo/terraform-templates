# Additional Architecture Diagrams

This document contains additional architecture diagrams to complement the main project architecture diagrams and fill identified gaps.

## Table of Contents

1. [Pattern Comparison Matrix](#pattern-comparison-matrix)
2. [Data Flow Diagrams](#data-flow-diagrams)
3. [Implementation Roadmap](#implementation-roadmap)
4. [VPC Architecture](#vpc-architecture)
5. [IAM Permission Diagrams](#iam-permission-diagrams)
6. [Monitoring and Alerting](#monitoring-and-alerting)
7. [CI/CD Pipeline](#cicd-pipeline)
8. [Testing Strategy](#testing-strategy)
9. [Troubleshooting Flowcharts](#troubleshooting-flowcharts)

---

## Pattern Comparison Matrix

```mermaid
graph TB
    subgraph "Pattern Comparison Matrix"
        subgraph "Complexity Level"
            SIMPLE[Simple<br/>Low Complexity]
            MEDIUM[Medium<br/>Moderate Complexity]
            COMPLEX[Complex<br/>High Complexity]
        end
        
        subgraph "Cost Profile"
            LOW_COST[Low Cost<br/>Pay-per-request]
            MED_COST[Medium Cost<br/>Mixed pricing]
            HIGH_COST[Higher Cost<br/>More resources]
        end
        
        subgraph "Performance"
            FAST[Fast<br/>Low latency]
            MED_PERF[Medium<br/>Balanced]
            SCALABLE[Scalable<br/>Auto-scaling]
        end
        
        subgraph "Security"
            BASIC[Basic<br/>Standard security]
            ENHANCED[Enhanced<br/>WAF + encryption]
            COMPREHENSIVE[Comprehensive<br/>Multi-layer]
        end
    end
    
    subgraph "Patterns"
        AGDD[API Gateway<br/>Direct DynamoDB]
        AGLSS[API Gateway<br/>Lambda SNS SQS]
        ELASS[EventBridge<br/>Lambda API SNS SQS]
        RWCS[Route53 WAF<br/>CloudFront S3]
        AGMD[API Gateway<br/>Microservices<br/>DynamoDB]
    end
    
    AGDD --> SIMPLE
    AGDD --> LOW_COST
    AGDD --> FAST
    AGDD --> BASIC
    
    AGLSS --> MEDIUM
    AGLSS --> MED_COST
    AGLSS --> MED_PERF
    AGLSS --> ENHANCED
    
    ELASS --> COMPLEX
    ELASS --> MED_COST
    ELASS --> SCALABLE
    ELASS --> ENHANCED
    
    RWCS --> MEDIUM
    RWCS --> MED_COST
    RWCS --> FAST
    RWCS --> COMPREHENSIVE
    
    AGMD --> COMPLEX
    AGMD --> HIGH_COST
    AGMD --> SCALABLE
    AGMD --> COMPREHENSIVE
    
    style AGDD fill:#e1f5fe
    style AGLSS fill:#f3e5f5
    style ELASS fill:#e8f5e8
    style RWCS fill:#fff3e0
    style AGMD fill:#fce4ec
```

---

## Data Flow Diagrams

### API Gateway Direct DynamoDB Data Flow

```mermaid
sequenceDiagram
    participant Client
    participant API Gateway
    participant VTL
    participant DynamoDB
    participant CloudWatch
    
    Client->>API Gateway: HTTP Request
    API Gateway->>VTL: Transform Request
    VTL->>DynamoDB: Database Operation
    DynamoDB-->>VTL: Response Data
    VTL->>API Gateway: Transform Response
    API Gateway-->>Client: HTTP Response
    API Gateway->>CloudWatch: Log Request
    DynamoDB->>CloudWatch: Log Operation
```

### API Gateway Lambda SNS SQS Data Flow

```mermaid
sequenceDiagram
    participant Client
    participant API Gateway
    participant Lambda1
    participant SNS
    participant SQS
    participant Lambda2
    participant CloudWatch
    
    Client->>API Gateway: HTTP Request
    API Gateway->>Lambda1: Process Request
    Lambda1->>SNS: Publish Message
    SNS->>SQS: Deliver Message
    SQS->>Lambda2: Trigger Processing
    Lambda2->>CloudWatch: Log Processing
    Lambda1-->>API Gateway: Return Response
    API Gateway-->>Client: HTTP Response
```

### EventBridge Lambda API SNS SQS Data Flow

```mermaid
sequenceDiagram
    participant EventBridge
    participant Lambda1
    participant External API
    participant SNS
    participant SQS
    participant Lambda2
    participant CloudWatch
    
    EventBridge->>Lambda1: Scheduled Trigger
    Lambda1->>External API: Fetch Data
    External API-->>Lambda1: Return Data
    Lambda1->>SNS: Publish Messages
    SNS->>SQS: Deliver Messages
    SQS->>Lambda2: Process Messages
    Lambda2->>CloudWatch: Log Results
```

---

## Implementation Roadmap

```mermaid
graph TB
    subgraph "Implementation Phases"
        subgraph "Phase 1: Foundation"
            P1_1[Choose Pattern]
            P1_2[Set Up AWS Account]
            P1_3[Configure Terraform]
        end
        
        subgraph "Phase 2: Core Infrastructure"
            P2_1[Deploy Base Resources]
            P2_2[Configure Security]
            P2_3[Set Up Monitoring]
        end
        
        subgraph "Phase 3: Application Layer"
            P3_1[Deploy Application]
            P3_2[Configure APIs]
            P3_3[Test Functionality]
        end
        
        subgraph "Phase 4: Production"
            P4_1[Performance Testing]
            P4_2[Security Review]
            P4_3[Go Live]
        end
    end
    
    subgraph "Migration Paths"
        M1[Start Simple<br/>API Gateway Direct DynamoDB]
        M2[Add Complexity<br/>Lambda Processing]
        M3[Scale Up<br/>Microservices]
        M4[Global Distribution<br/>CloudFront + WAF]
    end
    
    P1_1 --> P1_2
    P1_2 --> P1_3
    P1_3 --> P2_1
    P2_1 --> P2_2
    P2_2 --> P2_3
    P2_3 --> P3_1
    P3_1 --> P3_2
    P3_2 --> P3_3
    P3_3 --> P4_1
    P4_1 --> P4_2
    P4_2 --> P4_3
    
    M1 --> M2
    M2 --> M3
    M3 --> M4
    
    style M1 fill:#e1f5fe
    style M2 fill:#f3e5f5
    style M3 fill:#e8f5e8
    style M4 fill:#fff3e0
```

---

## VPC Architecture

```mermaid
graph TB
    subgraph "VPC Architecture (Optional)"
        subgraph "Public Subnets"
            PUBLIC_AZ1[Public Subnet<br/>AZ-1]
            PUBLIC_AZ2[Public Subnet<br/>AZ-2]
        end
        
        subgraph "Private Subnets"
            PRIVATE_AZ1[Private Subnet<br/>AZ-1]
            PRIVATE_AZ2[Private Subnet<br/>AZ-2]
        end
        
        subgraph "Database Subnets"
            DB_AZ1[Database Subnet<br/>AZ-1]
            DB_AZ2[Database Subnet<br/>AZ-2]
        end
    end
    
    subgraph "Security Groups"
        SG_API[API Gateway SG<br/>HTTPS: 443]
        SG_LAMBDA[Lambda SG<br/>Outbound: All]
        SG_DB[DynamoDB SG<br/>VPC Endpoint]
    end
    
    subgraph "Network ACLs"
        NACL_PUBLIC[Public NACL<br/>Allow HTTP/HTTPS]
        NACL_PRIVATE[Private NACL<br/>Restrictive]
    end
    
    PUBLIC_AZ1 --> SG_API
    PUBLIC_AZ2 --> SG_API
    PRIVATE_AZ1 --> SG_LAMBDA
    PRIVATE_AZ2 --> SG_LAMBDA
    DB_AZ1 --> SG_DB
    DB_AZ2 --> SG_DB
    
    SG_API --> NACL_PUBLIC
    SG_LAMBDA --> NACL_PRIVATE
    SG_DB --> NACL_PRIVATE
    
    style PUBLIC_AZ1 fill:#ff9800
    style PRIVATE_AZ1 fill:#2196f3
    style DB_AZ1 fill:#4caf50
```

---

## IAM Permission Diagrams

```mermaid
graph TB
    subgraph "IAM Roles and Policies"
        subgraph "API Gateway Role"
            AG_ROLE[API Gateway<br/>Execution Role]
            AG_POLICY[CloudWatch<br/>Logging Policy]
        end
        
        subgraph "Lambda Roles"
            LAMBDA_ROLE[Lambda<br/>Execution Role]
            LAMBDA_POLICY[Custom<br/>Lambda Policy]
        end
        
        subgraph "Service Roles"
            SNS_ROLE[SNS<br/>Service Role]
            SQS_ROLE[SQS<br/>Service Role]
        end
    end
    
    subgraph "Permissions"
        PERM_READ[Read Permissions<br/>DynamoDB, S3]
        PERM_WRITE[Write Permissions<br/>SNS, SQS]
        PERM_EXECUTE[Execute Permissions<br/>Lambda]
        PERM_LOG[Logging Permissions<br/>CloudWatch]
    end
    
    AG_ROLE --> AG_POLICY
    AG_POLICY --> PERM_LOG
    
    LAMBDA_ROLE --> LAMBDA_POLICY
    LAMBDA_POLICY --> PERM_READ
    LAMBDA_POLICY --> PERM_WRITE
    LAMBDA_POLICY --> PERM_EXECUTE
    LAMBDA_POLICY --> PERM_LOG
    
    SNS_ROLE --> PERM_WRITE
    SQS_ROLE --> PERM_READ
    
    style AG_ROLE fill:#ff9800
    style LAMBDA_ROLE fill:#2196f3
    style PERM_READ fill:#4caf50
    style PERM_WRITE fill:#9c27b0
```

---

## Monitoring and Alerting

```mermaid
graph TB
    subgraph "Monitoring Stack"
        subgraph "Data Collection"
            CW_LOGS[CloudWatch<br/>Logs]
            CW_METRICS[CloudWatch<br/>Metrics]
            CW_TRACES[X-Ray<br/>Traces]
        end
        
        subgraph "Alerting"
            ALARMS[CloudWatch<br/>Alarms]
            SNS_ALERTS[SNS<br/>Alerts]
            EMAIL[Email<br/>Notifications]
        end
        
        subgraph "Dashboards"
            DASH_OPERATIONAL[Operational<br/>Dashboard]
            DASH_BUSINESS[Business<br/>Dashboard]
            DASH_SECURITY[Security<br/>Dashboard]
        end
    end
    
    subgraph "AWS Services"
        API[API Gateway]
        LAMBDA[Lambda]
        DDB[DynamoDB]
        S3[S3]
    end
    
    API --> CW_LOGS
    API --> CW_METRICS
    LAMBDA --> CW_LOGS
    LAMBDA --> CW_METRICS
    LAMBDA --> CW_TRACES
    DDB --> CW_METRICS
    S3 --> CW_METRICS
    
    CW_METRICS --> ALARMS
    ALARMS --> SNS_ALERTS
    SNS_ALERTS --> EMAIL
    
    CW_METRICS --> DASH_OPERATIONAL
    CW_METRICS --> DASH_BUSINESS
    CW_LOGS --> DASH_SECURITY
    
    style CW_LOGS fill:#4caf50
    style ALARMS fill:#f44336
    style DASH_OPERATIONAL fill:#2196f3
```

---

## CI/CD Pipeline

```mermaid
graph LR
    subgraph "Development"
        DEV[Developer<br/>Local Environment]
        GIT[Git Repository<br/>Version Control]
        CODE_REVIEW[Code Review<br/>Pull Request]
    end
    
    subgraph "CI/CD Pipeline"
        BUILD[Build<br/>Terraform Plan]
        TEST[Test<br/>Infrastructure Tests]
        SECURITY[Security<br/>Scan]
        DEPLOY_STAGING[Deploy to<br/>Staging]
        DEPLOY_PROD[Deploy to<br/>Production]
    end
    
    subgraph "Environments"
        STAGING[Staging<br/>Environment]
        PROD[Production<br/>Environment]
    end
    
    subgraph "Quality Gates"
        UNIT_TESTS[Unit Tests<br/>Pass]
        INTEGRATION_TESTS[Integration Tests<br/>Pass]
        SECURITY_SCAN[Security Scan<br/>Pass]
        APPROVAL[Manual<br/>Approval]
    end
    
    DEV --> GIT
    GIT --> CODE_REVIEW
    CODE_REVIEW --> BUILD
    BUILD --> TEST
    TEST --> SECURITY
    SECURITY --> DEPLOY_STAGING
    DEPLOY_STAGING --> STAGING
    STAGING --> UNIT_TESTS
    STAGING --> INTEGRATION_TESTS
    UNIT_TESTS --> SECURITY_SCAN
    INTEGRATION_TESTS --> SECURITY_SCAN
    SECURITY_SCAN --> APPROVAL
    APPROVAL --> DEPLOY_PROD
    DEPLOY_PROD --> PROD
    
    style DEV fill:#2196f3
    style GIT fill:#ff9800
    style PROD fill:#f44336
    style APPROVAL fill:#9c27b0
```

---

## Testing Strategy

```mermaid
graph TB
    subgraph "Testing Pyramid"
        subgraph "Unit Tests"
            UNIT_TERRAFORM[Terraform<br/>Unit Tests]
            UNIT_LAMBDA[Lambda<br/>Unit Tests]
        end
        
        subgraph "Integration Tests"
            INT_API[API<br/>Integration Tests]
            INT_DB[Database<br/>Integration Tests]
        end
        
        subgraph "End-to-End Tests"
            E2E_WORKFLOW[Complete<br/>Workflow Tests]
            E2E_PERFORMANCE[Performance<br/>Tests]
        end
    end
    
    subgraph "Testing Tools"
        TOOL_TERRAFORM[Terraform Test<br/>Framework]
        TOOL_LAMBDA[AWS SAM<br/>Local Testing]
        TOOL_API[Postman/Newman<br/>API Testing]
        TOOL_PERF[Artillery<br/>Load Testing]
    end
    
    subgraph "Test Environments"
        ENV_LOCAL[Local<br/>Development]
        ENV_STAGING[Staging<br/>Environment]
        ENV_PROD[Production<br/>Environment]
    end
    
    UNIT_TERRAFORM --> TOOL_TERRAFORM
    UNIT_LAMBDA --> TOOL_LAMBDA
    INT_API --> TOOL_API
    E2E_PERFORMANCE --> TOOL_PERF
    
    TOOL_TERRAFORM --> ENV_LOCAL
    TOOL_LAMBDA --> ENV_LOCAL
    TOOL_API --> ENV_STAGING
    TOOL_PERF --> ENV_STAGING
    
    style UNIT_TERRAFORM fill:#4caf50
    style INT_API fill:#ff9800
    style E2E_WORKFLOW fill:#f44336
```

---

## Troubleshooting Flowcharts

### API Gateway Issues

```mermaid
flowchart TD
    A[API Gateway Issue] --> B{Is API responding?}
    B -->|No| C[Check API Gateway logs]
    B -->|Yes| D[Check response time]
    
    C --> E{Are there errors?}
    E -->|Yes| F[Check IAM permissions]
    E -->|No| G[Check Lambda function]
    
    F --> H[Verify API Gateway role]
    H --> I[Check CloudWatch logs]
    
    G --> J{Is Lambda working?}
    J -->|No| K[Check Lambda logs]
    J -->|Yes| L[Check integration]
    
    D --> M{Is response time high?}
    M -->|Yes| N[Check Lambda timeout]
    M -->|No| O[Check client configuration]
    
    style A fill:#f44336
    style I fill:#4caf50
    style O fill:#4caf50
```

### DynamoDB Issues

```mermaid
flowchart TD
    A[DynamoDB Issue] --> B{Can read data?}
    B -->|No| C[Check IAM permissions]
    B -->|Yes| D{Can write data?}
    
    C --> E[Verify DynamoDB policy]
    E --> F[Check table permissions]
    
    D -->|No| G[Check write capacity]
    D -->|Yes| H[Check data consistency]
    
    G --> I[Check provisioned capacity]
    I --> J[Consider auto-scaling]
    
    H --> K{Data consistent?}
    K -->|No| L[Check eventual consistency]
    K -->|Yes| M[Check application logic]
    
    style A fill:#f44336
    style F fill:#4caf50
    style M fill:#4caf50
```

---

## Conclusion

These additional architecture diagrams provide:

1. **Pattern Selection Guidance**: Comparison matrix helps choose the right pattern
2. **Implementation Clarity**: Data flow diagrams show how components interact
3. **Operational Excellence**: Monitoring, CI/CD, and testing strategies
4. **Troubleshooting Support**: Flowcharts for common issues
5. **Security Understanding**: IAM and VPC architecture details

Together with the main architecture diagrams, this creates a comprehensive showcase of AWS Solutions Architecture capabilities.
