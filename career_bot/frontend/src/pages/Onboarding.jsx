import React, { useState } from "react";
import { api } from "../api";
import { haptic } from "../telegram";

const EDUCATION_OPTIONS = [
  "Школьник (9-11 класс)",
  "Студент колледжа/СПО",
  "Студент вуза",
  "Выпускник",
];

export default function Onboarding({ onComplete, profile, editMode, setPage }) {
  const [step, setStep] = useState(0);
  const [form, setForm] = useState(() => {
    if (profile && editMode) {
      return {
        name: profile.name || "",
        age: profile.age ? String(profile.age) : "",
        city: profile.city || "",
        education: profile.education || "",
        interests: profile.interests || "",
        skills: profile.skills || "",
      };
    }
    return { name: "", age: "", city: "", education: "", interests: "", skills: "" };
  });
  const [saving, setSaving] = useState(false);

  const set = (key, val) => setForm((f) => ({ ...f, [key]: val }));

  async function handleSubmit() {
    setSaving(true);
    try {
      await api.saveProfile({ ...form, age: parseInt(form.age) });
      haptic("success");
      onComplete(form);
    } catch (e) {
      alert("Ошибка сохранения: " + e.message);
    }
    setSaving(false);
  }

  const steps = [
    <StepName value={form.name} onChange={(v) => set("name", v)} />,
    <StepAge value={form.age} onChange={(v) => set("age", v)} />,
    <StepCity value={form.city} onChange={(v) => set("city", v)} />,
    <StepEducation value={form.education} onChange={(v) => set("education", v)} />,
    <StepInterests value={form.interests} onChange={(v) => set("interests", v)} />,
    <StepSkills value={form.skills} onChange={(v) => set("skills", v)} />,
  ];

  const TOTAL = steps.length;

  const canNext =
    (step === 0 && form.name.trim()) ||
    (step === 1 && form.age && +form.age >= 12 && +form.age <= 60) ||
    (step === 2 && form.city.trim()) ||
    (step === 3 && form.education) ||
    (step === 4 && form.interests.trim()) ||
    (step === 5 && form.skills.trim());

  return (
    <>
      {editMode && (
        <button className="btn btn-outline" style={{ marginBottom: 12 }} onClick={() => setPage("dashboard")}>
          ← Отмена
        </button>
      )}
      <div className="page-header" style={{ textAlign: "center", padding: "20px 0 10px" }}>
        <div style={{ fontSize: 48, marginBottom: 8 }}>{editMode ? "✏️" : "💔"}</div>
        <h1 className="page-title">{editMode ? "Редактирование" : "ProTrack"}</h1>
        <p className="page-subtitle">Шаг {step + 1} из {TOTAL}</p>
      </div>

      <div className="progress-bar-bg">
        <div className="progress-bar-fill" style={{ width: `${((step + 1) / TOTAL) * 100}%` }} />
      </div>

      <div className="card">{steps[step]}</div>

      <div style={{ display: "flex", gap: 8, marginTop: 16 }}>
        {step > 0 && (
          <button className="btn btn-outline" style={{ flex: 1 }} onClick={() => setStep(step - 1)}>
            Назад
          </button>
        )}
        {step < TOTAL - 1 ? (
          <button
            className="btn btn-primary"
            style={{ flex: 2 }}
            disabled={!canNext}
            onClick={() => { haptic(); setStep(step + 1); }}
          >
            Далее
          </button>
        ) : (
          <button
            className="btn btn-primary"
            style={{ flex: 2 }}
            disabled={!canNext || saving}
            onClick={handleSubmit}
          >
            {saving ? "Сохраняю..." : "Готово!"}
          </button>
        )}
      </div>
    </>
  );
}

function StepName({ value, onChange }) {
  return (
    <div className="form-group">
      <label className="form-label">Как тебя зовут?</label>
      <input className="form-input" placeholder="Введи имя" value={value} onChange={(e) => onChange(e.target.value)} autoFocus />
    </div>
  );
}

function StepAge({ value, onChange }) {
  return (
    <div className="form-group">
      <label className="form-label">Сколько тебе лет?</label>
      <input className="form-input" type="number" placeholder="Возраст" min={12} max={60} value={value} onChange={(e) => onChange(e.target.value)} autoFocus />
    </div>
  );
}

function StepCity({ value, onChange }) {
  return (
    <div className="form-group">
      <label className="form-label">В каком городе ты живёшь?</label>
      <input className="form-input" placeholder="Москва, Казань, Новосибирск..." value={value} onChange={(e) => onChange(e.target.value)} autoFocus />
    </div>
  );
}

function StepEducation({ value, onChange }) {
  return (
    <div className="form-group">
      <label className="form-label">Образование</label>
      <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
        {EDUCATION_OPTIONS.map((opt) => (
          <button key={opt} className={`btn ${value === opt ? "btn-primary" : "btn-outline"}`} onClick={() => onChange(opt)}>
            {opt}
          </button>
        ))}
      </div>
    </div>
  );
}

function StepInterests({ value, onChange }) {
  return (
    <div className="form-group">
      <label className="form-label">Твои интересы и хобби</label>
      <textarea className="form-textarea" placeholder="Программирование, дизайн, музыка, спорт..." value={value} onChange={(e) => onChange(e.target.value)} rows={3} autoFocus />
    </div>
  );
}

function StepSkills({ value, onChange }) {
  return (
    <div className="form-group">
      <label className="form-label">Какие навыки у тебя уже есть?</label>
      <textarea className="form-textarea" placeholder="Python, Figma, английский, видеомонтаж..." value={value} onChange={(e) => onChange(e.target.value)} rows={3} autoFocus />
      <small style={{ color: "var(--text-secondary)", marginTop: 4, display: "block" }}>
        Если пока ничего — напиши "пока нет"
      </small>
    </div>
  );
}
