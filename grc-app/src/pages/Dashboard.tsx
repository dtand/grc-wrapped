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
              <div className="dashboard-stat-value">{stats.club_records}</div>
              <div className="dashboard-stat-label">Club Records</div>
            </div>
          </div>
        )}
        {stats && stats.popular_races.length > 0 && (
          <>
          <p className="dashboard-subtitle">We've showed up</p>
            <ParticipationTimeline data={stats.popular_races as any} />
          </>
        )}
      </div>
    </Layout>
  );
};

export default Dashboard;
