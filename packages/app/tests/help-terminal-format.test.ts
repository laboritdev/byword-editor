import { describe, expect, it } from 'vitest';
import { helpMarkdownDocument, helpShortcutsDocument } from '@labword/domain/shared/help/help-reference';

describe('helpShortcutsDocument', () => {
  it('includes all shortcut sections', () => {
    const document = helpShortcutsDocument();
    expect(document.title).toBe('Keyboard shortcuts');
    expect(document.sections.map((section) => section.title)).toEqual(['File', 'Edit', 'View']);
    expect(document.sections[0]?.rows.some((row) => row.label === 'New Document' && row.value === '⌘N')).toBe(true);
  });
});

describe('helpMarkdownDocument', () => {
  it('includes structure hints', () => {
    const document = helpMarkdownDocument();
    expect(document.sections.some((section) => section.title === 'Structure')).toBe(true);
  });
});
