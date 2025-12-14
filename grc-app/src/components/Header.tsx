import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import './Header.css';

const navLinks = [
  { to: '/', label: 'Dashboard' },
  { to: '/races', label: 'Performances' },
];

const Header: React.FC = () => {
  const location = useLocation();
  return (
    <header className="grc-header">
      <div className="grc-header-left">GRC Wrapped</div>
      <nav className="grc-header-right">
        {navLinks.map((link) => (
          <Link
            key={link.to}
            to={link.to}
            className={
              'grc-header-link' + (location.pathname === link.to ? ' active' : '')
            }
          >
            {link.label}
          </Link>
        ))}
      </nav>
    </header>
  );
};

export default Header;
