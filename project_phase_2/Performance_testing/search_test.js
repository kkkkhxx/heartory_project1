import http from 'k6/http';
import { sleep, check } from 'k6';

export const options = {
  stages: [
    { duration: '10s', target: 10 },   // Ramp-up users
    { duration: '20s', target: 10 },   // Steady load
    { duration: '10s', target: 0 },    // Ramp-down
  ],
  thresholds: {
    http_req_duration: ['p(95)<800'],  // 95% response < 800ms
    http_req_failed: ['rate<0.01'],    // < 1% error rate
  },
};

//  Product names to simulate user search
const SEARCH_KEYWORDS = [
  "shirt",
  "black",
  "mu",
  "t-shirt",
  "tee",
  "store"
];

const BASE_URL = "http://10.34.112.158:8000/store";

export default function () {
  // Random keyword
  const keyword = SEARCH_KEYWORDS[Math.floor(Math.random() * SEARCH_KEYWORDS.length)];

  // API endpoint Medusa Storefront search
  const url = `${BASE_URL}/products?search=${keyword}`;

  const res = http.get(url, {
    tags: { name: 'SearchProduct' }
  });

  // Validate result
  check(res, {
    "status is 200": (r) => r.status === 200,
    "response time < 1s": (r) => r.timings.duration < 1000,
    "returns JSON": (r) => r.headers["Content-Type"]?.includes("application/json"),
  });

  sleep(1); // simulate user think-time
}
