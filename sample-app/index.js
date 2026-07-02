'use strict';

/**
 * ARC SaaS EKS Blueprint — sample HTTP handler.
 *
 * A zero-dependency Node.js HTTP server that proves the stack works end-to-end:
 * ALB → WAF → EKS (this pod) → JSON response.
 *
 * Replace with your real application. The Dockerfile and k8s/ manifests stay the same.
 */

const http = require('http');

const PORT = process.env.PORT || 8080;
const VERSION = process.env.APP_VERSION || '1.0.0';

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok' }));
    return;
  }

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    message: 'Your ARC SaaS EKS Blueprint is live.',
    poweredBy: 'SourceFuse ARC Blueprint',
    version: VERSION,
    request: { method: req.method, path: req.url },
    timestamp: new Date().toISOString(),
  }, null, 2));
});

server.listen(PORT, () => {
  console.log(`Sample app listening on :${PORT}`);
});
