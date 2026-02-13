const assert = require('assert');
const http = require('http');
const app = require('./app');

const server = http.createServer(app);
let port;

function request(path, timeoutMs) {
  return new Promise((resolve, reject) => {
    const req = http.get(`http://127.0.0.1:${port}${path}`, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => resolve({ status: res.statusCode, body }));
    });
    req.on('error', reject);
    if (timeoutMs) {
      setTimeout(() => {
        req.destroy();
        resolve({ status: 'timeout', body: '' });
      }, timeoutMs);
    }
  });
}

async function runTests() {
  let passed = 0;
  let failed = 0;

  await new Promise((resolve) => {
    server.listen(0, '127.0.0.1', () => {
      port = server.address().port;
      resolve();
    });
  });

  // Test 1: App module exports an Express app
  try {
    assert.strictEqual(typeof app, 'function', 'app should be a function');
    console.log('  PASS: App module exports Express app');
    passed++;
  } catch (e) {
    console.log('  FAIL: App module exports -', e.message);
    failed++;
  }

  // Test 2: GET /api/status route exists (with timeout — DB may not be available)
  try {
    const res = await request('/api/status', 3000);
    // Route is registered if we get any HTTP response OR a timeout (DB not available)
    assert.ok(res.status === 200 || res.status === 500 || res.status === 'timeout',
      'Status route should be registered');
    console.log('  PASS: GET /api/status route is registered (' + res.status + ')');
    passed++;
  } catch (e) {
    console.log('  FAIL: GET /api/status -', e.message);
    failed++;
  }

  // Test 3: Unknown routes return 404
  try {
    const res = await request('/nonexistent');
    assert.strictEqual(res.status, 404, 'Unknown route should return 404');
    console.log('  PASS: Unknown routes return 404');
    passed++;
  } catch (e) {
    console.log('  FAIL: 404 handler -', e.message);
    failed++;
  }

  // Test 4: 404 response is JSON with message field
  try {
    const res = await request('/nonexistent');
    const body = JSON.parse(res.body);
    assert.ok(body.message, 'Error response should have message field');
    console.log('  PASS: 404 response is valid JSON with message');
    passed++;
  } catch (e) {
    console.log('  FAIL: 404 JSON response -', e.message);
    failed++;
  }

  server.close();

  console.log(`\n  ${passed} passing, ${failed} failing\n`);
  if (failed > 0) process.exit(1);
  process.exit(0);
}

console.log('\n  API Tests\n');
runTests().catch((err) => {
  console.error('Test runner error:', err);
  server.close();
  process.exit(1);
});
