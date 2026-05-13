import React from 'react';
import './Footer.css';

const Footer = () => {
  return (
    <footer className="footer">
      <div className="container footer-container">
        <div className="footer-brand">
          <div className="footer-logo">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 3L1 9L12 15L21 10.09V17H23V9L12 3Z" fill="white"/>
              <path d="M5 13.18V17.18C5 17.18 8.13401 21 12 21C15.866 21 19 17.18 19 17.18V13.18L12 17L5 13.18Z" fill="white"/>
            </svg>
            <span>EPISIGN</span>
          </div>
          <p>The modern attendance tracking solution designed exclusively for EPITA students and teachers.</p>
        </div>
        
        <div className="footer-links">
          <div className="link-group">
            <h4>Application</h4>
            <ul>
              <li><a href="#">Download for iOS</a></li>
              <li><a href="#">Teacher Guide</a></li>
              <li><a href="#">Student Guide</a></li>
            </ul>
          </div>
          <div className="link-group">
            <h4>Technology</h4>
            <ul>
              <li><a href="#">SwiftUI</a></li>
              <li><a href="#">CoreNFC</a></li>
              <li><a href="#">Firebase</a></li>
            </ul>
          </div>
        </div>
      </div>
      <div className="footer-bottom">
        <div className="container">
          <p>&copy; {new Date().getFullYear()} EPISIGN. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
