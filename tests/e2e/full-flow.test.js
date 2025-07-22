const axios = require('axios');
const { expect } = require('chai');

// Test configuration
const API_BASE_URL = process.env.API_URL || 'http://localhost:8080/api/v1';
const TEST_USER = {
  email: 'test.user@tsum.ru',
  password: 'TestPassword123!',
  name: 'Test User',
  role: 'Student'
};

let authToken = null;
let userId = null;
let courseId = null;
let assessmentId = null;

describe('LMS Full User Flow E2E Test', () => {
  
  // Step 1: User Registration and Authentication
  describe('Authentication Flow', () => {
    it('should register a new user', async () => {
      const response = await axios.post(`${API_BASE_URL}/users`, TEST_USER);
      
      expect(response.status).to.equal(201);
      expect(response.data).to.have.property('id');
      expect(response.data.email).to.equal(TEST_USER.email);
      
      userId = response.data.id;
    });
    
    it('should login with credentials', async () => {
      const response = await axios.post(`${API_BASE_URL}/auth/login`, {
        email: TEST_USER.email,
        password: TEST_USER.password
      });
      
      expect(response.status).to.equal(200);
      expect(response.data).to.have.property('access_token');
      expect(response.data).to.have.property('refresh_token');
      
      authToken = response.data.access_token;
    });
    
    it('should verify authentication', async () => {
      const response = await axios.get(`${API_BASE_URL}/auth/verify`, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      
      expect(response.status).to.equal(200);
      expect(response.data.user.id).to.equal(userId);
    });
  });
  
  // Step 2: Course Discovery and Enrollment
  describe('Course Management Flow', () => {
    it('should list available courses', async () => {
      const response = await axios.get(`${API_BASE_URL}/courses`, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      
      expect(response.status).to.equal(200);
      expect(response.data).to.be.an('array');
      expect(response.data.length).to.be.greaterThan(0);
      
      // Select first course for enrollment
      courseId = response.data[0].id;
    });
    
    it('should get course details', async () => {
      const response = await axios.get(`${API_BASE_URL}/courses/${courseId}`, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      
      expect(response.status).to.equal(200);
      expect(response.data.id).to.equal(courseId);
      expect(response.data).to.have.property('modules');
      expect(response.data).to.have.property('competencies');
    });
    
    it('should enroll in course', async () => {
      const response = await axios.post(
        `${API_BASE_URL}/courses/${courseId}/enroll`,
        {},
        { headers: { Authorization: `Bearer ${authToken}` } }
      );
      
      expect(response.status).to.equal(201);
      expect(response.data).to.have.property('enrollment_id');
      expect(response.data.status).to.equal('active');
    });
    
    it('should track course progress', async () => {
      // Complete first module
      const progressResponse = await axios.post(
        `${API_BASE_URL}/courses/${courseId}/progress`,
        { module_id: 'module_1', completed: true },
        { headers: { Authorization: `Bearer ${authToken}` } }
      );
      
      expect(progressResponse.status).to.equal(200);
      
      // Get updated progress
      const response = await axios.get(
        `${API_BASE_URL}/courses/${courseId}/progress`,
        { headers: { Authorization: `Bearer ${authToken}` } }
      );
      
      expect(response.status).to.equal(200);
      expect(response.data.completed_modules).to.include('module_1');
      expect(response.data.progress_percentage).to.be.greaterThan(0);
    });
  });
  
  // Step 3: Competency Assessment
  describe('Competency Assessment Flow', () => {
    let competencyId = null;
    
    it('should list user competencies', async () => {
      const response = await axios.get(`${API_BASE_URL}/competencies`, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      
      expect(response.status).to.equal(200);
      expect(response.data).to.be.an('array');
      
      competencyId = response.data[0].id;
    });
    
    it('should create assessment', async () => {
      const response = await axios.post(
        `${API_BASE_URL}/assessments`,
        {
          competency_id: competencyId,
          user_id: userId,
          score: 85,
          comments: 'E2E test assessment'
        },
        { headers: { Authorization: `Bearer ${authToken}` } }
      );
      
      expect(response.status).to.equal(201);
      expect(response.data).to.have.property('id');
      expect(response.data.score).to.equal(85);
      
      assessmentId = response.data.id;
    });
    
    it('should get competency matrix', async () => {
      const response = await axios.get(`${API_BASE_URL}/competencies/matrix`, {
        headers: { Authorization: `Bearer ${authToken}` },
        params: { user_id: userId }
      });
      
      expect(response.status).to.equal(200);
      expect(response.data).to.have.property('competencies');
      expect(response.data).to.have.property('overall_progress');
    });
  });
  
  // Step 4: Notifications
  describe('Notification Flow', () => {
    it('should receive notifications', async () => {
      const response = await axios.get(`${API_BASE_URL}/notifications`, {
        headers: { Authorization: `Bearer ${authToken}` }
      });
      
      expect(response.status).to.equal(200);
      expect(response.data).to.be.an('array');
      // Should have notifications about enrollment and assessment
      expect(response.data.length).to.be.greaterThan(0);
    });
  });
  
  // Step 5: Complete Course
  describe('Course Completion Flow', () => {
    it('should complete the course', async () => {
      const response = await axios.post(
        `${API_BASE_URL}/courses/${courseId}/complete`,
        {},
        { headers: { Authorization: `Bearer ${authToken}` } }
      );
      
      expect(response.status).to.equal(200);
      expect(response.data).to.have.property('certificate_id');
      expect(response.data.status).to.equal('completed');
    });
  });
  
  // Cleanup
  after(async () => {
    if (userId && authToken) {
      try {
        await axios.delete(`${API_BASE_URL}/users/${userId}`, {
          headers: { Authorization: `Bearer ${authToken}` }
        });
      } catch (error) {
        console.log('Cleanup failed:', error.message);
      }
    }
  });
});

// Performance tests
describe('Performance Tests', () => {
  it('should handle concurrent requests', async () => {
    const promises = [];
    const concurrentRequests = 50;
    
    for (let i = 0; i < concurrentRequests; i++) {
      promises.push(
        axios.get(`${API_BASE_URL}/courses`, {
          headers: { Authorization: `Bearer ${authToken}` }
        })
      );
    }
    
    const start = Date.now();
    const results = await Promise.all(promises);
    const duration = Date.now() - start;
    
    expect(results.every(r => r.status === 200)).to.be.true;
    expect(duration).to.be.lessThan(5000); // All requests should complete within 5 seconds
  });
  
  it('should respect rate limits', async () => {
    const requests = [];
    
    // Try to exceed rate limit (5 requests per minute for login)
    for (let i = 0; i < 10; i++) {
      requests.push(
        axios.post(`${API_BASE_URL}/auth/login`, {
          email: `test${i}@example.com`,
          password: 'password'
        }).catch(err => err.response)
      );
    }
    
    const responses = await Promise.all(requests);
    const rateLimited = responses.filter(r => r.status === 429);
    
    expect(rateLimited.length).to.be.greaterThan(0);
  });
}); 