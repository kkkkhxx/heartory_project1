import http from "k6/http";
import { check } from "k6";

export const options = {
  scenarios: {
    spike: {
      executor: "constant-arrival-rate",
      rate: 300,               // 300 requests ต่อวินาที 🔥
      timeUnit: "1s",
      duration: "20s",
      preAllocatedVUs: 50,
      maxVUs: 500,
    },
  },
  thresholds: {
    http_req_failed: ["rate<0.50"],     // คาดว่าจะ fail เยอะ
    http_req_duration: ["p(95)<20000"], // อนุญาตให้ช้ามาก
  },
};

export default function () {
  const res = http.get("http://10.34.112.158:8000/dk/store");

  check(res, {
    "status OK": (r) => r.status === 200,
  });
}
