import React, { useState, useEffect } from "react";
import { api } from "../api";
import { haptic } from "../telegram";

export default function Vacancies({ profile }) {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState(null);
  const [suggestions, setSuggestions] = useState([]);
  const [loading, setLoading] = useState(false);
  const [loadingSuggestions, setLoadingSuggestions] = useState(true);

  useEffect(() => {
    loadSuggestions();
  }, []);

  async function loadSuggestions() {
    try {
      const data = await api.getVacancySuggestions();
      setSuggestions(data.queries || []);
    } catch (e) {
      console.error(e);
    }
    setLoadingSuggestions(false);
  }

  const [scored, setScored] = useState(false);

  async function search(q) {
    const searchQuery = q || query;
    if (!searchQuery.trim()) return;
    setLoading(true);
    setScored(false);
    haptic();
    try {
      const data = await api.searchVacanciesScored(searchQuery);
      setResults({ query: searchQuery, ...data });
      setScored(true);
    } catch (e) {
      // Fallback to regular search
      try {
        const data = await api.searchVacancies(searchQuery);
        setResults({ query: searchQuery, ...data });
      } catch (e2) {
        alert("Ошибка: " + e2.message);
      }
    }
    setLoading(false);
  }

  return (
    <>
      <div className="page-header">
        <h1 className="page-title">Вакансии</h1>
        <p className="page-subtitle">Поиск по hh.ru</p>
      </div>

      <div style={{ display: "flex", gap: 8, marginBottom: 16 }}>
        <input
          className="form-input"
          placeholder="Поиск вакансий..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && search()}
          style={{ flex: 1 }}
        />
        <button className="btn btn-primary" style={{ width: "auto", padding: "12px 20px" }} onClick={() => search()}>
          🔍
        </button>
      </div>

      {!results && !loading && (
        <>
          {loadingSuggestions ? (
            <div className="loading">
              <div className="spinner" />
              <span>Подбираю запросы...</span>
            </div>
          ) : suggestions.length > 0 ? (
            <>
              <p style={{ fontSize: 14, color: "var(--text-secondary)", marginBottom: 10 }}>
                Подобрано под твой профиль:
              </p>
              {suggestions.map((s, i) => (
                <button
                  key={i}
                  className="btn btn-card"
                  style={{ marginBottom: 8 }}
                  onClick={() => { setQuery(s); search(s); }}
                >
                  <span className="btn-card-icon">🔍</span>
                  <span className="btn-card-text">{s}</span>
                </button>
              ))}
            </>
          ) : (
            <div className="card" style={{ textAlign: "center", color: "var(--text-secondary)" }}>
              Введи запрос для поиска вакансий
            </div>
          )}
        </>
      )}

      {loading && (
        <div className="loading">
          <div className="spinner" />
          <span>Ищу вакансии...</span>
        </div>
      )}

      {results && !loading && (
        <>
          <p style={{ fontSize: 14, color: "var(--text-secondary)", marginBottom: 12 }}>
            Найдено: {results.total} вакансий по запросу «{results.query}»
          </p>
          {results.items.length === 0 && (
            <div className="card" style={{ textAlign: "center", color: "var(--text-secondary)" }}>
              Ничего не найдено. Попробуй другой запрос.
            </div>
          )}
          {results.items.map((v) => (
            <div className="vacancy-card" key={v.id}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                <div className="vacancy-title" style={{ flex: 1 }}>{v.title}</div>
                {scored && v.match_score > 0 && (
                  <span style={{
                    fontSize: 12,
                    fontWeight: 700,
                    padding: "2px 8px",
                    borderRadius: 3,
                    flexShrink: 0,
                    marginLeft: 8,
                    background: v.match_score >= 70 ? "rgba(0,200,83,0.15)" : v.match_score >= 40 ? "rgba(255,214,0,0.15)" : "rgba(255,60,0,0.15)",
                    color: v.match_score >= 70 ? "var(--primary)" : v.match_score >= 40 ? "var(--amber)" : "#ff3d00",
                    border: "1px solid " + (v.match_score >= 70 ? "var(--primary)" : v.match_score >= 40 ? "var(--amber)" : "#ff3d00"),
                  }}>
                    {v.match_score}%
                  </span>
                )}
              </div>
              <div className="vacancy-company">{v.company}</div>
              {scored && v.match_reason && (
                <div style={{ fontSize: 12, color: "var(--text-secondary)", marginTop: 4, fontStyle: "italic" }}>
                  {v.match_reason}
                </div>
              )}
              <div className="vacancy-meta">
                {v.city && <span className="vacancy-tag">📍 {v.city}</span>}
                {v.salary !== "не указана" && <span className="vacancy-tag">💰 {v.salary}</span>}
                {v.experience && <span className="vacancy-tag">📋 {v.experience}</span>}
                {v.schedule && <span className="vacancy-tag">🕐 {v.schedule}</span>}
              </div>
              <a className="vacancy-link" href={v.url} target="_blank" rel="noopener">
                Открыть на hh.ru →
              </a>
            </div>
          ))}
          <button
            className="btn btn-outline"
            style={{ marginTop: 8 }}
            onClick={() => setResults(null)}
          >
            Новый поиск
          </button>
        </>
      )}
    </>
  );
}
