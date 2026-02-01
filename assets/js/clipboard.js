async function copyToClipboard(el) {
  const text = el.dataset.clipboardText || el.textContent.trim();

  try {
    await navigator.clipboard.writeText(text);
    console.log("Text copied to clipboard:", text);
  } catch (err) {
    console.error("Clipboard error:", err);
  }
}

function init() {
  document.addEventListener("copy-to-clipboard", async (e) => copyToClipboard(e.target));
}

export { init };
