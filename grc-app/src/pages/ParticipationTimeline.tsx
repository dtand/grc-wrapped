import React, { useState } from 'react';

interface TimelineData {
  race: string;
  participants: number;
  date?: string;
}

interface ParticipationTimelineProps {
  data: TimelineData[];
}

const colors = [
  '#2d7ff9', '#f9a825', '#43a047', '#e53935', '#8e24aa', '#00bcd4', '#ff7043', '#cddc39', '#5c6bc0', '#ffb300'
];

export const ParticipationTimeline: React.FC<ParticipationTimelineProps> = ({ data }) => {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  if (!data || data.length === 0) return null;

  const maxParticipants = Math.max(...data.map(d => d.participants));
  const minRadius = 30;
  const maxRadius = 80;

  const containerWidth = 1400;
  const containerHeight = 350;
  const padding = 100;
  const timelineY = containerHeight / 2;
  const availableWidth = containerWidth - padding * 2;

  return (
    <div className="participation-timeline-container">
      <svg width={containerWidth} height={containerHeight} className="participation-timeline">
        {/* Timeline line */}
        <line
          x1={padding}
          y1={timelineY + 20}
          x2={containerWidth - padding}
          y2={timelineY + 20}
          stroke="#e0e0e0"
          strokeWidth={2}
        />

        {/* Nodes and bubbles */}
        {data.map((d, i) => {
          const x = padding + (availableWidth / (data.length - 1 || 1)) * i;
          const radius = minRadius + (d.participants / maxParticipants) * (maxRadius - minRadius);
          const isHovered = hoveredIndex === i;
          const scale = isHovered ? 1.15 : 1;

          return (
            <g key={d.race} className="timeline-node">
              {/* Small dot on timeline */}
              <circle
                cx={x}
                cy={timelineY + 20}
                r={4}
                fill="#2d7ff9"
              />

              {/* Main bubble */}
              <circle
                cx={x}
                cy={timelineY - 70}
                r={radius * scale}
                fill={colors[i % colors.length]}
                opacity={0.85}
                stroke="#fff"
                strokeWidth={3}
                onMouseEnter={() => setHoveredIndex(i)}
                onMouseLeave={() => setHoveredIndex(null)}
                style={{
                  cursor: 'pointer',
                  transition: 'all 0.2s ease',
                  filter: isHovered ? 'drop-shadow(0 4px 12px rgba(0,0,0,0.2))' : 'drop-shadow(0 2px 6px rgba(0,0,0,0.1))'
                }}
              />

              {/* Participant count inside bubble */}
              <text
                x={x}
                y={timelineY - 70}
                textAnchor="middle"
                dy={5}
                fontSize={Math.min(18, radius / 2.5)}
                fontWeight="bold"
                fill="#fff"
                pointerEvents="none"
              >
                {d.participants}
              </text>

              {/* Race name below timeline - vertical text */}

              {/* Race name on hover - tooltip style */}
              {isHovered && (
                <foreignObject x={x - 80} y={timelineY - 140} width={160} height={50}>
                  <div className="timeline-tooltip">
                    <div className="timeline-tooltip-race">{d.race}</div>
                    {d.date && <div className="timeline-tooltip-date">{d.date}</div>}
                  </div>
                </foreignObject>
              )}
            </g>
          );
        })}
      </svg>
    </div>
  );
};

export default ParticipationTimeline;
