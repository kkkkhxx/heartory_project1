import http from "k6/http";
import { check, sleep } from "k6";

export const options = {
  stages: [
    { duration: "10s", target: 10 },   // เริ่มเบา ๆ
    { duration: "10s", target: 30 },   // เริ่มช้า
    { duration: "10s", target: 60 },   // หน่วงหนัก
    { duration: "10s", target: 80 },   // ค้างแน่
    { duration: "20s", target: 100 },  // จุดที่ควรค้างทั้งหน้า login
    { duration: "10s", target: 0 },    // ปล่อยลดโหลด
  ],
  thresholds: {
    http_req_failed: ["rate<0.10"],      // error ได้ถึง 10%
    http_req_duration: ["p(95)<30000"],  // P95 ไม่เกิน 30s (เพื่อให้เห็นอาการค้าง)
  },
};

const LOGIN_PAGE = "http://10.34.112.158:8000/dk/account";

export default function () {
  const res = http.get(LOGIN_PAGE);

  check(res, {
    "status 200": (r) => r.status === 200,
    "HTML returned": (r) => r.headers["Content-Type"]?.includes("text/html"),
    "RT < 30s": (r) => r.timings.duration < 30000,
  });

  sleep(0.1);  // ทำให้ยิงเร็วขึ้น → หน้า Login จะค้างชัดขึ้น
}
