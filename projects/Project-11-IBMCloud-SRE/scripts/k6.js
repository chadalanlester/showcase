import http from 'k6/http'; import { sleep, check } from 'k6';
export const options = { vus: 20, duration: '30s' };
export default function () {
  const r = http.get(`${__ENV.APP_URL}/healthz`);
  check(r, { '200': x => x.status === 200 });
  sleep(0.2);
}
