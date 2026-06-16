#!/bin/bash
set -x
exec > /var/log/user_data.log 2>&1
echo "Starting user_data at $(date)"
dnf install -y nodejs git
mkdir -p /opt/app
cat > /opt/app/server.js << 'HEREDOC'
var http = require('http');
http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'application/json'});
  if (req.url === '/health') {
    res.end(JSON.stringify({status: 'ok'}));
  } else {
    res.end(JSON.stringify({project: 'Cloud Secure CI/CD', status: 'deployed'}));
  }
}).listen(3000, '0.0.0.0', function() {
  console.log('Server running on port 3000');
});
HEREDOC
nohup node /opt/app/server.js > /var/log/app_stdout.log 2>&1 &
sleep 5
curl -s http://localhost:3000/health && echo "SUCCESS-NODE-UP" || echo "FAILED-NODE-DOWN"
echo "Completed at $(date)"
