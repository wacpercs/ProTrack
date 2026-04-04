import React from "react";
import { haptic } from "../telegram";

export default function Dashboard({ profile, setPage }) {
  const name = profile?.name || "субъект";

  return (
    <>
      <div className="page-header">
        <div className="app-logo">PROTRACK</div>
        <div className="app-logo-sub">CAREER AI</div>
      </div>

      <div className="dashboard-cards">
        <div className="dash-card" onClick={() => { haptic(); setPage("vacancies"); }}>
          <div className="dash-card-header">
            <span className="dash-card-title">💼 Вакансии</span>
            <span className="dash-card-badge">НОВОЕ</span>
          </div>
          <div className="dash-card-desc">Подобранные предложения по твоему профилю</div>
        </div>

        <div className="dash-card" onClick={() => { haptic(); setPage("career"); }}>
          <div className="dash-card-header">
            <span className="dash-card-title">⚗️ AI Анализ</span>
            <span className="dash-card-badge">AI</span>
          </div>
          <div className="dash-card-desc">Подбор профессий и карьерный план</div>
        </div>

        <div className="dash-card" onClick={() => { haptic(); setPage("chat"); }}>
          <div className="dash-card-header">
            <span className="dash-card-title">🧪 Консультант</span>
            <span className="dash-card-badge">ОНЛАЙН</span>
          </div>
          <div className="dash-card-desc">AI-чат по вопросам карьеры</div>
        </div>
      </div>

      {profile && (
        <div className="card" style={{ marginTop: 16 }}>
          <div className="card-header">📁 ДОСЬЕ</div>
          <ProfileRow label="Имя" value={profile.name} />
          <ProfileRow label="Возраст" value={profile.age} />
          <ProfileRow label="Город" value={profile.city} />
          <ProfileRow label="Образование" value={profile.education} />
          <ProfileRow label="Интересы" value={profile.interests} />
          <ProfileRow label="Навыки" value={profile.skills} />
          <button className="btn btn-outline" style={{ marginTop: 12 }} onClick={() => { haptic(); setPage("editProfile"); }}>
            Редактировать
          </button>
        </div>
      )}
    </>
  );
}

function ProfileRow({ label, value }) {
  if (!value) return null;
  return (
    <div style={{ marginBottom: 6, fontSize: 13 }}>
      <span style={{ color: "var(--text-secondary)", textTransform: "uppercase", letterSpacing: "1px", fontSize: 11 }}>{label}: </span>
      <span>{value}</span>
    </div>
  );
}
