---
name: "rag-openweb-ui"
displayName: "RAG OpenWebUI"
description: "Interroga le knowledge base aziendali del sistema RAG basato su OpenWebUI direttamente da Kiro. Ricerca semantica su documenti, offerte, gare, procedure ISO."
keywords: ["rag", "knowledge base", "documenti", "ricerca", "query", "openwebui", "aitek"]
author: "Aitek S.p.A."
---

# RAG OpenWebUI Power

Questo Power connette Kiro al sistema RAG aziendale basato su OpenWebUI (https://rag.aitek.it), permettendo di interrogare le knowledge base aziendali direttamente dalla chat.

## Overview

Il Power fornisce 4 tool per interagire con il RAG:
- **list_knowledge_bases** — Elenca tutte le KB disponibili
- **select_knowledge_bases** — Seleziona una o più KB come fonte attiva
- **query_rag** — Ricerca semantica nelle KB selezionate
- **generate_context** — Genera contesto combinato RAG + Steering

## Prerequisiti

- Node.js >= 18
- Accesso a https://rag.aitek.it con un account valido
- Un token JWT (ottenibile dalla console browser: `localStorage.getItem('token')`)

## Installazione

### Opzione 1: Script automatico (consigliata)

```bash
git clone https://gitlab.aitek.it/oddera/kiro-rag.git
cd kiro-rag
./setup.sh
```

Lo script installa le dipendenze, compila, chiede il token, configura Kiro e verifica la connessione.

### Opzione 2: Manuale

```bash
git clone https://gitlab.aitek.it/oddera/kiro-rag.git
cd kiro-rag
npm install
npm run build
```

Poi crea/modifica `~/.kiro/settings/mcp.json`:

```json
{
  "mcpServers": {
    "kiro-rag-openweb-ui": {
      "command": "node",
      "args": ["dist/index.js"],
      "cwd": "/percorso/assoluto/a/kiro-rag",
      "env": {
        "RAG_BASE_URL": "https://rag.aitek.it",
        "RAG_API_KEY": "IL_TUO_TOKEN_JWT"
      }
    }
  }
}
```

Ricarica Kiro con Ctrl+Shift+P → "Reload Window".

## Flusso di Utilizzo

### 1. Elencare le Knowledge Base disponibili

Usa il tool `list_knowledge_bases` per vedere tutte le KB disponibili nel sistema RAG.

### 2. Selezionare le Knowledge Base

Usa il tool `select_knowledge_bases` con i nomi delle KB che vuoi usare come fonte.
Puoi selezionarne una o più contemporaneamente. La selezione sostituisce quella precedente.

### 3. Interrogare il RAG

Usa il tool `query_rag` per fare domande in linguaggio naturale.

Parametri:
- `query` (obbligatorio): la domanda in linguaggio naturale
- `top_k` (opzionale, default 5): numero massimo di risultati (1-50)

### 4. Generare Contesto Combinato

Usa il tool `generate_context` per ottenere un contesto strutturato che combina risultati RAG con istruzioni aggiuntive.

Parametri:
- `query` (obbligatorio): la domanda
- `top_k` (opzionale, default 5): numero massimo di risultati
- `context_prefix` (opzionale, max 2000 char): istruzioni aggiuntive per raffinare la ricerca

## Knowledge Base Disponibili

| Nome | Descrizione |
|------|-------------|
| documenti gara teralp | Documenti per gara Teralp |
| documenti di offerta | Offerte prodotte |
| documenti di gara | Documenti di gara generici |
| documenti tecnici per gare | Documenti tecnici per gare |
| Offerte-Aitek | Offerte fatte da Aitek |
| Aitek-ISO | Sistema qualità ISO e procedure sviluppo Software |
| documenti tecnici aitek | Offerte tecniche e whitepaper |

## Mapping KB per Argomento

| Argomento | KB da selezionare |
|-----------|-------------------|
| Qualità, ISO, procedure | Aitek-ISO |
| Offerte tecniche, whitepaper | documenti tecnici aitek |
| Offerte commerciali passate | Offerte-Aitek |
| Gare d'appalto (generiche) | documenti di gara |
| Gara Teralp specifica | documenti gara teralp |
| Documenti tecnici per gare | documenti tecnici per gare |
| Offerte prodotte | documenti di offerta |

## Esempi d'Uso

### Cercare informazioni tecniche
> "Seleziona documenti tecnici aitek e cerca architettura microservizi"

### Cercare procedure ISO
> "Seleziona Aitek-ISO e cerca procedura di gestione delle non conformità"

### Preparare un'offerta
> "Seleziona Offerte-Aitek e documenti tecnici per gare, poi cerca requisiti tecnici videosorveglianza"

### Analizzare una gara
> "Seleziona documenti gara teralp e cerca requisiti di partecipazione"

## Best Practices

- Seleziona sempre le KB pertinenti PRIMA di fare una query
- Seleziona più KB contemporaneamente se la domanda è trasversale
- Se la query non produce risultati, prova a riformulare o selezionare KB diverse
- Aumenta `top_k` (fino a 50) se servono più risultati
- Usa `generate_context` quando devi generare documenti basati su contesto RAG

## Troubleshooting

### "Health check fallito"
- Il token JWT potrebbe essere scaduto
- Verifica la raggiungibilità di https://rag.aitek.it
- Rigenera il token dalla console browser

### "Knowledge base non trovate"
- Chiama prima `list_knowledge_bases` per popolare la cache
- Verifica che il nome sia esatto (case-sensitive)

### Il server non si avvia
- Ricompila: `cd kiro-rag && npm run build`
- Verifica che Node.js >= 18 sia installato
- Ricarica Kiro: Ctrl+Shift+P → "Reload Window"

### Token scaduto
1. Accedi a https://rag.aitek.it
2. Console browser → `localStorage.getItem('token')`
3. Aggiorna `RAG_API_KEY` in `~/.kiro/settings/mcp.json`
4. Ricarica Kiro
