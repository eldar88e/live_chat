import React, { useState, useEffect, useRef } from "react";
import { createConsumer } from "@rails/actioncable";
import { Smile, Send } from "lucide-react";

const MAX_TEXTAREA_HEIGHT = 120;

export default function LiveChat({apiUrl: apiUrl, token: token, domain: domain, cableUrl: cableUrl}) {
    const [chatId, setChatId] = useState(null);
    const [messages, setMessages] = useState([]);
    const [loading, setLoading] = useState(true);
    const messagesEndRef = useRef(null);
    const cableRef = useRef(null);
    const subscriptionRef = useRef(null);
    const [message, setMessage] = useState("");
    const textareaRef = useRef(null);
    const AUTH_HEADERS = {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
        "X-Widget-Domain": domain
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
            messagesEndRef.current.scrollIntoView({ behavior: "smooth" });
        }
    }, [messages]);

    const loadMessages = async (id) => {
        const res = await fetch(`${apiUrl}/api/v1/widget/chats/${id}/messages`, {
            headers: AUTH_HEADERS
        });
        const data = await res.json();
        setMessages(data.messages || []);
        setLoading(false);
    };

    useEffect(() => {
        const initChat = async () => {
            let externalId =
                localStorage.getItem("rails_chat_ext_id") ||
                Math.random().toString(36).substr(2, 10);
            localStorage.setItem("rails_chat_ext_id", externalId);

            const res = await fetch(`${apiUrl}/api/v1/widget/chats`, {
                method: "POST",
                headers: AUTH_HEADERS,
                body: JSON.stringify({external_id: externalId})
            });
            const data = await res.json();
            setChatId(data.chat_id);

            await loadMessages(data.chat_id);

            // Connect to ActionCable
            cableRef.current = createConsumer(cableUrl);
            subscriptionRef.current = cableRef.current.subscriptions.create(
                {channel: "ChatChannel", chat_id: data.chat_id},
                {
                    received: (msg) => {
                        if (msg.content) {
                            setMessages((prev) => [...prev, msg]);
                        }
                    }
                }
            );
        }

        initChat();
    }, []);

    const sendMessage = async (e) => {
        e.preventDefault();
        if (!message.trim()) return;

        let body = JSON.stringify({ content: message })
        setMessage("");
        await fetch(`${apiUrl}/api/v1/widget/chats/${chatId}/messages`, {
            method: "POST",
            headers: AUTH_HEADERS,
            body: body
        });
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
                height: "100%"
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
            </div>

            {/* Messages */}
            <div
                style={{
                    padding: "10px",
                    display: "flex",
                    flexDirection: "column"
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
                            <div key={i} style={{ margin: "4px 0", textAlign: ["bot", "manager"].includes(m.role) ? "left" : "right" }}>
                                <span
                                    style={{
                                        background: m.role === "bot" ? "#eee" : (m.role === "client" ? "#d6f5d6" : "#fff"),
                                        padding: "5px 8px",
                                        borderRadius: "8px",
                                        display: "inline-block",
                                        maxWidth: "85%",
                                        boxShadow: "0 0 #0000, 0 0 #0000, 0 .25rem 6px rgba(50, 50, 93, .08), 0 1px 3px rgba(0, 0, 0, .05)"
                                    }}
                                >
                                    {m.content}
                                </span>
                            </div>
                        ))}
                        <div ref={messagesEndRef}></div>
                    </>
                )}
            </div>

            {/* Input */}
            <div className="p-2">
                <form
                    onSubmit={sendMessage}
                    className="flex items-center rounded-2xl border-2 border-transparent focus-within:border-blue-500 px-3 py-2 w-full"
                >
                    <textarea
                        ref={textareaRef}
                        style={{ maxHeight: `${MAX_TEXTAREA_HEIGHT}px`, lineHeight: "20px" }}
                        className="flex-1 bg-transparent outline-none resize-none h-5 overflow-y-auto"
                        placeholder="Написать сообщение..."
                        value={message}
                        onChange={handleInput}
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
    );
}
