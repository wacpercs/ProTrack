import React, { useState } from "react";
import { api } from "../api";
import { haptic } from "../telegram";

export default function Career({ profile }) {
  const [tab, setTab] = useState("professions");
  const [professions, setProfessions] = useState(null);
  const [plan, setPlan] = useState(null);
  const [skillGap, setSkillGap] = useState(null);
  const [loading, setLoading] = useState(false);

  async function loadProfessions() {
    setLoading(true);
    try {
      const data = await api.getProfessions();
      setProfessions(data.result);
      haptic("success");
    } catch (e) {
      alert("Ошибка: " + e.message);
    }
    setLoading(false);
  }

  async function loadPlan() {
    setLoading(true);
    try {
      const data = await api.getCareerPlan();
      setPlan(data.result);
      haptic("success");
    } catch (e) {
      alert("Ошибка: " + e.message);
    }
    setLoading(false);
  }

  async function loadSkillGap() {
    setLoading(true);
    try {
      const data = await api.getSkillGap();
      setSkillGap(data.result);
      haptic("success");
    } catch (e) {
      alert("Ошибка: " + e.message);
    }
    setLoading(false);
  }

  return (
    <>
      <div className="page-header">
        <h1 className="page-title">Карьера</h1>
        <p className="page-subtitle">AI-рекомендации на основе профиля</p>
      </div>

      <div className="tabs">
        <button className={`tab ${tab === "professions" ? "active" : ""}`} onClick={() => setTab("professions")}>
          Профессии
        </button>
        <button className={`tab ${tab === "plan" ? "active" : ""}`} onClick={() => setTab("plan")}>
          Карьерный план
        </button>
        <button className={`tab ${tab === "skillgap" ? "active" : ""}`} onClick={() => setTab("skillgap")}>
          Skill Gap
        </button>
      </div>

      {tab === "professions" && (
        <>
          {!professions && !loading && (
            <div className="card" style={{ textAlign: "center" }}>
              <div style={{ fontSize: 48, marginBottom: 12 }}>🎯</div>
              <p style={{ marginBottom: 16, color: "var(--text-secondary)" }}>
                AI проанализирует твои интересы и навыки и подберёт подходящие профессии
              </p>
              <button className="btn btn-primary" onClick={loadProfessions}>
                Подобрать профессии
              </button>
            </div>
          )}
          {loading && (
            <div className="loading">
              <div className="spinner" />
              <span>Анализирую профиль...</span>
            </div>
          )}
          {professions && (
            <div className="card">
              <div className="ai-result">{professions}</div>
              <button
                className="btn btn-outline"
                style={{ marginTop: 16 }}
                onClick={() => { setProfessions(null); loadProfessions(); }}
              >
                Обновить рекомендации
              </button>
            </div>
          )}
        </>
      )}

      {tab === "plan" && (
        <>
          {!plan && !loading && (
            <div className="card" style={{ textAlign: "center" }}>
              <div style={{ fontSize: 48, marginBottom: 12 }}>🗺</div>
              <p style={{ marginBottom: 16, color: "var(--text-secondary)" }}>
                AI составит план с этапами роста (Стажёр → Junior → Middle → Senior), курсами и сертификатами
              </p>
              <button className="btn btn-primary" onClick={loadPlan}>
                Составить план
              </button>
            </div>
          )}
          {loading && (
            <div className="loading">
              <div className="spinner" />
              <span>Составляю план с курсами...</span>
            </div>
          )}
          {plan && (
            <div className="card">
              <div className="ai-result">{plan}</div>
              <button
                className="btn btn-outline"
                style={{ marginTop: 16 }}
                onClick={() => { setPlan(null); loadPlan(); }}
              >
                Обновить план
              </button>
            </div>
          )}
        </>
      )}

      {tab === "skillgap" && (
        <>
          {!skillGap && !loading && (
            <div className="card" style={{ textAlign: "center" }}>
              <div style={{ fontSize: 48, marginBottom: 12 }}>📊</div>
              <p style={{ marginBottom: 16, color: "var(--text-secondary)" }}>
                AI сравнит твои навыки с требованиями профессий и покажет, что нужно подтянуть
              </p>
              <button className="btn btn-primary" onClick={loadSkillGap}>
                Анализ навыков
              </button>
            </div>
          )}
          {loading && (
            <div className="loading">
              <div className="spinner" />
              <span>Анализирую навыки...</span>
            </div>
          )}
          {skillGap && (
            <div className="card">
              <div className="ai-result">{skillGap}</div>
              <button
                className="btn btn-outline"
                style={{ marginTop: 16 }}
                onClick={() => { setSkillGap(null); loadSkillGap(); }}
              >
                Обновить анализ
              </button>
            </div>
          )}
        </>
      )}
    </>
  );
}
