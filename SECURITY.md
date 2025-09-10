# Security Guidelines for COVID19 dbt Project

## Overview
This document outlines security best practices and configurations for the COVID19 hospital bed occupancy analysis project.

## Database Connection Security

### Recommended profiles.yml Configuration
```yaml
# IMPORTANT: Store sensitive credentials in environment variables
# This configuration should be in your ~/.dbt/profiles.yml file (NOT in the project)

covid19:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"
      user: "{{ env_var('SNOWFLAKE_USER') }}"
      password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
      role: "{{ env_var('SNOWFLAKE_ROLE') }}"
      database: COVID19
      warehouse: "{{ env_var('SNOWFLAKE_WAREHOUSE') }}"
      schema: PUBLIC
      
      # Security enhancements
      authenticator: snowflake
      client_session_keep_alive: false
      query_tag: "dbt_covid19_project"
      connect_retries: 3
      connect_timeout: 60
      retry_on_database_errors: true
      
    prod:
      type: snowflake
      account: "{{ env_var('SNOWFLAKE_ACCOUNT_PROD') }}"
      user: "{{ env_var('SNOWFLAKE_USER_PROD') }}"
      password: "{{ env_var('SNOWFLAKE_PASSWORD_PROD') }}"
      role: "{{ env_var('SNOWFLAKE_ROLE_PROD') }}"
      database: COVID19_PROD
      warehouse: "{{ env_var('SNOWFLAKE_WAREHOUSE_PROD') }}"
      schema: PUBLIC
      
      # Production security settings
      authenticator: snowflake
      client_session_keep_alive: false
      query_tag: "dbt_covid19_prod"
      connect_retries: 3
      connect_timeout: 60
      retry_on_database_errors: true
```

### Required Environment Variables
Set these environment variables before running dbt:

**Development:**
- `SNOWFLAKE_ACCOUNT`: Your Snowflake account identifier
- `SNOWFLAKE_USER`: Your Snowflake username
- `SNOWFLAKE_PASSWORD`: Your Snowflake password
- `SNOWFLAKE_ROLE`: Database role (e.g., DBT_ROLE)
- `SNOWFLAKE_WAREHOUSE`: Compute warehouse name

**Production:**
- `SNOWFLAKE_ACCOUNT_PROD`: Production Snowflake account
- `SNOWFLAKE_USER_PROD`: Production service account username
- `SNOWFLAKE_PASSWORD_PROD`: Production service account password
- `SNOWFLAKE_ROLE_PROD`: Production database role
- `SNOWFLAKE_WAREHOUSE_PROD`: Production compute warehouse

## Data Classification

### Sensitivity Levels
- **Public**: Dimension tables (time, location types)
- **Internal**: Aggregated metrics without personal identifiers
- **Sensitive**: Raw health data, detailed occupancy metrics
- **Restricted**: Not applicable to this project

### PII Handling
- The `p_usuario` field contains user identifiers and should be treated as PII
- Consider hashing or pseudonymizing this field in staging models
- Implement data retention policies per healthcare regulations

## Access Control

### Recommended Snowflake Roles
- `COVID19_READ_ONLY`: Read access to Gold layer only
- `COVID19_ANALYST`: Read access to Silver and Gold layers
- `COVID19_DATA_ENGINEER`: Full access for data pipeline management
- `COVID19_ADMIN`: Full administrative access

### Principle of Least Privilege
- Grant minimum necessary permissions
- Regular review of user access
- Implement role-based access control

## Monitoring and Auditing

### Data Quality Monitoring
- Run data quality tests on every deployment
- Monitor for data freshness and completeness
- Set up alerts for data quality failures

### Access Logging
- Enable Snowflake query history logging
- Monitor unusual access patterns
- Implement audit trails for sensitive data access

## Compliance Considerations

### LGPD/GDPR Compliance
- Implement data retention policies
- Document data processing activities
- Ensure data subject rights capabilities
- Regular privacy impact assessments

### Healthcare Data Regulations
- Follow local healthcare data protection laws
- Implement appropriate security controls
- Regular security audits and assessments

## Incident Response

### Data Breach Response
1. Immediately isolate affected systems
2. Notify relevant stakeholders
3. Document the incident
4. Implement corrective measures
5. Review and update security controls

### Contact Information
- Data Protection Officer: [CONTACT_INFO]
- Security Team: [CONTACT_INFO]
- Infrastructure Team: [CONTACT_INFO]

## Security Checklist

### Before Deployment
- [ ] Environment variables properly configured
- [ ] Database connections use encryption
- [ ] Access roles properly defined
- [ ] Data quality tests passing
- [ ] PII handling reviewed
- [ ] Audit logging enabled

### Regular Maintenance
- [ ] Review user access quarterly
- [ ] Update dependencies regularly
- [ ] Monitor for security advisories
- [ ] Test backup and recovery procedures
- [ ] Review and update documentation

## Best Practices

1. **Never commit credentials** to version control
2. **Use environment variables** for all sensitive configuration
3. **Implement defense in depth** with multiple security layers
4. **Regular security training** for team members
5. **Automated security testing** in CI/CD pipeline
6. **Regular penetration testing** for production systems

## Updates and Maintenance

This document should be reviewed and updated:
- Quarterly or when significant changes are made
- After security incidents
- When regulations change
- During major system upgrades