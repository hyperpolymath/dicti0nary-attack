# Security Policy

## Supported Versions

We take security seriously. The following versions are currently supported with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Security Context

**dicti0nary-attack** is a security research tool designed for:
- ✅ Authorized penetration testing
- ✅ Security audits of owned systems
- ✅ CTF competitions
- ✅ Academic research
- ✅ Password strength analysis

**Unauthorized use is illegal.** This tool must only be used with explicit written permission.

## Reporting a Vulnerability

### Where to Report

**DO NOT** open public GitHub issues for security vulnerabilities.

Instead, report security issues via:

1. **Email**: security@[project-domain] (if available)
2. **GitHub Security Advisories**: Use the "Security" tab → "Report a vulnerability"
3. **Encrypted communication**: PGP key available in `.well-known/security.txt`

### What to Include

Please include:

- **Description**: Clear description of the vulnerability
- **Impact**: Potential security impact
- **Reproduction**: Steps to reproduce the issue
- **Affected versions**: Which versions are affected
- **Suggested fix**: If you have one
- **Disclosure timeline**: Your preferred disclosure timeline

### Response Timeline

We aim to:

- **Acknowledge** receipt within **48 hours**
- **Initial assessment** within **7 days**
- **Fix development** within **30 days** for critical issues
- **Public disclosure** after fix is released (coordinated disclosure)

### Vulnerability Severity

We use CVSS 3.1 scoring:

- **Critical** (9.0-10.0): Immediate attention, emergency patch
- **High** (7.0-8.9): High priority, patch within 30 days
- **Medium** (4.0-6.9): Standard priority, patch within 60 days
- **Low** (0.1-3.9): Low priority, patch in next release

## Security Considerations

### Tool-Specific Security

This is a **password cracking tool**. Security considerations include:

1. **Hash Algorithm Security**
   - We support multiple hash algorithms (MD5, SHA256, etc.)
   - Some algorithms (MD5, SHA1) are cryptographically broken
   - Use modern algorithms (SHA256+) for new implementations

2. **Data Protection**
   - **Never commit** password hashes to version control
   - **Never commit** cracked passwords to version control
   - Use the `.gitignore` to exclude output directories
   - Clear output files after use

3. **Access Control**
   - Run with minimum required permissions
   - Do not run as root unless absolutely necessary
   - Use virtual environments to isolate dependencies

4. **Network Security**
   - This tool is **offline-first** by design
   - No network calls in core functionality
   - Web interface should be used on localhost only or behind authentication

### Known Limitations

1. **Parallel Processing**: Multi-process cracking may consume significant CPU resources
2. **Memory Usage**: Large wordlists may require significant RAM
3. **Output Files**: Generated files may contain sensitive data - secure appropriately

### Security Best Practices for Users

1. **Authorization**: Always obtain written permission before testing
2. **Data Handling**: Treat all hashes and cracked passwords as sensitive data
3. **Environment**: Use in isolated, controlled environments
4. **Logging**: Disable logging of sensitive data in production
5. **Updates**: Keep the tool updated for security fixes

## Responsible Disclosure

We believe in **coordinated disclosure**:

1. Report vulnerabilities privately
2. Work with us to develop a fix
3. Allow time for users to update
4. Coordinate public disclosure

We will:
- Credit researchers in security advisories (unless you prefer anonymity)
- Maintain a security hall of fame for responsible disclosures
- Not pursue legal action against good-faith security researchers

## Security Updates

Security updates are distributed via:

- **GitHub Releases**: Tagged releases with security fixes
- **CHANGELOG.md**: Security fixes documented
- **Security Advisories**: GitHub Security Advisories for critical issues
- **Mailing list**: (if established)

## Scope

### In Scope

- Vulnerabilities in dicti0nary-attack code
- Security issues in dependencies
- Configuration issues leading to security problems
- Documentation issues that could lead to insecure usage

### Out of Scope

- Vulnerabilities in third-party dependencies (report to upstream)
- Issues in user-specific configurations
- Social engineering attacks
- Physical security issues
- Issues requiring unauthorized access to systems

## Legal Safe Harbor

We support good-faith security research. If you:

- Make a good faith effort to avoid privacy violations and data destruction
- Only interact with systems you have permission to test
- Report issues promptly and cooperate with remediation
- Do not publicly disclose issues before fixes are available

We will not initiate legal action and will work with you on coordinated disclosure.

## Security Hardening

### For Developers

- All dependencies must be pinned with integrity hashes
- Use automated security scanning (Bandit, Safety)
- Regular dependency updates via Dependabot
- Code review for all changes
- No secrets in source code
- Input validation for all user input

### For Users

- Install from official sources only
- Verify package signatures
- Use virtual environments
- Run with least privilege
- Keep software updated
- Review configuration before use

## Contact

- **Security email**: Create dedicated security@domain when available
- **PGP key**: See `.well-known/security.txt`
- **Security advisories**: GitHub Security tab

## Acknowledgments

We maintain a security hall of fame for responsible disclosures:

*(To be populated as vulnerabilities are responsibly disclosed)*

---

**Last updated**: 2025-11-22
**Policy version**: 1.0
