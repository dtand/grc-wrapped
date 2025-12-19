import React, { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import { yearlyStatsApi } from '../services/api';
import type { YearlyStats } from '../types/api';
import './Dashboard.css';
import ParticipationTimeline from './ParticipationTimeline';

const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<YearlyStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Function to randomly select N items from an array
  const getRandomItems = <T,>(arr: T[], count: number): T[] => {
    const shuffled = [...arr].sort(() => 0.5 - Math.random());
    return shuffled.slice(0, count);
  };

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const response = await yearlyStatsApi.get();
        setStats(response.data);
      } catch (err) {
        setError('Failed to load yearly stats');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  if (loading) {
    return <Layout><div>Loading...</div></Layout>;
  }

  if (error) {
    return <Layout><div>Error: {error}</div></Layout>;
  }

  return (
    <Layout>
      <div className="dashboard-container">
        <div className="dashboard-header">
          <h1 className="dashboard-title">GRC Yearly Recap</h1>
          <p className="dashboard-subtitle">Here's how we crushed it this year</p>
        </div>
        {stats && (
          <>
            <div className="dashboard-stats-row">
              <div className="dashboard-stat-item">
                <span className="dashboard-stat-icon">🏆</span>
                <div className="dashboard-stat-value">{stats.personal_bests}</div>
                <div className="dashboard-stat-label">PRs Broken</div>
              </div>
              <div className="dashboard-stat-item">
                <span className="dashboard-stat-icon">🏁</span>
                <div className="dashboard-stat-value">{stats.races_competed}</div>
                <div className="dashboard-stat-label">Big Races</div>
              </div>
              <div className="dashboard-stat-item">
                <span className="dashboard-stat-icon">⭐</span>
                <div className="dashboard-stat-value">{stats.club_records.count}</div>
                <div className="dashboard-stat-label">Club Records</div>
              </div>
              <div className="dashboard-stat-item">
                <span className="dashboard-stat-icon">🎯</span>
                <div className="dashboard-stat-value">{stats.top_list_performances.count}</div>
                <div className="dashboard-stat-label">Top List Performances</div>
              </div>
              <div className="dashboard-stat-item">
                <span className="dashboard-stat-icon">🥇</span>
                <div className="dashboard-stat-value">{stats.races_won}</div>
                <div className="dashboard-stat-label">Races Won</div>
              </div>
            </div>

            <div className="dashboard-three-column-section">
              {stats.club_records.performances.length > 0 && (
                <div className="dashboard-section-column">
                  <h2 className="dashboard-section-title">⭐ Club Records</h2>
                  <div className="performance-list">
                    {stats.club_records.performances.slice(0, 10).map((perf, idx) => (
                      <div key={idx} className="performance-item">
                        <span className="performance-athlete">{perf.athlete_name}</span>
                        <span className="performance-distance">{perf.race_distance}</span>
                        <span className="performance-time">{perf.time}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {stats.top_list_performances.performances.length > 0 && (
                <div className="dashboard-section-column">
                  <h2 className="dashboard-section-title">🎯 GRC All-Time</h2>
                  <div className="performance-list">
                    {getRandomItems(stats.top_list_performances.performances, 8).map((perf, idx) => (
                      <div key={idx} className="performance-item">
                        <span className="performance-athlete">{perf.athlete_name}</span>
                        <span className="performance-distance">{perf.race_distance}</span>
                        <span className="performance-time">{perf.time}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {stats.distance_breakdown.length > 0 && (
                <div className="dashboard-section-column">
                  <h2 className="dashboard-section-title">📊 Distance Breakdown</h2>
                  <div className="distance-breakdown-list">
                    {stats.distance_breakdown.slice(0, 10).map((dist, idx) => (
                      <div key={idx} className="distance-item">
                        <span className="distance-name">{dist.distance}</span>
                        <span className="distance-count">{dist.total_races}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {stats.grc_debuts.length > 0 && (
                <div className="dashboard-section-column">
                  <h2 className="dashboard-section-title">🎉 GRC Debuts</h2>
                  <div className="debuts-list">
                    {stats.grc_debuts.slice(0, 10).map((debut, idx) => (
                      <div key={idx} className="debut-item">
                        {debut.athlete_name}
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </>
        )}
        {stats && stats.popular_races.length > 0 && (
          <>
          <p className="dashboard-subtitle">GRC's biggest showings this year!</p>
            <ParticipationTimeline data={stats.popular_races as any} />
          </>
        )}
      </div>
    </Layout>
  );
};

export default Dashboard;
