#!/bin/bash
# Installa il Power RAG OpenWebUI nel profilo Kiro dell'utente
# Scarica il pacchetto da Nexus3 (rete aziendale, no auth per download)
# Uso: ./install-power.sh

set -e

echo "=== Installazione Kiro Power: RAG OpenWebUI ==="
echo ""

NEXUS_URL="https://nexus3.aitek.it/repository/aitek-installer/kiro/packages"
PACKAGE_NAME="aitek-kiro-rag-setup-1.0.5.tgz"
POWER_DIR="$HOME/.kiro/powers/rag-openweb-ui"
STEERING_DIR="$HOME/.kiro/steering"

# 1. Verifica Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js non trovato. Installa Node.js >= 18"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js $NODE_VERSION trovato, serve >= 18"
    exit 1
fi
echo "✅ Node.js $(node -v)"

# 2. Scarica pacchetto da Nexus3
echo ""
echo "📥 Download pacchetto da Nexus3..."
TMP_DIR=$(mktemp -d)
DOWNLOAD_URL="${NEXUS_URL}/${PACKAGE_NAME}"

HTTP_CODE=$(curl -sL -o "${TMP_DIR}/${PACKAGE_NAME}" -w "%{http_code}" "$DOWNLOAD_URL")

if [ "$HTTP_CODE" != "200" ]; then
    echo "❌ Download fallito (HTTP $HTTP_CODE)"
    echo "   URL: $DOWNLOAD_URL"
    echo ""
    echo "   Verifica di essere connesso alla rete aziendale."
    rm -rf "$TMP_DIR"
    exit 1
fi
echo "✅ Download completato"

# 3. Estrai pacchetto
echo "📦 Estrazione pacchetto..."
tar xzf "${TMP_DIR}/${PACKAGE_NAME}" -C "$TMP_DIR"
EXTRACT_DIR="$TMP_DIR/package"

if [ ! -f "$EXTRACT_DIR/dist/bundle.js" ]; then
    echo "❌ bundle.js non trovato nel pacchetto"
    rm -rf "$TMP_DIR"
    exit 1
fi
echo "✅ Pacchetto estratto"

# 4. Richiesta token JWT
echo ""
echo "🔑 Per ottenere il token JWT:"
echo "   1. Accedi a https://rag.aitek.it"
echo "   2. Apri la console del browser (F12 → Console)"
echo "   3. Digita: localStorage.getItem('token')"
echo "   4. Copia il valore (senza virgolette)"
echo ""
read -p "Incolla qui il tuo token JWT: " RAG_TOKEN

if [ -z "$RAG_TOKEN" ]; then
    echo "❌ Token non fornito."
    rm -rf "$TMP_DIR"
    exit 1
fi

# 5. Verifica connessione
echo ""
echo "🔍 Verifica connessione..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $RAG_TOKEN" \
    -H "Content-Type: application/json" \
    "https://rag.aitek.it/api/v1/auths/" 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Connessione al RAG System riuscita"
else
    echo "⚠️  Connessione fallita (HTTP $HTTP_CODE). Verifica il token."
    read -p "Vuoi continuare comunque? [y/N]: " CONTINUE
    if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
        rm -rf "$TMP_DIR"
        exit 1
    fi
fi

# 6. Installazione Power
echo ""
echo "⚙️  Installazione Power in Kiro..."

mkdir -p "$POWER_DIR/dist"

# Copia dal pacchetto Nexus3
cp "$EXTRACT_DIR/dist/bundle.js" "$POWER_DIR/dist/bundle.js"
chmod +x "$POWER_DIR/dist/bundle.js"
cp "$EXTRACT_DIR/power/POWER.md" "$POWER_DIR/POWER.md"

# Genera mcp.json con token (dal template nel pacchetto, sostituendo variabili)
cat > "$POWER_DIR/mcp.json" << EOF
{
  "mcpServers": {
    "kiro-rag-openweb-ui": {
      "command": "node",
      "args": ["dist/bundle.js"],
      "cwd": "$POWER_DIR",
      "env": {
        "RAG_BASE_URL": "https://rag.aitek.it",
        "RAG_API_KEY": "$RAG_TOKEN"
      },
      "autoApprove": [
        "list_knowledge_bases",
        "select_knowledge_bases",
        "query_rag",
        "generate_context"
      ]
    }
  }
}
EOF

echo "✅ Power installato in $POWER_DIR"

# 7. Steering file
mkdir -p "$STEERING_DIR"
if [ -f "$EXTRACT_DIR/power/steering/rag-usage.md" ]; then
    cp "$EXTRACT_DIR/power/steering/rag-usage.md" "$STEERING_DIR/rag-usage.md"
    echo "✅ Steering file installato"
fi

# 8. Pulizia
rm -rf "$TMP_DIR"

# Done
echo ""
echo "=== ✅ Installazione completata! ==="
echo ""
echo "Prossimi passi:"
echo "  1. Ricarica Kiro: Ctrl+Shift+P → 'Reload Window'"
echo "  2. Il Power 'RAG OpenWebUI' apparirà nel pannello Powers"
echo "  3. In chat, prova: 'Mostrami le knowledge base disponibili'"
