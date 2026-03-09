# TextChunker4D Overview

TextChunker4D is designed to split long documents into stable chunks that can be embedded and searched.

## Chunking Strategy

The project starts with Markdown-aware section extraction.
Large sections are then re-split with a recursive character splitter that prefers paragraph, line, and space boundaries before falling back to fixed-length slices.

## Storage Model

Each imported source becomes one document record.
Each chunk stores its text, position, heading metadata, and optional embedding payload.

### Retrieval

Retrieval compares an embedded query to stored chunk vectors.
The highest scoring chunks become the context used for answer generation.

```4d
// Headings inside fenced code blocks are ignored by the markdown splitter.
# not-a-real-heading
```

## RAG Workflow

The sample workflow imports Markdown, creates chunk records, stores embeddings, retrieves matching chunks, and produces an answer grounded in the stored context.
