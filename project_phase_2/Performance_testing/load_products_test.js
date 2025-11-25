import http from "k6/http";
import { sleep, check } from "k6";

export let options = {
  stages: [
    { duration: "10s", target: 50 },
    { duration: "20s", target: 200 },
    { duration: "10s", target: 0 },
  ],
};

const BASE_URL = "http://10.34.112.158:8000";

export default function () {
  let res = http.get(`${BASE_URL}/store/products`);

  check(res, {
    "status is 200": (r) => r.status === 200,
    "response < 500ms": (r) => r.timings.duration < 500,
  });

  sleep(1);
}
