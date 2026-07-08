import { describe, expect, it } from 'vitest';
import { parseAgentCommand, executeAgentCommand, countWords } from '@labword/app/features/agent-terminal/agent-command.service';
import { asDocumentContent } from '@labword/domain/domain/document/document.types';

describe('AgentCommandService', () => {
  it('parses help command', () => {
    const parsed = parseAgentCommand('help commands');
    expect(parsed?.root).toBe('help');
    expect(parsed?.arguments).toEqual(['commands']);
  });

  it('parses help shortcuts aliases', () => {
    expect(parseAgentCommand('?')?.root).toBe('help');
    expect(parseAgentCommand('hs')?.arguments).toEqual(['shortcuts']);
    expect(parseAgentCommand('help hs')?.arguments).toEqual(['shortcuts']);
  });

  it('executes stats command', () => {
    const content = asDocumentContent('hello world');
    const result = executeAgentCommand('stats', {
      content,
      wordCount: countWords(content),
      onSave: () => undefined,
      onTogglePreview: () => undefined,
      onOpenSettings: () => undefined,
    });
    const text = result.blocks
      .filter((block) => block.kind === 'text')
      .map((block) => block.text)
      .join('\n');
    expect(text).toContain('Words: 2');
  });

  it('returns help table for shortcuts command', () => {
    const content = asDocumentContent('');
    const result = executeAgentCommand('hs', {
      content,
      wordCount: 0,
      onSave: () => undefined,
      onTogglePreview: () => undefined,
      onOpenSettings: () => undefined,
    });
    expect(result.blocks[0]?.kind).toBe('help');
  });

  it('clears scrollback on clear command', () => {
    const content = asDocumentContent('');
    const result = executeAgentCommand('clear', {
      content,
      wordCount: 0,
      onSave: () => undefined,
      onTogglePreview: () => undefined,
      onOpenSettings: () => undefined,
    });
    expect(result.clearScrollback).toBe(true);
  });
});
