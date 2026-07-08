import { describe, expect, it } from 'vitest';
import {
  helpCategoriesDocument,
  resolveAgentCommandRoot,
  resolveHelpTopic,
} from '@labword/domain/domain/agent/command-registry';

describe('resolveHelpTopic', () => {
  it('maps help topic shortcuts', () => {
    expect(resolveHelpTopic('hs')).toBe('shortcuts');
    expect(resolveHelpTopic('hc')).toBe('commands');
    expect(resolveHelpTopic('hm')).toBe('markdown');
    expect(resolveHelpTopic('shortcuts')).toBe('shortcuts');
  });
});

describe('resolveAgentCommandRoot', () => {
  it('maps root help aliases', () => {
    expect(resolveAgentCommandRoot('?')).toEqual({ root: 'help', arguments: [] });
    expect(resolveAgentCommandRoot('hs')).toEqual({ root: 'help', arguments: ['shortcuts'] });
  });
});

describe('helpCategoriesDocument', () => {
  it('lists help command shortcuts', () => {
    const document = helpCategoriesDocument();
    expect(document.sections[0]?.rows).toEqual([
      { label: 'help', value: '?' },
      { label: 'help shortcuts', value: 'hs' },
      { label: 'help markdown', value: 'hm' },
      { label: 'help commands', value: 'hc' },
    ]);
  });
});
