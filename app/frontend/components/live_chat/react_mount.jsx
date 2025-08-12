import React from 'react';
import { createRoot } from 'react-dom/client';
import LiveChat from './LiveChat';

document.addEventListener("DOMContentLoaded", () => {
    const container = document.getElementById('live-chat-container');
    if (container) {
        const apiUrl = container.getAttribute('data-api-url');
        const token = container.getAttribute('data-token');
        const domain = container.getAttribute('data-domain');
        const root = createRoot(container);
        root.render(<LiveChat apiUrl={apiUrl} token={token} domain={domain} />);
    }
});
