import { describe, expect, it } from 'vitest';
import {
  asDocumentContent,
  asFilePath,
  createDocumentId,
  displayTitleFromSnapshot,
  windowTitleFromSnapshot,
  type DocumentSnapshot,
} from '@labword/domain/domain/document/document.types';

function makeSnapshot(overrides: Partial<DocumentSnapshot> = {}): DocumentSnapshot {
  const base: DocumentSnapshot = {
    id: createDocumentId(),
    filePath: null,
    content: asDocumentContent('# Notes\n'),
    isDirty: false,
    title: 'Notes',
  };
  return { ...base, ...overrides };
}

describe('displayTitleFromSnapshot', () => {
  it('uses filename when document is saved', () => {
    const snapshot = makeSnapshot({
      filePath: asFilePath('/tmp/report.md'),
      content: asDocumentContent('# Other Name'),
    });
    expect(displayTitleFromSnapshot(snapshot)).toBe('report.md');
  });
});

describe('windowTitleFromSnapshot', () => {
  it('appends asterisk when document is dirty', () => {
    expect(windowTitleFromSnapshot(makeSnapshot({ isDirty: true, title: 'Notes' }))).toBe('Notes *');
  });

  it('returns plain title when document is saved', () => {
    expect(windowTitleFromSnapshot(makeSnapshot({ title: 'Notes' }))).toBe('Notes');
  });
});
