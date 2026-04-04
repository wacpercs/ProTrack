import React, { useState, useRef, useEffect } from "react";
import { api } from "../api";
import { haptic } from "../telegram";

export default function Chat({ profile }) {
  const [messages, setMessages] = useState([
    { role: "bot", text: `Привет${profile?.name ? ", " + profile.name : ""}! Задавай любые вопросы о карьере, профессиях, обучении — помогу разобраться.` },
  ]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const bottomRef = useRef(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  async function send() {
    const text = input.trim();
    if (!text || loading) return;
    setInput("");
    setMessages((m) => [...m, { role: "user", text }]);
    setLoading(true);
    haptic();

    try {
      const data = await api.chat(text);
      setMessages((m) => [...m, { role: "bot", text: data.reply }]);
    } catch (e) {
      setMessages((m) => [...m, { role: "bot", text: "Ошибка: " + e.message }]);
    }
    setLoading(false);
  }

  return (
    <>
      <div className="page-header">
        <h1 className="page-title">Чат</h1>
        <p className="page-subtitle">AI-консультант по карьере</p>
      </div>

      <div className="chat-messages" style={{ paddingBottom: 80 }}>
        {messages.map((m, i) => (
          <div key={i} className={`chat-msg ${m.role === "user" ? "user" : "bot"}`}>
            {m.text}
          </div>
        ))}
        {loading && (
          <div className="chat-msg bot" style={{ opacity: 0.6 }}>
            Думаю...
          </div>
        )}
        <div ref={bottomRef} />
      </div>

      <div className="chat-input-wrap">
        <input
          className="form-input"
          placeholder="Задай вопрос..."
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && send()}
          disabled={loading}
        />
        <button className="btn btn-primary" onClick={send} disabled={loading || !input.trim()}>
          ➤
        </button>
      </div>
    </>
  );
}
