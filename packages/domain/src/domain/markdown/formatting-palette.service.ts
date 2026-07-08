import type { MarkdownSnippet } from '@labword/domain/shared/markdown/markdown-snippets';
import { MARKDOWN_SNIPPETS } from '@labword/domain/shared/markdown/markdown-snippets';

function scoreSnippet(snippet: MarkdownSnippet, query: string): number {
  const title = snippet.title.toLowerCase();
  const syntax = snippet.syntax.toLowerCase();
  const keywords = snippet.keywords.join(' ').toLowerCase();
  const haystack = `${title} ${keywords} ${syntax}`;

  if (title.startsWith(query)) {
    return 100;
  }
  if (keywords.split(' ').some((keyword) => keyword.startsWith(query))) {
    return 90;
  }
  if (haystack.includes(query)) {
    return 70 + Math.max(0, 20 - haystack.indexOf(query));
  }

  let hayIndex = 0;
  for (const char of query) {
    const found = haystack.indexOf(char, hayIndex);
    if (found === -1) {
      return 0;
    }
    hayIndex = found + 1;
  }
  return 40;
}

export function filterMarkdownSnippets(query: string): readonly MarkdownSnippet[] {
  const normalized = query.trim().toLowerCase();
  if (normalized.length === 0) {
    return MARKDOWN_SNIPPETS;
  }

  return MARKDOWN_SNIPPETS
    .map((snippet) => ({ snippet, score: scoreSnippet(snippet, normalized) }))
    .filter((entry) => entry.score > 0)
    .sort((left, right) => right.score - left.score || left.snippet.title.localeCompare(right.snippet.title))
    .map((entry) => entry.snippet);
}
