import React from 'react';
import './RolesSection.css';

const RolesSection = () => {
  return (
    <section className="roles-section">
      <div className="container">
        
        <div className="role-block">
          <div className="role-content">
            <span className="pill pill-navy role-pill">For Teachers</span>
            <h2>Open Sessions Effortlessly</h2>
            <p>
              As a teacher, managing attendance takes seconds. Tap your iPhone to a classroom NFC tag to instantly start a 10-minute session.
            </p>
            <ul className="role-list">
              <li>
                <div className="list-icon">✓</div>
                <span>10-minute live countdown</span>
              </li>
              <li>
                <div className="list-icon">✓</div>
                <span>Backup QR Code generation</span>
              </li>
              <li>
                <div className="list-icon">✓</div>
                <span>Cancel sessions anytime</span>
              </li>
            </ul>
          </div>
          <div className="role-visual">
            <div className="modal-mockup">
              <div className="modal-content">
                <div className="modal-close">×</div>
                <h3>Prêt à scanner</h3>
                <p>Approchez votre iPhone du tag NFC placé en salle de cours.</p>
                <div className="modal-icon-wrapper">
                  <div className="modal-icon-circle">
                    {/* Simplified phone icon */}
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                      <rect x="5" y="2" width="14" height="20" rx="3"/>
                      <path d="M12 18h.01"/>
                    </svg>
                  </div>
                </div>
                <button className="btn btn-cancel">Annuler</button>
              </div>
            </div>
          </div>
        </div>

        <div className="role-block role-reverse">
          <div className="role-content">
            <span className="pill pill-green role-pill">For Students</span>
            <h2>Sign in with a Tap</h2>
            <p>
              When a session is open, simply tap the tag or scan the QR code to log your presence. Complete the process by providing your handwritten signature.
            </p>
            <ul className="role-list">
              <li>
                <div className="list-icon">✓</div>
                <span>Instant validation</span>
              </li>
              <li>
                <div className="list-icon">✓</div>
                <span>Visual timeline of lectures</span>
              </li>
              <li>
                <div className="list-icon">✓</div>
                <span>Secure signature pad</span>
              </li>
            </ul>
          </div>
          <div className="role-visual">
            <div className="card student-card-mockup">
              <div className="student-card-header">
                <span className="pill pill-green">CHECK-IN OPEN</span>
                <span className="time-left">10:00</span>
              </div>
              <h4>Architecture Réseaux</h4>
              <p>Unknown Teacher</p>
              <div className="student-card-actions">
                <button className="btn btn-navy full-width">Tap NFC to Start</button>
              </div>
            </div>
          </div>
        </div>

      </div>
    </section>
  );
};

export default RolesSection;
