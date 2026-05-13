import React from 'react';
import Navbar from './components/Navbar';
import HeroSection from './components/HeroSection';
import FeatureCards from './components/FeatureCards';
import RolesSection from './components/RolesSection';
import Footer from './components/Footer';
import './App.css';

function App() {
  return (
    <div className="app-wrapper">
      <Navbar />
      <main>
        <HeroSection />
        <FeatureCards />
        <RolesSection />
      </main>
      <Footer />
    </div>
  );
}

export default App;
