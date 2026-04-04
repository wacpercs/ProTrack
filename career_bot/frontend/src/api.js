import { getInitData } from "./telegram";

const BASE = "/api";

function getAuth() {
  // Try TG initData first
  const initData = getInitData();
  if (initData) return initData;
  // Try saved Bearer token (APK mode)
  const token = localStorage.getItem("career_token");
  if (token) return `Bearer ${token}`;
  return "";
}

async function request(path, options = {}) {
  const auth = getAuth();
  const res = await fetch(BASE + path, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(auth ? { Authorization: auth } : {}),
      ...options.headers,
    },
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.detail || `HTTP ${res.status}`);
  }
  return res.json();
}

async function ensureAuth() {
  // If we already have auth, do nothing
  if (getAuth()) return;
  // Auto-register with random credentials
  const uid = "user_" + Math.random().toString(36).slice(2, 10);
  const pwd = Math.random().toString(36).slice(2, 14);
  try {
    const res = await fetch(BASE + "/auth/register", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username: uid, password: pwd }),
    });
    const data = await res.json();
    if (data.token) {
      localStorage.setItem("career_token", data.token);
    }
  } catch (e) {
    console.error("Auto-register failed:", e);
  }
}

export const api = {
  getProfile: () => request("/profile"),
  saveProfile: async (data) => {
    await ensureAuth();
    return request("/profile", { method: "POST", body: JSON.stringify(data) });
  },
  getProfessions: () => request("/professions"),
  getCareerPlan: () => request("/career-plan"),
  chat: (message) => request("/chat", { method: "POST", body: JSON.stringify({ message }) }),
  searchVacancies: (query, experience = "noExperience", page = 0) =>
    request("/vacancies", {
      method: "POST",
      body: JSON.stringify({ query, experience, page }),
    }),
  getSkillGap: () => request("/skill-gap"),
  searchVacanciesScored: (query, experience = "noExperience", page = 0) =>
    request("/vacancies/scored", {
      method: "POST",
      body: JSON.stringify({ query, experience, page }),
    }),
  getVacancySuggestions: () => request("/vacancy-suggestions"),
  getTheme: () => request("/theme"),
  setTheme: (theme) => request("/theme", { method: "POST", body: JSON.stringify({ theme }) }),
};
