import { describe, expect, it } from 'vitest';
import {
  DEFAULT_EDITOR_PREFERENCES,
  decreaseFontSize,
  increaseFontSize,
} from '@labword/domain/shared/preferences/editor-preferences';

describe('increaseFontSize', () => {
  it('increases by one step up to the maximum', () => {
    expect(increaseFontSize(DEFAULT_EDITOR_PREFERENCES).fontSizePx).toBe(20);
    expect(increaseFontSize({ ...DEFAULT_EDITOR_PREFERENCES, fontSizePx: 28 }).fontSizePx).toBe(28);
  });
});

describe('decreaseFontSize', () => {
  it('decreases by one step down to the minimum', () => {
    expect(decreaseFontSize(DEFAULT_EDITOR_PREFERENCES).fontSizePx).toBe(18);
    expect(decreaseFontSize({ ...DEFAULT_EDITOR_PREFERENCES, fontSizePx: 12 }).fontSizePx).toBe(12);
  });
});
