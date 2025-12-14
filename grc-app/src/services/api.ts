import axios from 'axios';
import type {
  Athlete,
  Race,
  RaceResult,
  Workout,
  AthleteNickname,
  ReviewFlag,
  Email,
  AthleteDetails,
  EmailDetails,
  SyncEmailsRequest,
  SyncEmailsResponse,
  PaginatedResponse,
  AthleteForm,
  RaceForm,
  RaceResultForm,
  WorkoutForm,
  AthleteNicknameForm,
  ReviewFlagResolveForm,
  YearlyStats
} from '../types/api.ts';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080/api/v1';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor for adding auth headers if needed
api.interceptors.request.use((config) => {
  // Add admin API key for admin endpoints
  if (config.url?.includes('/sync_emails') ||
      config.url?.includes('/review_flags') ||
      config.url?.includes('/emails')) {
    const adminKey = import.meta.env.VITE_ADMIN_API_KEY;
    if (adminKey) {
      config.headers.Authorization = `Bearer ${adminKey}`;
    }
  }
  return config;
});

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error);
    return Promise.reject(error);
  }
);

// Athletes API
export const athletesApi = {
  getAll: () => api.get<PaginatedResponse<Athlete>>('/athletes'),
  getAllDetails: () => api.get<AthleteDetails[]>('/athletes/details'),
  getById: (id: number) => api.get<Athlete>(`/athletes/${id}`),
  getDetails: (id: number) => api.get<AthleteDetails>(`/athletes/${id}/details`),
  create: (data: AthleteForm) => api.post<Athlete>('/athletes', data),
  update: (id: number, data: Partial<AthleteForm>) => api.put<Athlete>(`/athletes/${id}`, data),
  delete: (id: number) => api.delete(`/athletes/${id}`),
};

// Races API
export const racesApi = {
  getAll: () => api.get<PaginatedResponse<Race>>('/races'),
  getById: (id: number) => api.get<Race>(`/races/${id}`),
  create: (data: RaceForm) => api.post<Race>('/races', data),
  update: (id: number, data: Partial<RaceForm>) => api.put<Race>(`/races/${id}`, data),
  delete: (id: number) => api.delete(`/races/${id}`),
};

// Race Results API
export const raceResultsApi = {
  getAll: () => api.get<PaginatedResponse<RaceResult>>('/race_results'),
  getById: (id: number) => api.get<RaceResult>(`/race_results/${id}`),
  create: (data: RaceResultForm) => api.post<RaceResult>('/race_results', data),
  update: (id: number, data: Partial<RaceResultForm>) => api.put<RaceResult>(`/race_results/${id}`, data),
  delete: (id: number) => api.delete(`/race_results/${id}`),
};

// Workouts API
export const workoutsApi = {
  getAll: () => api.get<PaginatedResponse<Workout>>('/workouts'),
  getById: (id: number) => api.get<Workout>(`/workouts/${id}`),
  create: (data: WorkoutForm) => api.post<Workout>('/workouts', data),
  update: (id: number, data: Partial<WorkoutForm>) => api.put<Workout>(`/workouts/${id}`, data),
  delete: (id: number) => api.delete(`/workouts/${id}`),
};

// Yearly Stats API
export const yearlyStatsApi = {
  get: () => api.get<YearlyStats>('/yearly_stats'),
};

// Athlete Nicknames API
export const athleteNicknamesApi = {
  getAll: () => api.get<PaginatedResponse<AthleteNickname>>('/athlete_nicknames'),
  getById: (id: number) => api.get<AthleteNickname>(`/athlete_nicknames/${id}`),
  create: (data: AthleteNicknameForm) => api.post<AthleteNickname>('/athlete_nicknames', data),
  update: (id: number, data: AthleteNicknameForm) => api.put<AthleteNickname>(`/athlete_nicknames/${id}`, data),
  delete: (id: number) => api.delete(`/athlete_nicknames/${id}`),
};

// Review Flags API (Admin)
export const reviewFlagsApi = {
  getAll: () => api.get<PaginatedResponse<ReviewFlag>>('/review_flags'),
  getById: (id: number) => api.get<ReviewFlag>(`/review_flags/${id}`),
  resolve: (id: number, data: ReviewFlagResolveForm) => api.put(`/review_flags/${id}/resolve`, data),
};

// Emails API (Admin)
export const emailsApi = {
  getAll: () => api.get<PaginatedResponse<Email>>('/emails'),
  getById: (id: number) => api.get<Email>(`/emails/${id}`),
  getDetails: (id: number) => api.get<EmailDetails>(`/emails/${id}/details`),
};

// Admin API
export const adminApi = {
  syncEmails: (data: SyncEmailsRequest) => api.post<SyncEmailsResponse>('/sync_emails', data),
};

export default api;