import React, { useState, useEffect } from "react";
import { initTelegram } from "./telegram";
import { api } from "./api";
import Onboarding from "./pages/Onboarding";
import Dashboard from "./pages/Dashboard";
import Career from "./pages/Career";
import Vacancies from "./pages/Vacancies";
import Chat from "./pages/Chat";

const PAGES = {
  dashboard: Dashboard,
  career: Career,
  vacancies: Vacancies,
  chat: Chat,
  editProfile: Onboarding,
};

export default function App() {
  const [page, setPage] = useState("dashboard");
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    try { initTelegram(); } catch(e) {}
    loadProfile();
  }, []);

  async function loadProfile() {
    try {
      const data = await api.getProfile();
      if (data.exists) setProfile(data.profile);
    } catch (e) {
      console.warn("Profile load failed:", e.message);
    }
    setLoading(false);
  }

  if (loading) {
    return (
      <div className="app">
        <div className="loading">
          <div className="spinner" />
          <span>Загрузка...</span>
        </div>
      </div>
    );
  }

  if (!profile) {
    return (
      <div className="app">
        <Onboarding onComplete={(p) => setProfile(p)} />
      </div>
    );
  }

  const PageComponent = PAGES[page];

  return (
    <div className="app">
      <PageComponent
        profile={profile}
        setProfile={setProfile}
        setPage={setPage}
        onComplete={page === "editProfile" ? (p) => { setProfile(p); setPage("dashboard"); } : undefined}
        editMode={page === "editProfile"}
      />
      <nav className="nav-bottom">
        <NavItem icon="🏠" label="Главная" active={page === "dashboard"} onClick={() => setPage("dashboard")} />
        <NavItem icon="🔍" label="Вакансии" active={page === "vacancies"} onClick={() => setPage("vacancies")} />
        <NavItem icon="⚗️" label="Анализ" active={page === "career"} onClick={() => setPage("career")} />
        <NavItem icon="👤" label="Профиль" active={page === "editProfile"} onClick={() => setPage("editProfile")} />
      </nav>
    </div>
  );
}

function NavItem({ icon, label, active, onClick }) {
  return (
    <button className={`nav-item ${active ? "active" : ""}`} onClick={onClick}>
      <span className="nav-item-icon">{icon}</span>
      {label}
    </button>
  );
}
