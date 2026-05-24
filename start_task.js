const fs = require('fs');
const cp = require('child_process');

try {
    const cache = JSON.parse(fs.readFileSync(require('os').homedir() + '/.zentao-token.json', 'utf8'));
    const url = cache.url;
    const token = cache.token;

    const reqUrl = `${url}/api.php/v2/tasks/14/start`;
    const data = JSON.stringify({ realStarted: "2026-05-23" });
    const cmd = ['curl', '-s', '-X', 'PUT', reqUrl, '-H', `token: ${token}`, '-H', 'Content-Type: application/json', '-d', data];
    console.log("Running curl");
    console.log(cp.spawnSync(cmd[0], cmd.slice(1)).stdout.toString());
} catch(e) {
    console.error(e);
}
