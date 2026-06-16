/**
 * server.js — Simple health-check API
 * 
 * Intentionally minimal. The app is cargo — the infrastructure and
 * pipeline security gates are the project. This just needs to serve
 * a response so we can verify the deploy works end-to-end.
 * 
 * What it demonstrates:
 * - A deployable service behind a load balancer / security group
 * - Health check endpoint for CI/CD validation
 * - npm audit will scan these dependencies for vulnerabilities
 */

const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Health check — used by load balancers and CI/CD smoke tests
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Root — basic info endpoint
app.get('/', (req, res) => {
  res.json({
    project: 'Cloud Secure CI/CD',
    message: 'Watch this space. Under active development.',
    docs: '/health for health check'
  });
});

// Only start listening if this is the main module (not required in tests)
if (require.main === module) {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
  });
}

// Export for testing
module.exports = app;
