import { describe, expect, it } from 'vitest';
import { filterMarkdownSnippets } from '@labword/domain/domain/markdown/formatting-palette.service';

describe('filterMarkdownSnippets', () => {
  it('returns all snippets for empty query', () => {
    expect(filterMarkdownSnippets('').length).toBeGreaterThan(0);
  });

  it('finds checklist snippets by task keyword', () => {
    const results = filterMarkdownSnippets('task');
    expect(results[0]?.id).toBe('task');
  });

  it('finds heading snippets by h2 keyword', () => {
    const results = filterMarkdownSnippets('h2');
    expect(results.some((snippet) => snippet.id === 'heading-2')).toBe(true);
  });

  it('returns empty list when nothing matches', () => {
    expect(filterMarkdownSnippets('zzzz-not-found')).toEqual([]);
  });
});
