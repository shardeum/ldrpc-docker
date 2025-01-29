module.exports = {
  apps: [
    {
      name: 'validator',
      cwd: '/home/node/shardeum',
      script: 'dist/src/index.js',
      node_args: '--max_old_space_size=16000'
    },
    {
      name: 'collector-server',
      cwd: '/home/node/relayer-collector',
      script: 'dist/src/collector.js',
      node_args: '--max_old_space_size=16000'
    },
    {
      name: 'collector-api-server',
      cwd: '/home/node/relayer-collector',
      script: 'dist/src/server.js',
      node_args: '--max_old_space_size=16000'
    },
    {
      name: 'collector-log-server',
      cwd: '/home/node/relayer-collector',
      script: 'dist/src/log_server.js',
      node_args: '--max_old_space_size=16000'
    },
    {
      name: 'json-rpc-server',
      cwd: '/home/node/json-rpc-server',
      script: 'npm',
      args: 'start',
      node_args: '--max_old_space_size=16000'
    }
  ]
} 