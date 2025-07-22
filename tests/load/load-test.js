import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const courseListSuccessRate = new Rate('course_list_success');
const enrollmentSuccessRate = new Rate('enrollment_success');

// Test configuration
export const options = {
  stages: [
    { duration: '30s', target: 10 },   // Ramp up to 10 users
    { duration: '1m', target: 50 },    // Ramp up to 50 users
    { duration: '2m', target: 100 },   // Stay at 100 users
    { duration: '1m', target: 200 },   // Peak load - 200 users
    { duration: '2m', target: 200 },   // Stay at peak
    { duration: '1m', target: 50 },    // Ramp down to 50
    { duration: '30s', target: 0 },    // Ramp down to 0
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% of requests must complete below 500ms
    http_req_failed: ['rate<0.1'],     // Error rate must be below 10%
    errors: ['rate<0.1'],              // Custom error rate below 10%
  },
};

const BASE_URL = __ENV.API_URL || 'http://localhost:8080/api/v1';

// Test data
const TEST_USERS = [
  { email: 'student1@tsum.ru', password: 'Test123!' },
  { email: 'student2@tsum.ru', password: 'Test123!' },
  { email: 'student3@tsum.ru', password: 'Test123!' },
  { email: 'manager1@tsum.ru', password: 'Test123!' },
  { email: 'admin1@tsum.ru', password: 'Test123!' },
];

// Helper function to get auth token
function authenticate(user) {
  const payload = JSON.stringify({
    email: user.email,
    password: user.password,
  });

  const params = {
    headers: { 'Content-Type': 'application/json' },
  };

  const loginRes = http.post(`${BASE_URL}/auth/login`, payload, params);
  
  const loginSuccess = check(loginRes, {
    'login successful': (r) => r.status === 200,
    'has access token': (r) => r.json('access_token') !== undefined,
  });

  errorRate.add(!loginSuccess);

  if (loginSuccess) {
    return loginRes.json('access_token');
  }
  return null;
}

// Main test scenario
export default function () {
  // Select random user
  const user = TEST_USERS[Math.floor(Math.random() * TEST_USERS.length)];
  
  // Step 1: Authentication
  const token = authenticate(user);
  if (!token) {
    errorRate.add(1);
    return;
  }

  const authHeaders = {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
  };

  // Step 2: Browse courses
  const coursesRes = http.get(`${BASE_URL}/courses`, authHeaders);
  const coursesSuccess = check(coursesRes, {
    'courses loaded': (r) => r.status === 200,
    'has courses': (r) => r.json('length') > 0,
    'response time OK': (r) => r.timings.duration < 300,
  });

  courseListSuccessRate.add(coursesSuccess);
  errorRate.add(!coursesSuccess);

  if (!coursesSuccess) {
    return;
  }

  sleep(1); // Think time

  // Step 3: View course details
  const courses = coursesRes.json();
  if (courses && courses.length > 0) {
    const randomCourse = courses[Math.floor(Math.random() * courses.length)];
    
    const courseDetailRes = http.get(
      `${BASE_URL}/courses/${randomCourse.id}`,
      authHeaders
    );

    check(courseDetailRes, {
      'course details loaded': (r) => r.status === 200,
      'has modules': (r) => r.json('modules') !== undefined,
    });

    sleep(2); // Reading course details

    // Step 4: Enroll in course (30% of users)
    if (Math.random() < 0.3) {
      const enrollRes = http.post(
        `${BASE_URL}/courses/${randomCourse.id}/enroll`,
        '{}',
        authHeaders
      );

      const enrollSuccess = check(enrollRes, {
        'enrollment successful': (r) => r.status === 201 || r.status === 200,
      });

      enrollmentSuccessRate.add(enrollSuccess);
      errorRate.add(!enrollSuccess);
    }
  }

  // Step 5: Check competencies (50% of users)
  if (Math.random() < 0.5) {
    const competenciesRes = http.get(`${BASE_URL}/competencies`, authHeaders);
    
    check(competenciesRes, {
      'competencies loaded': (r) => r.status === 200,
    });

    sleep(1);
  }

  // Step 6: View notifications (70% of users)
  if (Math.random() < 0.7) {
    const notificationsRes = http.get(`${BASE_URL}/notifications`, authHeaders);
    
    check(notificationsRes, {
      'notifications loaded': (r) => r.status === 200,
    });
  }

  sleep(Math.random() * 3); // Random think time between actions
}

// Stress test scenario
export function stressTest() {
  const user = TEST_USERS[0];
  const token = authenticate(user);
  
  if (!token) return;

  const authHeaders = {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
  };

  // Rapid fire requests
  for (let i = 0; i < 10; i++) {
    http.get(`${BASE_URL}/courses`, authHeaders);
  }
}

// Spike test scenario
export function spikeTest() {
  // Simulate sudden spike in traffic
  const responses = [];
  
  for (let i = 0; i < 50; i++) {
    responses.push(
      http.get(`${BASE_URL}/health`, { tags: { name: 'HealthCheck' } })
    );
  }

  const allSuccess = responses.every(r => r.status === 200);
  check(allSuccess, {
    'handled spike': () => allSuccess,
  });
} 