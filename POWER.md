---
name: "rag-openweb-ui"
displayName: "RAG OpenWebUI"
description: "Interroga le knowledge base aziendali via RAG OpenWebUI."
keywords: ["rag", "knowledge base", "documenti", "ricerca", "query", "openwebui"]
author: "Aitek S.p.A."
---

# RAG OpenWebUI Power

Connette Kiro al sistema RAG aziendale per ricerca semantica nelle knowledge base.

## Tools

- `list_knowledge_bases` — Elenca le KB disponibili
- `select_knowledge_bases` — Seleziona KB attive
- `query_rag` — Ricerca semantica
- `generate_context` — Contesto combinato RAG + istruzioni

## Installazione

```bash
git clone https://github.com/andyodd/kiro-power-rag.git
cd kiro-power-rag
./install-power.sh
```

Requisiti: Node.js >= 18, accesso rete aziendale, token JWT da https://rag.aitek.it
