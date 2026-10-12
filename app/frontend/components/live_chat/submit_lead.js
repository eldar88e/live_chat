export async function submitLead({
  apiUrl,
  headers,
  chatId,
  externalId,
  contactToken,
  contact,
}) {
  const refreshToken = async () => {
    const res = await fetch(`${apiUrl}/api/v1/widget/chats`, {
      method: "POST",
      headers,
      body: JSON.stringify({ external_id: externalId }),
    });
    if (!res.ok) return null;
    const data = await res.json();
    return data.chat_id === chatId ? data.contact_token : null;
  };

  const send = (token) =>
    fetch(`${apiUrl}/api/v1/widget/chats/${chatId}/leads`, {
      method: "POST",
      headers,
      body: JSON.stringify({ contact_token: token, contact }),
    });

  let token = contactToken;
  if (!token) token = await refreshToken();
  if (!token)
    throw new Error("Не удалось обновить сессию чата. Обновите страницу.");

  let res = await send(token);
  if (res.status === 401 && contactToken) {
    token = await refreshToken();
    if (token) res = await send(token);
  }
  return res;
}
