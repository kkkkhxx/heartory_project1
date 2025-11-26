import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 8,              // จำนวนผู้ใช้พร้อมกันคงที่ (เหมาะกับเว็บคุณ)
  duration: '15m',     // Soak Test 15 นาที (กำลังดี)
  thresholds: {
    http_req_failed: ['rate<0.05'],     // <5% error ถือว่ายอมรับได้ใน Soak
    http_req_duration: ['p(95)<3000'],  // 95% ไม่เกิน 3s (เหมาะกับ SSR)
  },
};

// หน้าเว็บสำคัญที่ต้องทดสอบ Frontend
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
    "HTML returned": r =>
      r.headers["Content-Type"]?.includes("text/html"),
    "RT < 3s": r => r.timings.duration < 3000,
  });

  sleep(1 + Math.random() * 2); // think-time 1–3s (realistic)
}
