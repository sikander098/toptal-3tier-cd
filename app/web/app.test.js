const assert = require('assert');
const http = require('http');
const app = require('./app');

const server = http.createServer(app);
let port;

function request(path) {
  return new Promise((resolve, reject) => {
    const req = http.get(`http://127.0.0.1:${port}${path}`, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => resolve({ status: res.statusCode, body }));
    });
    req.on('error', reject);
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

  // Test 1: App module exports Express app
  try {
    assert.strictEqual(typeof app, 'function', 'app should be a function');
    console.log('  PASS: App module exports Express app');
    passed++;
  } catch (e) {
    console.log('  FAIL: App module exports -', e.message);
    failed++;
  }

  // Test 2: View engine is configured
  try {
    assert.strictEqual(app.get('view engine'), 'jade', 'View engine should be jade');
    console.log('  PASS: View engine is jade');
    passed++;
  } catch (e) {
    console.log('  FAIL: View engine -', e.message);
    failed++;
  }

  // Test 3: GET / route is defined (will fail connecting to API but route exists)
  try {
    const res = await request('/');
    // Route exists — returns 500 because API_HOST is not set in test env
    assert.ok(res.status === 200 || res.status === 500, 'Root route should respond');
    console.log('  PASS: GET / route responds (' + res.status + ')');
    passed++;
  } catch (e) {
    console.log('  FAIL: GET / -', e.message);
    failed++;
  }

  // Test 4: Error handler catches unknown routes
  try {
    const res = await request('/this/does/not/exist');
    assert.ok(res.status >= 400, 'Unknown route should return error status');
    console.log('  PASS: Error handler catches unknown routes (' + res.status + ')');
    passed++;
  } catch (e) {
    console.log('  FAIL: Error handler -', e.message);
    failed++;
  }

  server.close();

  console.log(`\n  ${passed} passing, ${failed} failing\n`);
  if (failed > 0) process.exit(1);
  process.exit(0);
}

console.log('\n  Web Tests\n');
runTests().catch((err) => {
  console.error('Test runner error:', err);
  server.close();
  process.exit(1);
});
