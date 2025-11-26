import http from 'k6/http';
import { sleep, check } from 'k6';

export const options = {
  stages: [
    { duration: '10s', target: 10 },  // ramp up to 10 VUs
    { duration: '20s', target: 10 },  // sustain 10 VUs
    { duration: '10s', target: 0 },   // ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<1000'],  // 95% page load < 1s
    http_req_failed: ['rate<0.01'],     // <1% errors
  },
};

// หน้าเว็บที่ต้องการทดสอบ
const PAGES = [
  "http://10.34.112.158:8000/dk/store",
  "http://10.34.112.158:8000/dk/products/t-shirt",
  "http://10.34.112.158:8000/dk/products/sikkhim",
  "http://10.34.112.158:8000/dk/cart",
];

export default function () {

  const url = PAGES[Math.floor(Math.random() * PAGES.length)];
  const res = http.get(url);

  check(res, {
    "status 200": r => r.status === 200,
    "HTML returned": r => r.headers["Content-Type"]?.includes("text/html"),
    "page < 1s": r => r.timings.duration < 1000,
  });

  sleep(1);
}
