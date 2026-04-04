function getTg() {
  return window.Telegram?.WebApp || null;
}

export function initTelegram() {
  const tg = getTg();
  if (tg) {
    try { tg.ready(); } catch(e) {}
    try { tg.expand(); } catch(e) {}
  }
}

export function getInitData() {
  return getTg()?.initData || "";
}

export function getTgUser() {
  return getTg()?.initDataUnsafe?.user || null;
}

export function getColorScheme() {
  return getTg()?.colorScheme || "light";
}

export function closeMiniApp() {
  try { getTg()?.close(); } catch(e) {}
}

export function haptic(type = "impact") {
  try {
    const tg = getTg();
    if (type === "impact") tg?.HapticFeedback?.impactOccurred("medium");
    if (type === "success") tg?.HapticFeedback?.notificationOccurred("success");
  } catch(e) {}
}
