// API Client for standalone backend
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api';

export interface ApiResponse<T> {
  data?: T;
  error?: string;
  message?: string;
}

class ApiClient {
  private baseUrl: string;
  private token: string | null = null;

  constructor(baseUrl: string = API_BASE_URL) {
    this.baseUrl = baseUrl;
    this.token = localStorage.getItem('auth_token');
  }

  setToken(token: string) {
    this.token = token;
    localStorage.setItem('auth_token', token);
  }

  getToken(): string | null {
    return this.token || localStorage.getItem('auth_token');
  }

  clearToken() {
    this.token = null;
    localStorage.removeItem('auth_token');
  }

  private getHeaders(): HeadersInit {
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
    };

    const token = this.getToken();
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    return headers;
  }

  async request<T>(
    method: string,
    path: string,
    body?: unknown
  ): Promise<T> {
    const url = `${this.baseUrl}${path}`;
    const options: RequestInit = {
      method,
      headers: this.getHeaders(),
    };

    if (body) {
      options.body = JSON.stringify(body);
    }

    const response = await fetch(url, options);

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || `HTTP ${response.status}`);
    }

    return response.json();
  }

  async uploadFile<T>(
    method: string,
    path: string,
    file: File,
    onProgress?: (progress: number) => void
  ): Promise<T> {
    const url = `${this.baseUrl}${path}`;
    const formData = new FormData();
    formData.append('file', file);

    const headers: any = {};
    const token = this.getToken();
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const xhr = new XMLHttpRequest();
    
    return new Promise((resolve, reject) => {
      if (onProgress) {
        xhr.upload.addEventListener('progress', (e) => {
          if (e.lengthComputable) {
            onProgress((e.loaded / e.total) * 100);
          }
        });
      }

      xhr.addEventListener('load', () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          try {
            resolve(JSON.parse(xhr.responseText));
          } catch (e) {
            resolve(xhr.responseText as any);
          }
        } else {
          try {
            const error = JSON.parse(xhr.responseText);
            reject(new Error(error.error || `HTTP ${xhr.status}`));
          } catch (e) {
            reject(new Error(`HTTP ${xhr.status}`));
          }
        }
      });

      xhr.addEventListener('error', () => {
        reject(new Error('Upload failed'));
      });

      xhr.open(method, url);
      Object.entries(headers).forEach(([key, value]) => {
        xhr.setRequestHeader(key, String(value));
      });
      xhr.send(formData);
    });
  }

  // Auth endpoints
  async signup(email: string, password: string, fullName: string, role: string, collegeId?: string) {
    return this.request('POST', '/auth/signup', {
      email,
      password,
      fullName,
      role,
      collegeId,
    });
  }

  async signin(email: string, password: string) {
    return this.request('POST', '/auth/signin', { email, password });
  }

  async resetPassword(email: string) {
    return this.request('POST', '/auth/reset-password', { email });
  }

  async updatePassword(password: string) {
    return this.request('POST', '/auth/update-password', { password });
  }

  // Profile endpoints
  async getProfile() {
    return this.request('GET', '/profile');
  }

  async updateProfile(updates: any) {
    return this.request('PUT', '/profile', updates);
  }

  // Education endpoints
  async getEducation() {
    return this.request('GET', '/profile/education');
  }

  async addEducation(education: any) {
    return this.request('POST', '/profile/education', education);
  }

  async updateEducation(id: string, updates: any) {
    return this.request('PUT', `/profile/education/${id}`, updates);
  }

  async deleteEducation(id: string) {
    return this.request('DELETE', `/profile/education/${id}`);
  }

  // Experience endpoints
  async getExperience() {
    return this.request('GET', '/profile/experience');
  }

  async addExperience(experience: any) {
    return this.request('POST', '/profile/experience', experience);
  }

  async updateExperience(id: string, updates: any) {
    return this.request('PUT', `/profile/experience/${id}`, updates);
  }

  async deleteExperience(id: string) {
    return this.request('DELETE', `/profile/experience/${id}`);
  }

  // Opportunities endpoints
  async getOpportunities(params?: any) {
    const query = new URLSearchParams(params).toString();
    return this.request('GET', `/opportunities${query ? '?' + query : ''}`);
  }

  async getOpportunity(id: string) {
    return this.request('GET', `/opportunities/${id}`);
  }

  async registerForOpportunity(id: string) {
    return this.request('POST', `/opportunities/${id}/register`);
  }

  async unregisterFromOpportunity(id: string) {
    return this.request('DELETE', `/opportunities/${id}/register`);
  }

  async saveOpportunity(id: string) {
    return this.request('POST', `/opportunities/${id}/save`);
  }

  async unsaveOpportunity(id: string) {
    return this.request('DELETE', `/opportunities/${id}/save`);
  }

  // Jobs endpoints
  async getJobs(params?: any) {
    const query = new URLSearchParams(params).toString();
    return this.request('GET', `/jobs${query ? '?' + query : ''}`);
  }

  async getJob(id: string) {
    return this.request('GET', `/jobs/${id}`);
  }

  async applyJob(jobId: string, data: any) {
    return this.request('POST', `/jobs/${jobId}/apply`, data);
  }

  async saveJob(jobId: string) {
    return this.request('POST', `/jobs/${jobId}/save`);
  }

  async unsaveJob(jobId: string) {
    return this.request('DELETE', `/jobs/${jobId}/save`);
  }

  async getUserApplications() {
    return this.request('GET', '/jobs/user/applications');
  }

  async getSavedJobs() {
    return this.request('GET', '/jobs/user/saved');
  }

  // Companies endpoints
  async getCompanies(params?: any) {
    const query = new URLSearchParams(params).toString();
    return this.request('GET', `/companies${query ? '?' + query : ''}`);
  }

  async getCompany(id: string) {
    return this.request('GET', `/companies/${id}`);
  }

  async getMyCompany() {
    return this.request('GET', '/companies/profile/me');
  }

  async updateCompany(updates: any) {
    return this.request('PUT', '/companies/profile/me', updates);
  }

  async getCompanyJobs(companyId: string) {
    return this.request('GET', `/companies/${companyId}/jobs`);
  }

  // Social/Posts endpoints
  async getPosts(params?: any) {
    const query = new URLSearchParams(params).toString();
    return this.request('GET', `/posts${query ? '?' + query : ''}`);
  }

  async createPost(post: any) {
    return this.request('POST', '/posts', post);
  }

  async likePost(postId: string) {
    return this.request('POST', `/posts/${postId}/like`);
  }

  async unlikePost(postId: string) {
    return this.request('DELETE', `/posts/${postId}/like`);
  }

  async getPostComments(postId: string) {
    return this.request('GET', `/posts/${postId}/comments`);
  }

  async addComment(postId: string, content: string) {
    return this.request('POST', `/posts/${postId}/comments`, { content });
  }

  // Connections endpoints
  async getConnections() {
    return this.request('GET', '/connections');
  }

  async getPendingRequests() {
    return this.request('GET', '/connections/pending/requests');
  }

  async sendConnectionRequest(addresseeId: string) {
    return this.request('POST', '/connections/request', { addresseeId });
  }

  async acceptConnection(connectionId: string) {
    return this.request('PUT', `/connections/${connectionId}/accept`);
  }

  async rejectConnection(connectionId: string) {
    return this.request('PUT', `/connections/${connectionId}/reject`);
  }

  // Messages endpoints
  async getMessages() {
    return this.request('GET', '/messages');
  }

  async getConversation(userId: string) {
    return this.request('GET', `/messages/${userId}/conversation`);
  }

  async sendMessage(receiverId: string, content: string) {
    return this.request('POST', '/messages', { receiverId, content });
  }

  async getUnreadMessageCount() {
    return this.request('GET', '/messages/unread/count');
  }

  // Notifications endpoints
  async getNotifications(params?: any) {
    const query = new URLSearchParams(params).toString();
    return this.request('GET', `/notifications${query ? '?' + query : ''}`);
  }

  async markNotificationAsRead(id: string) {
    return this.request('PUT', `/notifications/${id}/read`);
  }

  async markAllNotificationsAsRead() {
    return this.request('PUT', '/notifications/all/read');
  }

  async getUnreadNotificationCount() {
    return this.request('GET', '/notifications/unread/count');
  }

  // File upload endpoints
  async uploadAvatar(file: File, onProgress?: (progress: number) => void) {
    return this.uploadFile('POST', '/profile/avatar', file, onProgress);
  }

  async uploadResume(file: File, onProgress?: (progress: number) => void) {
    return this.uploadFile('POST', '/profile/resume', file, onProgress);
  }

  async uploadCertificate(file: File, onProgress?: (progress: number) => void) {
    return this.uploadFile('POST', '/profile/certificate', file, onProgress);
  }

  async uploadProjectImage(file: File, onProgress?: (progress: number) => void) {
    return this.uploadFile('POST', '/profile/project-image', file, onProgress);
  }

  async deleteFile(path: string) {
    return this.request('POST', '/files/delete', { path });
  }
}

export const apiClient = new ApiClient();
export default apiClient;
