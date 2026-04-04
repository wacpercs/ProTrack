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

  async function search(q) {
    const searchQuery = q || query;
    if (!searchQuery.trim()) return;
    setLoading(true);
    haptic();
    try {
      const data = await api.searchVacancies(searchQuery);
      setResults({ query: searchQuery, ...data });
    } catch (e) {
      alert("Ошибка: " + e.message);
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
              <div className="vacancy-title">{v.title}</div>
              <div className="vacancy-company">{v.company}</div>
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
