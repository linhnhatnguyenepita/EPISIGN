import React from 'react';
import './Navbar.css';

const Navbar = () => {
  return (
    <nav className="navbar">
      <div className="container navbar-container">
        <div className="navbar-logo">
          {/* A simple SVG representing the graduation cap from the EPISIGN logo */}
          <svg width="32" height="32" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M12 3L1 9L12 15L21 10.09V17H23V9L12 3Z" fill="var(--accent-navy)"/>
            <path d="M5 13.18V17.18C5 17.18 8.13401 21 12 21C15.866 21 19 17.18 19 17.18V13.18L12 17L5 13.18Z" fill="var(--accent-navy)"/>
          </svg>
          <span className="navbar-title">EPISIGN</span>
        </div>
        <div className="navbar-actions">
          <button className="btn btn-navy">Get the App</button>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
