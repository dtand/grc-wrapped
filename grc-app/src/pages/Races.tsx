import React, { useEffect, useMemo, useState } from 'react';
import Layout from '../components/Layout';
import { athletesApi } from '../services/api';
import type { AthleteDetails } from '../types/api';

// Flattened performance row for table display
interface PerformanceRow {
  id: number;
  athlete: string;
  race: string;
  dateRecorded: string;
  distance: string;
  time: string;
  isPr: boolean;
  isClubRecord: boolean;
}

const Races: React.FC = () => {
  const [allDetails, setAllDetails] = useState<AthleteDetails[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      setError(null);
      try {
        // Fetch all athlete details in one call
        const res = await athletesApi.getAllDetails();
        setAllDetails(res.data || []);
      } catch (e: any) {
        setError(e?.response?.data?.message || e?.message || 'Unknown error');
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  // Helper to safely extract string values from potential sql.NullString objects
  const extractValue = (val: any): string => {
    if (!val) return '';
    if (typeof val === 'string') return val;
    if (typeof val === 'object' && 'String' in val) return val.String || '';
    return String(val);
  };

  // Flatten athlete details into simple performance rows
  const performances: PerformanceRow[] = useMemo(() => {
    const rows: PerformanceRow[] = [];
    
    // First, collect ALL performances from ALL athletes into flat array
    for (const detail of allDetails) {
      const athleteName = extractValue(detail.athlete?.name);
      
      (detail.race_performances || []).forEach((perf) => {
        if (perf.race_result && perf.race) {
          rows.push({
            id: perf.race_result.id,
            athlete: athleteName,
            race: extractValue(perf.race.name),
            dateRecorded: extractValue(perf.race_result.date_recorded || perf.race.date),
            distance: extractValue(perf.race.distance),
            time: extractValue(perf.race_result.time),
            isPr: perf.race_result.is_pr || false,
            isClubRecord: perf.race_result.is_club_record || false,
          });
        }
      });
    }
    
    // Now sort the completely flat array ONLY by dateRecorded desc (most recent first)
    // This breaks any athlete-level grouping
    rows.sort((a, b) => {
      return b.dateRecorded.localeCompare(a.dateRecorded);
    });
    
    return rows;
  }, [allDetails]);

  return (
    <Layout>
      <div className="dashboard-container" style={{ maxWidth: 1400, margin: '0 auto', padding: '24px' }}>
        <h1 className="dashboard-title">Performances</h1>
        <p className="dashboard-subtitle">Club race results pulled from athlete details</p>

        {loading && <div>Loading athletes and performances…</div>}
        {error && <div style={{ color: 'crimson' }}>Error: {error}</div>}

        {!loading && !error && (
          <div style={{ overflowX: 'auto', marginTop: 16 }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', minWidth: 1000 }}>
              <thead>
                <tr style={{ textAlign: 'left', borderBottom: '1px solid #e5e7eb' }}>
                  <th style={{ padding: '12px 8px' }}>Athlete</th>
                  <th style={{ padding: '12px 8px' }}>Race</th>
                  <th style={{ padding: '12px 8px' }}>Date Recorded</th>
                  <th style={{ padding: '12px 8px' }}>Distance</th>
                  <th style={{ padding: '12px 8px' }}>Time</th>
                </tr>
              </thead>
              <tbody>
                {performances.map((perf) => {
                  // Safely extract string values from potential sql.NullString objects
                  const getValue = (val: any): string => {
                    if (!val) return '';
                    if (typeof val === 'string') return val;
                    if (typeof val === 'object' && 'String' in val) return val.String || '';
                    return String(val);
                  };

                  // Format time as HH:MM:SS.ms (omit hours if 0, omit ms if 0)
                  const formatTime = (timeStr: string): string => {
                    if (!timeStr) return '';
                    
                    // Parse time string (assume format like "01:23:45.67" or "23:45")
                    const parts = timeStr.split(':');
                    if (parts.length === 0) return timeStr;
                    
                    // Handle HH:MM:SS.ms or MM:SS or MM:SS.ms
                    let hours = 0, minutes = 0, seconds = 0, milliseconds = 0;
                    
                    if (parts.length === 3) {
                      hours = parseInt(parts[0]) || 0;
                      minutes = parseInt(parts[1]) || 0;
                      const secParts = parts[2].split('.');
                      seconds = parseInt(secParts[0]) || 0;
                      milliseconds = secParts[1] ? parseInt(secParts[1]) || 0 : 0;
                    } else if (parts.length === 2) {
                      minutes = parseInt(parts[0]) || 0;
                      const secParts = parts[1].split('.');
                      seconds = parseInt(secParts[0]) || 0;
                      milliseconds = secParts[1] ? parseInt(secParts[1]) || 0 : 0;
                    } else {
                      return timeStr;
                    }
                    
                    // Build output string - no leading zeros
                    let result = '';
                    if (hours > 0) {
                      result += `${hours}:`;
                      result += `${minutes.toString().padStart(2, '0')}:`;
                    } else {
                      result += `${minutes}:`;
                    }
                    result += seconds.toString().padStart(2, '0');
                    if (milliseconds > 0) {
                      result += `.${milliseconds.toString().padStart(2, '0')}`;
                    }
                    return result;
                  };

                  // Format date as yyyy-mm-dd (strip time)
                  const formatDate = (dateStr: string): string => {
                    if (!dateStr) return '';
                    
                    // If it's already in yyyy-mm-dd format, return as-is
                    if (/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) return dateStr;
                    
                    // Parse ISO date or other formats and extract date portion
                    try {
                      const date = new Date(dateStr);
                      if (isNaN(date.getTime())) return dateStr.split('T')[0] || dateStr;
                      const year = date.getFullYear();
                      const month = (date.getMonth() + 1).toString().padStart(2, '0');
                      const day = date.getDate().toString().padStart(2, '0');
                      return `${year}-${month}-${day}`;
                    } catch {
                      return dateStr.split('T')[0] || dateStr;
                    }
                  };

                  // Build indicator string (PR, CR, or PR, CR)
                  const indicators: string[] = [];
                  if (perf.isPr) indicators.push('PR');
                  if (perf.isClubRecord) indicators.push('CR');
                  const indicatorText = indicators.length > 0 ? ` (${indicators.join(', ')})` : '';

                  return (
                    <tr key={`perf-${perf.id}`} style={{ borderBottom: '1px solid #f1f5f9' }}>
                      <td style={{ padding: '10px 8px', fontWeight: 600 }}>{getValue(perf.athlete)}</td>
                      <td style={{ padding: '10px 8px' }}>{getValue(perf.race)}</td>
                      <td style={{ padding: '10px 8px' }}>{formatDate(getValue(perf.dateRecorded))}</td>
                      <td style={{ padding: '10px 8px' }}>{getValue(perf.distance)}</td>
                      <td style={{ padding: '10px 8px', fontWeight: (perf.isPr || perf.isClubRecord) ? 700 : 400 }}>
                        {formatTime(getValue(perf.time))}{indicatorText}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </Layout>
  );
};

export default Races;
