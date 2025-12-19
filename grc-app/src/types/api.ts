// API Types for GRC Running Club
export interface Athlete {
  id: number;
  name: string;
  gender: string;
  active: boolean;
  website_url?: string;
}

export interface Race {
  id: number;
  name: string;
  date: string;
  year: string;
  distance: string;
  notes?: string;
  email_id: number;
}

export interface RaceResult {
  id: number;
  race_id: number;
  athlete_id?: number;
  unknown_athlete_name?: string;
  time: string;
  pr_improvement?: string;
  notes?: string;
  position?: number;
  is_pr: boolean;
  is_club_record: boolean;
  tags?: string[];
  flagged: boolean;
  flag_reason?: string;
  email_id: number;
  date_recorded?: string;
  actual_distance?: string;
}

export interface WorkoutSegment {
  segment_type: string;
  repetitions?: number;
  rest?: string;
  targets?: string;
}

export interface WorkoutGroup {
  group_name: string;
  description?: string;
  segments: WorkoutSegment[];
}

export interface Workout {
  id: number;
  date: string;
  location: string;
  start_time?: string;
  coach_notes?: string;
  email_id: number;
  groups?: WorkoutGroup[];
}

export interface AthleteNickname {
  id: number;
  athlete_id: number;
  nickname: string;
}

export interface ReviewFlag {
  id: number;
  flag_type: string;
  entity_type: string;
  entity_id: number;
  reason?: string;
  mentioned_name?: string;
  matched_athlete_id?: number;
  resolved: boolean;
  resolved_by?: string;
  resolved_at?: string;
  created_at: string;
}

export interface Email {
  id: number;
  title: string;
  body: string;
  date: string;
  sender: string;
  recipient: string;
}

// Detailed response types
export interface AthleteDetails {
  athlete: Athlete;
  race_performances: Array<{
    race_result: RaceResult;
    race: Race;
  }>;
  nicknames: AthleteNickname[];
}

export interface EmailDetails {
  email: Email;
  athletes: Athlete[];
  races: Race[];
  race_results: RaceResult[];
  workouts: Workout[];
}

// Sync emails types
export interface SyncEmailsRequest {
  start_date: string;
  sender: string;
  recipient: string;
}

export interface SyncEmailsResponse {
  emails_processed: number;
  records_created: {
    athletes: number;
    races: number;
    race_results: number;
    workouts: number;
  };
  errors: string[];
}

// API Response types
export interface ApiResponse<T> {
  data?: T;
  error?: string;
  message?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  limit: number;
  offset: number;
}

// Form types
export interface AthleteForm {
  name: string;
  gender: string;
  active: boolean;
  website_url?: string;
}

export interface RaceForm {
  name: string;
  date: string;
  distance: string;
  notes?: string;
  email_id: number;
}

export interface RaceResultForm {
  race_id: number;
  athlete_id?: number;
  unknown_athlete_name?: string;
  time: string;
  pr_improvement?: string;
  notes?: string;
  position?: number;
  is_pr: boolean;
  tags?: string[];
  flagged: boolean;
  flag_reason?: string;
  email_id: number;
}

export interface WorkoutForm {
  date: string;
  location: string;
  start_time?: string;
  coach_notes?: string;
  email_id: number;
  groups?: WorkoutGroup[];
}

export interface AthleteNicknameForm {
  athlete_id: number;
  nickname: string;
}

export interface ReviewFlagResolveForm {
  resolved_by: string;
}

export interface YearlyStats {
  personal_bests: number; 
  races_competed: number; 
  club_records: PerformanceList; 
  popular_races: PopularRaceEntry[];
  distance_breakdown: DistanceBreakdownEntry[];
  top_list_performances: PerformanceList;
  races_won: number;
  grc_debuts: DebutEntry[];
}

export interface PerformanceList {
  count: number;
  performances: PerformanceDetail[];
}

export interface PerformanceDetail {
  athlete_id: number;
  athlete_name: string;
  race_distance: string;
  time: string;
}

export interface PopularRaceEntry {
  name: string;
  count: number;
}

export interface DistanceBreakdownEntry {
  distance: string;
  total_races: number;
}

export interface DebutEntry {
  athlete_name: string;
}