// Base API Client for LMS Backend Integration
// Handles authentication, error handling, and type-safe requests

export interface ApiResponse<T = any> {
  data: T;
  message?: string;
  success: boolean;
  status: number;
}

export interface User {
  id: number;
  email: string;
  name: string;
  role: string;
  ldap_username?: string;
  created_at: string;
  updated_at: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  user: User;
  token: string;
  expires_in: number;
}

export interface Competency {
  id: number;
  name: string;
  description: string;
  category: string;
  level: 'beginner' | 'intermediate' | 'advanced' | 'expert';
  color?: string;
  created_at: string;
  updated_at: string;
}

export interface Position {
  id: number;
  title: string;
  department: string;
  description: string;
  requirements: string[];
  competencies: Competency[];
  salary_range?: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface NewsItem {
  id: number;
  title: string;
  content: string;
  summary: string;
  author: string;
  category: string;
  tags: string[];
  published_at: string;
  is_featured: boolean;
  image_url?: string;
}

// API Configuration
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api';

class ApiClient {
  private baseURL: string;
  private token: string | null = null;

  constructor(baseURL: string = API_BASE_URL) {
    this.baseURL = baseURL;
    this.token = localStorage.getItem('auth_token');
  }

  // Set authentication token
  setToken(token: string | null) {
    this.token = token;
    if (token) {
      localStorage.setItem('auth_token', token);
    } else {
      localStorage.removeItem('auth_token');
    }
  }

  // Get current token
  getToken(): string | null {
    return this.token || localStorage.getItem('auth_token');
  }

  // Base request method with error handling
  private async request<T = any>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<ApiResponse<T>> {
    const url = `${this.baseURL}${endpoint}`;
    
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...(options.headers as Record<string, string>),
    };

    // Add authentication header if token exists
    const token = this.getToken();
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    try {
      const response = await fetch(url, {
        ...options,
        headers,
      });

      const data = await response.json();

      // Handle authentication errors
      if (response.status === 401) {
        this.setToken(null);
        window.location.href = '/login';
        throw new Error('Authentication failed');
      }

      // Handle other HTTP errors
      if (!response.ok) {
        throw new Error(data.message || `HTTP Error: ${response.status}`);
      }

      return {
        data: data.data || data,
        message: data.message,
        success: response.ok,
        status: response.status,
      };
    } catch (error) {
      console.error('API Request failed:', error);
      throw error;
    }
  }

  // HTTP Methods
  async get<T = any>(endpoint: string): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, { method: 'GET' });
  }

  async post<T = any>(endpoint: string, data?: any): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: data ? JSON.stringify(data) : undefined,
    });
  }

  async put<T = any>(endpoint: string, data?: any): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, {
      method: 'PUT',
      body: data ? JSON.stringify(data) : undefined,
    });
  }

  async delete<T = any>(endpoint: string): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, { method: 'DELETE' });
  }

  // Authentication endpoints
  async login(credentials: LoginRequest): Promise<ApiResponse<LoginResponse>> {
    const response = await this.post<LoginResponse>('/auth/login', credentials);
    if (response.success && response.data.token) {
      this.setToken(response.data.token);
    }
    return response;
  }

  async logout(): Promise<ApiResponse<any>> {
    try {
      await this.post('/auth/logout');
    } finally {
      this.setToken(null);
    }
    return { data: null, success: true, status: 200 };
  }

  async getCurrentUser(): Promise<ApiResponse<User>> {
    return this.get<User>('/auth/me');
  }

  // Competencies endpoints
  async getCompetencies(params?: { 
    category?: string; 
    level?: string; 
    search?: string;
  }): Promise<ApiResponse<Competency[]>> {
    const queryParams = new URLSearchParams();
    if (params?.category) queryParams.append('category', params.category);
    if (params?.level) queryParams.append('level', params.level);
    if (params?.search) queryParams.append('search', params.search);
    
    const endpoint = `/competencies${queryParams.toString() ? `?${queryParams}` : ''}`;
    return this.get<Competency[]>(endpoint);
  }

  async getCompetency(id: number): Promise<ApiResponse<Competency>> {
    return this.get<Competency>(`/competencies/${id}`);
  }

  // Positions endpoints
  async getPositions(params?: {
    department?: string;
    is_active?: boolean;
    search?: string;
  }): Promise<ApiResponse<Position[]>> {
    const queryParams = new URLSearchParams();
    if (params?.department) queryParams.append('department', params.department);
    if (params?.is_active !== undefined) queryParams.append('is_active', String(params.is_active));
    if (params?.search) queryParams.append('search', params.search);
    
    const endpoint = `/positions${queryParams.toString() ? `?${queryParams}` : ''}`;
    return this.get<Position[]>(endpoint);
  }

  async getPosition(id: number): Promise<ApiResponse<Position>> {
    return this.get<Position>(`/positions/${id}`);
  }

  // News endpoints
  async getNews(params?: {
    category?: string;
    is_featured?: boolean;
    limit?: number;
    page?: number;
  }): Promise<ApiResponse<NewsItem[]>> {
    const queryParams = new URLSearchParams();
    if (params?.category) queryParams.append('category', params.category);
    if (params?.is_featured !== undefined) queryParams.append('is_featured', String(params.is_featured));
    if (params?.limit) queryParams.append('limit', String(params.limit));
    if (params?.page) queryParams.append('page', String(params.page));
    
    const endpoint = `/news${queryParams.toString() ? `?${queryParams}` : ''}`;
    return this.get<NewsItem[]>(endpoint);
  }

  async getNewsItem(id: number): Promise<ApiResponse<NewsItem>> {
    return this.get<NewsItem>(`/news/${id}`);
  }
}

// Export singleton instance
export const apiClient = new ApiClient();
export default apiClient; 