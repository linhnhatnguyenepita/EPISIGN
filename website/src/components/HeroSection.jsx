import React from 'react';
import './HeroSection.css';

const HeroSection = () => {
  return (
    <section className="hero">
      <div className="container hero-container">
        <div className="hero-content">
          <span className="pill pill-green hero-pill">
            Check-In Open
          </span>
          <h1 className="hero-title">
            The Future of <span className="text-gradient">Attendance Tracking</span> at EPITA.
          </h1>
          <p className="hero-description">
            Say goodbye to paper sheets. EPISIGN brings secure NFC and QR Code check-ins directly to your iOS device. Fast, reliable, and completely native.
          </p>
          <div className="hero-buttons">
            <button className="btn btn-primary">Download on App Store</button>
            <button className="btn btn-navy">View Documentation</button>
          </div>
        </div>
        
        <div className="hero-visual">
          <div className="phone-mockup">
            <div className="phone-screen">
              {/* Mockup of the Timeline UI */}
              <div className="mockup-header">
                <div>
                  <h3 className="mockup-logo">EPISIGN</h3>
                  <span className="mockup-role">Teacher</span>
                </div>
                <div className="mockup-avatar"></div>
              </div>
              
              <div className="mockup-title-row">
                <h2>Today's Lectures</h2>
                <span>3 Sessions</span>
              </div>
              
              <div className="mockup-timeline">
                <div className="mockup-timeline-item">
                  <div className="timeline-line"></div>
                  <div className="timeline-card active-card">
                    <span className="pill pill-green">CHECK-IN OPEN</span>
                    <h4>Probabilités et statistique</h4>
                    <p>Unknown Teacher</p>
                    <p className="room">Amphi A</p>
                    <p className="group">DEV2_1</p>
                  </div>
                </div>
                
                <div className="mockup-timeline-item">
                   <div className="timeline-card">
                    <span className="pill pill-navy">UPCOMING</span>
                    <h4>Intelligence Artificielle</h4>
                    <p>Unknown Teacher</p>
                    <p className="room">Room 402B</p>
                    <p className="group">DEV2_1</p>
                  </div>
                </div>
              </div>
              
              <div className="mockup-fab"></div>
            </div>
          </div>
        </div>
      </div>
      <div className="hero-background-glow"></div>
    </section>
  );
};

export default HeroSection;
