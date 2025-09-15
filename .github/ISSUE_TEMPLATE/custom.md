---
name: Custom issue template
about: Custom issues
title: ''
labels: ''
assignees: ''

---

name: 🐛 Bug Report
description: Report a bug or unexpected behavior
title: "[BUG] "
labels: ["bug", "needs-triage"]
assignees: []
body:
  - type: markdown
    attributes:
      value: |
        ## Bug Report Guidelines
        
        Thanks for taking the time to fill out this bug report! This helps us identify and fix issues quickly.
        
        **Before submitting:**
        - Search existing issues to avoid duplicates
        - Check if this occurs in the latest version
        - Gather all relevant information below
        
        **Security Note:** Do NOT include sensitive data (passwords, API keys, PII) in bug reports.

  - type: checkboxes
    id: preflight-checklist
    attributes:
      label: Pre-flight Checklist
      description: Please confirm you've completed these steps
      options:
        - label: I have searched existing issues and this is not a duplicate
          required: true
        - label: I have updated to the latest version and the issue persists
          required: true
        - label: I have read the documentation and troubleshooting guide
          required: true
        - label: I can reproduce this issue consistently
          required: true
        - label: I have removed all sensitive information from this report
          required: true

  - type: dropdown
    id: bug-severity
    attributes:
      label: Severity Level
      description: How severe is this bug's impact?
      options:
        - "🔴 Critical - System unusable, data loss, security vulnerability"
        - "🟠 High - Major functionality broken, significant workaround needed"
        - "🟡 Medium - Minor functionality broken, workaround available"
        - "🟢 Low - Cosmetic issue, no functional impact"
      default: 2
    validations:
      required: true

  - type: dropdown
    id: bug-frequency
    attributes:
      label: Bug Frequency
      description: How often does this bug occur?
      options:
        - "Always - 100% reproducible"
        - "Often - 75%+ of attempts"
        - "Sometimes - 25-75% of attempts"
        - "Rarely - <25% of attempts"
        - "Once - Single occurrence"
      default: 0
    validations:
      required: true

  - type: textarea
    id: bug-summary
    attributes:
      label: Bug Summary
      description: Clear, concise description of the bug
      placeholder: "When I [action], the system [unexpected behavior] instead of [expected behavior]"
    validations:
      required: true

  - type: textarea
    id: environment-details
    attributes:
      label: Environment Information
      description: Provide your complete environment details
      value: |
        **Operating System:**
        - OS: [e.g., Ubuntu 22.04 LTS, macOS 14.1, Windows 11 Pro]
        - Architecture: [e.g., x86_64, arm64]
        
        **Runtime Environment:**
        - Node.js: [e.g., v20.9.0]
        - Python: [e.g., 3.11.5]
        - Docker: [e.g., v24.0.7]
        - Kubernetes: [e.g., v1.28.2]
        
        **Application Version:**
        - Version: [e.g., v2.1.3]
        - Build: [e.g., commit sha or build number]
        - Installation Method: [e.g., Docker, npm, pip, source]
        
        **Browser (if applicable):**
        - Browser: [e.g., Chrome 119.0.6045.105]
        - Extensions: [e.g., AdBlock, DevTools]
        
        **Infrastructure:**
        - Cloud Provider: [e.g., AWS, GCP, Azure, Local]
        - Region: [e.g., us-east-1]
        - Instance Type: [e.g., t3.medium, 4 CPU, 16GB RAM]
    validations:
      required: true

  - type: textarea
    id: reproduction-steps
    attributes:
      label: Steps to Reproduce
      description: Detailed, numbered steps to reproduce the bug
      value: |
        **Prerequisites:**
        - [e.g., User must be logged in as admin]
        - [e.g., Database must contain test data]
        
        **Reproduction Steps:**
        1. Navigate to [specific page/endpoint]
        2. Enter the following data: [exact values]
        3. Click/execute [specific action]
        4. Wait for [specific duration/condition]
        5. Observe [specific location/output]
        
        **Expected Result:**
        [What should happen]
        
        **Actual Result:**
        [What actually happens]
    validations:
      required: true

  - type: textarea
    id: error-messages
    attributes:
      label: Error Messages and Logs
      description: Include complete error messages, stack traces, and relevant logs
      render: shell
      placeholder: |
        # Application Logs
        2024-09-15T14:30:45.123Z ERROR [main] Application failed to start
        Caused by: java.lang.NullPointerException: Cannot read property 'foo' of undefined
            at com.example.Service.method(Service.java:123)
            at com.example.Controller.handler(Controller.java:45)
        
        # Browser Console (if applicable)
        Uncaught TypeError: Cannot read property 'length' of undefined
            at Object.<anonymous> (app.js:67:12)
        
        # System Logs (if applicable)
        Sep 15 14:30:45 hostname kernel: Out of memory: Kill process 1234

  - type: textarea
    id: configuration
    attributes:
      label: Configuration Details
      description: Relevant configuration files, environment variables, or settings
      render: yaml
      placeholder: |
        # docker-compose.yml
        version: '3.8'
        services:
          app:
            image: myapp:2.1.3
            environment:
              - NODE_ENV=production
              - DATABASE_URL=postgresql://...
        
        # application.yml
        server:
          port: 8080
        database:
          driver: postgresql
          max-connections: 20

  - type: textarea
    id: network-info
    attributes:
      label: Network and Security Context
      description: Network topology, firewall rules, proxy settings (if relevant)
      placeholder: |
        - Load Balancer: [e.g., AWS ALB, nginx]
        - Reverse Proxy: [e.g., Cloudflare, nginx]
        - Firewall Rules: [e.g., port 443 open, 8080 restricted]
        - VPN/Network: [e.g., corporate VPN, isolated network]
        - SSL/TLS: [e.g., Let's Encrypt, self-signed]

  - type: textarea
    id: screenshots-videos
    attributes:
      label: Screenshots and Videos
      description: Visual evidence of the bug (drag and drop files here)
      placeholder: |
        Attach screenshots, videos, or other visual evidence.
        
        For web issues: Include browser developer tools (Network, Console tabs)
        For UI issues: Include before/after screenshots
        For performance issues: Include profiling screenshots

  - type: textarea
    id: workaround
    attributes:
      label: Current Workaround
      description: Any temporary solutions or workarounds you've found
      placeholder: |
        - Restart the service every hour
        - Use alternative API endpoint
        - Disable specific feature
        - None found

  - type: dropdown
    id: regression
    attributes:
      label: Regression Information
      description: Was this working before?
      options:
        - "Not a regression - Never worked"
        - "Recent regression - Worked in previous version"
        - "Old regression - Broken for multiple versions"
        - "Unknown - Unsure if it worked before"
      default: 3

  - type: input
    id: last-working-version
    attributes:
      label: Last Working Version
      description: If this is a regression, what was the last working version?
      placeholder: "e.g., v2.0.5, commit abc123, last week"

  - type: textarea
    id: impact-assessment
    attributes:
      label: Business Impact
      description: How does this bug affect users and business operations?
      placeholder: |
        **User Impact:**
        - Number of affected users: [e.g., all users, 10% of users, admin users only]
        - User experience impact: [e.g., cannot complete checkout, slow page load]
        
        **Business Impact:**
        - Revenue impact: [e.g., blocking sales, reduced conversion]
        - Operational impact: [e.g., manual workaround required, support tickets]
        - Security impact: [e.g., data exposure risk, authentication bypass]

  - type: textarea
    id: additional-context
    attributes:
      label: Additional Context
      description: Any other relevant information, related issues, or context
      placeholder: |
        - Related issues: #123, #456
        - Similar reports in: [external systems, user forums]
        - Timing correlation: [recent deployments, infrastructure changes]
        - External dependencies: [third-party service outages, network issues]

  - type: checkboxes
    id: follow-up
    attributes:
      label: Follow-up Actions
      description: What are you willing to help with?
      options:
        - label: I can provide additional debugging information if needed
        - label: I can test potential fixes in my environment
        - label: I can help write unit tests for this bug
        - label: I can submit a pull request with a potential fix
