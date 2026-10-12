import React, { useState, useEffect, useRef } from "react";
import { createConsumer } from "@rails/actioncable";
import { Send } from "lucide-react"; // Smile
import { submitLead } from "./submit_lead";

const MAX_TEXTAREA_HEIGHT = 120;

export default function LiveChat({
  apiUrl: apiUrl,
  token: token,
  domain: domain,
  cableUrl: cableUrl,
}) {
  const [chatId, setChatId] = useState(null);
  const [externalId, setExternalId] = useState(null);
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(true);
  const messagesEndRef = useRef(null);
  const [message, setMessage] = useState("");
  const [sending, setSending] = useState(false);
  const [messageError, setMessageError] = useState("");
  const [contactToken, setContactToken] = useState(null);
  const [showContacts, setShowContacts] = useState(false);
  const [contactsSaved, setContactsSaved] = useState(false);
  const [contactsDismissed, setContactsDismissed] = useState(false);
  const [contactName, setContactName] = useState("");
  const [phone, setPhone] = useState("");
  const [email, setEmail] = useState("");
  const [savingContacts, setSavingContacts] = useState(false);
  const [contactError, setContactError] = useState("");
  const textareaRef = useRef(null);
  const AUTH_HEADERS = {
    "Content-Type": "application/json",
    Authorization: `Bearer ${token}`,
    "X-Widget-Domain": domain,
  };

  const initChat = async () => {
    let extId;

    try {
      extId = localStorage.getItem("chat_ext_id");

      if (!extId) {
        extId = crypto.randomUUID();
        localStorage.setItem("chat_ext_id", extId);
      }
    } catch {
      extId = crypto.randomUUID();
    }
    localStorage.setItem("chat_ext_id", extId);
    setExternalId(extId);

    const params = new URLSearchParams(window.location.search);
    const utm = {};
    for (const key of [
      "utm_source",
      "utm_medium",
      "utm_campaign",
      "utm_term",
      "utm_content",
    ]) {
      const value = params.get(key);
      if (value) utm[key] = value;
    }

    const res = await fetch(`${apiUrl}/api/v1/widget/chats`, {
      method: "POST",
      headers: AUTH_HEADERS,
      body: JSON.stringify({ external_id: extId, utm }),
    });
    const data = await res.json();
    setChatId(data.chat_id);
    setContactToken(data.contact_token);
    setContactsSaved(data.contacts_saved);
    let dismissed = false;
    try {
      dismissed =
        localStorage.getItem(`chat_contacts_dismissed_${data.chat_id}`) ===
        "true";
    } catch {
      /* Storage may be unavailable in an embedded widget. */
    }
    setContactsDismissed(dismissed);
    setShowContacts(
      data.has_client_messages && !data.contacts_saved && !dismissed,
    );

    await loadMessages(data.chat_id);
  };

  const handleInput = (e) => {
    const el = textareaRef.current;
    if (el) {
      if (e.target.scrollHeight === 20) {
        el.style.height = "20" + "px";
      } else if (el.scrollHeight <= MAX_TEXTAREA_HEIGHT) {
        el.style.height = "auto";
        el.style.height = el.scrollHeight + "px";
      } else {
        el.style.height = `${MAX_TEXTAREA_HEIGHT}px`;
      }
    }
    setMessage(e.target.value);
  };

  useEffect(() => {
    if (messagesEndRef.current) {
      setTimeout(() => {
        messagesEndRef.current.scrollIntoView({ behavior: "smooth" });
      }, 50);
    }
  }, [messages, showContacts]);

  const loadMessages = async (id) => {
    const res = await fetch(`${apiUrl}/api/v1/widget/chats/${id}/messages`, {
      headers: AUTH_HEADERS,
    });
    const data = await res.json();
    setMessages(data.messages || []);
    setLoading(false);
  };

  useEffect(() => {
    initChat();
  }, []);

  useEffect(() => {
    if (!chatId || !externalId || !token || !cableUrl) return;

    const consumer = createConsumer(cableUrl);

    const subscription = consumer.subscriptions.create(
      {
        channel: "ChatChannel",
        token,
        external_id: externalId,
      },
      {
        received(msg) {
          setMessages((prev) => [...prev, msg]);
        },
      },
    );

    return () => {
      subscription.unsubscribe();
      consumer.disconnect();
    };
  }, [chatId, externalId, token, cableUrl]);

  const sendMessage = async (e) => {
    e.preventDefault();
    if (!message.trim() || !chatId || sending) return;
    setSending(true);
    setMessageError("");
    try {
      const res = await fetch(
        `${apiUrl}/api/v1/widget/chats/${chatId}/messages`,
        {
          method: "POST",
          headers: AUTH_HEADERS,
          body: JSON.stringify({ content: message }),
        },
      );
      if (!res.ok)
        throw new Error("Не удалось отправить сообщение. Попробуйте ещё раз.");
      setMessage("");
      if (!contactsSaved && !contactsDismissed) setShowContacts(true);
    } catch (error) {
      setMessageError(error.message);
    } finally {
      setSending(false);
    }
  };

  const dismissContacts = () => {
    setContactsDismissed(true);
    setShowContacts(false);
    try {
      localStorage.setItem(`chat_contacts_dismissed_${chatId}`, "true");
    } catch {
      /* Keep dismissal in memory when storage is unavailable. */
    }
  };

  const saveContacts = async (e) => {
    e.preventDefault();
    if (savingContacts) return;
    setSavingContacts(true);
    setContactError("");
    try {
      const res = await submitLead({
        apiUrl,
        headers: AUTH_HEADERS,
        chatId,
        externalId,
        contactToken,
        contact: { name: contactName, phone, email },
      });
      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error(
          data.error ||
            "Не удалось сохранить контакты. Попробуйте ещё раз или обновите страницу.",
        );
      }
      setContactsSaved(true);
      setShowContacts(false);
    } catch (error) {
      setContactError(error.message);
    } finally {
      setSavingContacts(false);
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      if (message.trim()) sendMessage(e);
    }
  };

  return (
    <div
      className="h-full w-full"
      style={{
        overflow: "hidden",
        background: "rgba(249, 249, 251)",
        display: "flex",
        flexDirection: "column",
        height: "100%",
      }}
    >
      {/* Header */}
      <div
        style={{
          background: "#2c3e50",
          color: "#fff",
          padding: "10px",
          borderRadius: "12px 12px 0 0",
          display: "flex",
          justifyContent: "space-between",
        }}
      >
        <div>Чат поддержки</div>
      </div>

      {/* Messages */}
      <div
        style={{
          padding: "10px",
          display: "flex",
          flexDirection: "column",
        }}
        className="flex-1 overflow-y-auto"
      >
        {loading ? (
          <div className="flex-1 flex items-center justify-center">
            <span className="animate-spin rounded-full h-10 w-10 border-b-2 border-green-600"></span>
          </div>
        ) : (
          <>
            {messages.map((m, i) => (
              <div
                key={i}
                style={{
                  margin: "4px 0",
                  textAlign: ["bot", "manager"].includes(m.role)
                    ? "left"
                    : "right",
                }}
              >
                <span
                  style={{
                    background:
                      m.role === "bot"
                        ? "#eee"
                        : m.role === "client"
                          ? "#d6f5d6"
                          : "#fff",
                    padding: "5px 8px",
                    borderRadius: "8px",
                    display: "inline-block",
                    maxWidth: "85%",
                    boxShadow:
                      "0 0 #0000, 0 0 #0000, 0 .25rem 6px rgba(50, 50, 93, .08), 0 1px 3px rgba(0, 0, 0, .05)",
                  }}
                >
                  {m.content}
                </span>
              </div>
            ))}
            {showContacts && (
              <form
                onSubmit={saveContacts}
                className="my-3 rounded-xl bg-white p-3 shadow-sm"
              >
                <p className="mb-3 text-sm">
                  Как к вам обращаться? Оставьте имя и телефон или email, чтобы
                  мы могли связаться с вами.
                </p>
                <label className="mb-2 block text-sm">
                  Имя
                  <input
                    name="name"
                    autoComplete="name"
                    required
                    maxLength={100}
                    value={contactName}
                    onChange={(e) => setContactName(e.target.value)}
                    className="mt-1 w-full rounded border p-2"
                    disabled={savingContacts}
                  />
                </label>
                <label className="mb-3 block text-sm">
                  Телефон
                  <input
                    name="phone"
                    type="tel"
                    autoComplete="tel"
                    required={!email.trim()}
                    maxLength={30}
                    placeholder="+7 999 123-45-67"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    className="mt-1 w-full rounded border p-2"
                    disabled={savingContacts}
                  />
                </label>
                <label className="mb-3 block text-sm">
                  Email (необязательно)
                  <input
                    name="email"
                    type="email"
                    autoComplete="email"
                    maxLength={254}
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="mt-1 w-full rounded border p-2"
                    disabled={savingContacts}
                  />
                </label>
                {contactError && (
                  <p role="alert" className="mb-2 text-sm text-red-600">
                    {contactError}
                  </p>
                )}
                <div className="flex gap-3">
                  <button
                    type="submit"
                    disabled={savingContacts}
                    className="rounded bg-blue-600 px-3 py-2 text-sm text-white"
                  >
                    {savingContacts ? "Сохраняем…" : "Отправить контакты"}
                  </button>
                  <button
                    type="button"
                    onClick={dismissContacts}
                    disabled={savingContacts}
                    className="text-sm text-gray-500"
                  >
                    Не сейчас
                  </button>
                </div>
              </form>
            )}
            {contactsSaved && (
              <p role="status" className="my-2 text-sm text-green-700">
                Контакты сохранены. Спасибо!
              </p>
            )}
            <div ref={messagesEndRef}></div>
          </>
        )}
      </div>

      {/* Input */}
      <div className="p-2">
        {messageError && (
          <p role="alert" className="text-sm text-red-600">
            {messageError}
          </p>
        )}
        <form
          onSubmit={sendMessage}
          className="flex items-center rounded-2xl border-2 border-transparent focus-within:border-blue-500 px-3 py-2 w-full"
        >
          <textarea
            ref={textareaRef}
            style={{
              maxHeight: `${MAX_TEXTAREA_HEIGHT}px`,
              lineHeight: "20px",
            }}
            className="flex-1 bg-transparent outline-none resize-none h-5 overflow-y-auto"
            placeholder="Написать сообщение..."
            value={message}
            disabled={sending || loading}
            onChange={handleInput}
            onKeyDown={handleKeyDown}
          />
          <button
            type="submit"
            disabled={sending || loading || !message.trim()}
            className="p-1 text-blue-500 hover:text-blue-400 cursor-pointer"
          >
            <Send size={20} />
          </button>
        </form>
      </div>
    </div>
  );
}
