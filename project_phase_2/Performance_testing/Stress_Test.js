import http from "k6/http";
import { check, sleep } from "k6";

export const options = {
  stages: [
    { duration: "10s", target: 5 },     // เริ่มเบาๆ
    { duration: "10s", target: 10 },    // โหลดปานกลาง
    { duration: "10s", target: 20 },    // เริ่มหนัก
    { duration: "10s", target: 30 },    // จุดที่ SSR เริ่มอิ่มตัว
    { duration: "10s", target: 40 },    // ใกล้พัง
    { duration: "10s", target: 50 },    // ทดสอบจุดวิกฤต
    { duration: "10s", target: 0 },     // ปล่อยลง
  ],
  thresholds: {
    http_req_failed: ["rate<0.05"],      // Error ต้อง < 5%
    http_req_duration: ["p(95)<5000"],   // 95% ไม่เกิน 5 วิ
  },
};

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
    "status 200": (r) => r.status === 200,
    "HTML": (r) => r.headers["Content-Type"]?.includes("text/html"),
    "RT < 5s": (r) => r.timings.duration < 5000,
  });

  sleep(0.5); 
}
