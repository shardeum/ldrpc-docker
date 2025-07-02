# CLAUDE.md - AI Assistant Instructions for ldrpc-docker

## Project Overview
This is a Docker setup for running the Shardeum JSON-RPC server in LD (Local Data) mode with all its dependencies. The project provides containerized services for:
- JSON-RPC Server
- Relayer Collector
- Service Validator

## Important Guidelines

### General Rules
1. Do what has been asked; nothing more, nothing less
2. NEVER create files unless they're absolutely necessary for achieving your goal
3. ALWAYS prefer editing existing files to creating new ones
4. NEVER proactively create documentation files (*.md) or README files unless explicitly requested
5. Avoid using emojis in code or documentation unless explicitly requested

### Code Style and Standards
1. Follow existing code patterns and conventions in the repository
2. Use consistent indentation (spaces, not tabs) matching existing files
3. Keep changes minimal and focused - avoid large, complex modifications
4. Every change should impact as little code as possible
5. Maintain backward compatibility with existing configurations

### Docker and Build Considerations
1. The project uses multi-stage Docker builds with configurable branches
2. Default branches are set to 'dev' for all repositories
3. Network configurations are stored in scripts/configs/ directory
4. Environment variables are used extensively for runtime configuration

### Environment Variables
Key environment variables that should be handled carefully:
- Network configuration: ARCHIVER_IP, DISTRIBUTOR_IP, COLLECTOR_PUBKEY, etc.
- RabbitMQ settings: RMQ_HOST, RMQ_USER, RMQ_PASS, queue names
- Build args: SHARDEUM_BRANCH, RELAYER_COLLECTOR_BRANCH, JSON_RPC_SERVER_BRANCH

### Testing and Validation
1. Always verify Docker build commands work correctly
2. Ensure environment variable substitutions are properly escaped
3. Test configuration scripts for syntax errors
4. Validate JSON syntax in ecosystem.config.js

### Security Considerations
1. Never hardcode sensitive information (keys, passwords, IPs)
2. Always use environment variables for configuration
3. Be cautious with collector public/secret keys
4. Ensure proper file permissions are maintained (750 for db directories)

### Common Tasks
1. Adding new network configurations: Create a new .sh file in scripts/configs/
2. Updating branches: Modify build args in Dockerfile or GitHub Actions
3. Adding environment variables: Update both Dockerfile and configure-and-start.sh
4. Modifying PM2 configs: Edit ecosystem.config.js

### File Structure
```
/home/marc/work/ldrpc-docker/
├── Dockerfile
├── README.md
├── ecosystem.config.js
└── scripts/
    ├── configs/
    │   ├── custom.sh
    │   ├── devnet-us.sh
    │   ├── mainnet.sh
    │   ├── stagenet.sh
    │   ├── testnet.sh
    │   └── unstable.sh
    ├── configure-and-start.sh
    ├── install.sh
    └── run-backup.sh
```

### Workflow for Complex Tasks
1. First understand the problem by reading relevant files
2. Plan changes and verify with user before implementation
3. Make changes incrementally with clear explanations
4. Test changes where possible
5. Document only what was changed, not what could be changed