import React, { useState, useEffect, useRef } from "react";
import { createConsumer } from "@rails/actioncable";
import { Smile, Send } from "lucide-react";

export default function LiveChat({apiUrl: apiUrl, token: token, domain: domain, cableUrl: cableUrl}) {
    console.log(cableUrl);
    const [isOpen, setIsOpen] = useState(false);
    const [chatId, setChatId] = useState(null);
    const [messages, setMessages] = useState([]);
    const messagesEndRef = useRef(null);
    const cableRef = useRef(null);
    const subscriptionRef = useRef(null);
    const [message, setMessage] = useState("");
    const AUTH_HEADERS = {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
        "X-Widget-Domain": domain
    };

    useEffect(() => {
        if (messagesEndRef.current) {
            messagesEndRef.current.scrollIntoView({ behavior: "smooth" });
        }
    }, [messages]);

    const loadMessages = async (id) => {
        const res = await fetch(`${apiUrl}/api/v1/chats/${id}/messages`, {
            headers: AUTH_HEADERS
        });
        const data = await res.json();
        setMessages(data.messages || []);
    };

    const openChat = async () => {
        setIsOpen(true);

        let externalId =
            localStorage.getItem("rails_chat_ext_id") ||
            Math.random().toString(36).substr(2, 10);
        localStorage.setItem("rails_chat_ext_id", externalId);

        const res = await fetch(`${apiUrl}/api/v1/chats`, {
            method: "POST",
            headers: AUTH_HEADERS,
            body: JSON.stringify({ external_id: externalId })
        });
        const data = await res.json();
        setChatId(data.chat_id);

        await loadMessages(data.chat_id);

        // Connect to ActionCable
        cableRef.current = createConsumer(cableUrl);
        subscriptionRef.current = cableRef.current.subscriptions.create(
            { channel: "ChatChannel", chat_id: data.chat_id },
            {
                received: (msg) => {
                    if (msg.content) {
                        setMessages((prev) => [...prev, msg]);
                    }
                }
            }
        );
    };

    const closeChat = () => {
        setIsOpen(false);
        if (subscriptionRef.current) {
            subscriptionRef.current.unsubscribe();
            subscriptionRef.current = null;
        }
    };

    const sendMessage = async (e) => {
        e.preventDefault();
        if (!message.trim()) return;

        await fetch(`${apiUrl}/api/v1/chats/${chatId}/messages`, {
            method: "POST",
            headers: AUTH_HEADERS,
            body: JSON.stringify({ content: message })
        });
        setMessage("");
    };

    const handleKeyDown = (e) => {
        if (e.key === "Enter" && !e.shiftKey) {
            e.preventDefault();
            if (message.trim()) {
                sendMessage(e);
            }
        } else if (e.key === "Escape") {
            closeChat();
        }
    };

    if (!isOpen) {
        return (
            <button
                onClick={openChat}
                style={{
                    borderRadius: "50%",
                    backgroundColor: "rgb(0, 173, 236)",
                    display: "flex",
                    justifyContent: "center",
                    alignItems: "center",
                    width: "48px",
                    height: "48px",
                    padding: 0,
                    margin: 0,
                    outline: "none",
                    border: "none",
                    boxShadow: "none",
                    position: "fixed",
                    right: "10px",
                    bottom: "10px",
                    cursor: "pointer"
                }}
                title="Открыть чат"
            >
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 31 28">
                    <path
                        fill="#FFFFFF"
                        fillRule="evenodd"
                        d="M23.29 13.25V2.84c0-1.378-1.386-2.84-2.795-2.84h-17.7C1.385 0 0 1.462 0 2.84v10.41c0 1.674 1.385 3.136 2.795 2.84H5.59v5.68h.93c.04 0 .29-1.05.933-.947l3.726-4.732h9.315c1.41.296 2.795-1.166 2.795-2.84zm2.795-3.785v4.733c.348 2.407-1.756 4.558-4.658 4.732h-8.385l-1.863 1.893c.22 1.123 1.342 2.127 2.794 1.893h7.453l2.795 3.786c.623-.102.93.947.93.947h.933v-4.734h1.863c1.57.234 2.795-1.02 2.795-2.84v-7.57c0-1.588-1.225-2.84-2.795-2.84h-1.863z"
                    />
                </svg>
            </button>
        );
    }

    return (
        <div
            style={{
                position: "fixed",
                overflow: "hidden",
                right: "20px",
                bottom: "20px",
                width: "300px",
                height: "400px",
                background: "#fff",
                borderRadius: "12px",
                boxShadow: "0 0 8px #ccc",
                zIndex: 999999,
                display: "flex",
                flexDirection: "column"
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
                    justifyContent: "space-between"
                }}
            >
                <div>Чат поддержки</div>
                <button
                    style={{ background: "transparent", border: "none", color: "white", cursor: "pointer" }}
                    onClick={closeChat}
                >
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="20"
                        height="20"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                    >
                        <line x1="18" y1="6" x2="6" y2="18" />
                        <line x1="6" y1="6" x2="18" y2="18" />
                    </svg>
                </button>
            </div>

            {/* Messages */}
            <div
                style={{ flex: 1, overflowY: "auto", padding: "8px" }}
            >
                {messages.map((m, i) => (
                    <div
                        key={i}
                        style={{
                            margin: "4px 0",
                            textAlign: ["bot", "manager"].includes(m.role) ? "left" : "right"
                        }}
                    >
            <span
                style={{
                    background: m.role === "bot" ? "#eee" : "#d6f5d6",
                    padding: "5px 8px",
                    borderRadius: "8px",
                    display: "inline-block"
                }}
            >
              {m.content}
            </span>
                    </div>
                ))}
                <div ref={messagesEndRef}></div>
            </div>

            {/* Input */}
            <div className="p-2">
                <div className="flex items-center rounded-2xl border-2 border-transparent focus-within:border-blue-500 px-3 py-2 w-full">
                    <form
                        onSubmit={sendMessage}
                        className="flex w-full"
                    >
                    <textarea
                        className="flex-1 bg-transparent outline-none resize-none h-[24px] max-h-[120px] overflow-y-auto"
                        placeholder="Написать сообщение..."
                        value={message}
                        onChange={(e) => setMessage(e.target.value)}
                        onKeyDown={handleKeyDown}
                    />
                    <button
                        type="submit"
                        className="p-1 text-blue-500 hover:text-blue-400 cursor-pointer"
                    >
                        <Send size={20} />
                    </button>
                    </form>
                </div>
            </div>
        </div>
    );
}
