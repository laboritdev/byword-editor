import { describe, expect, it } from 'vitest';
import {
  INTRO_DEMO_CONTENT,
  initialIntroContent,
} from '@labword/domain/shared/content/intro-demo-content';

describe('intro demo content', () => {
  it('includes markdown samples from the native intro', () => {
    expect(INTRO_DEMO_CONTENT.length).toBeGreaterThan(0);
    expect(INTRO_DEMO_CONTENT).toContain('# Hello');
    expect(INTRO_DEMO_CONTENT).toContain('**LabWord**');
    expect(INTRO_DEMO_CONTENT).toContain('- [ ]');
    expect(INTRO_DEMO_CONTENT).toContain('- [x]');
    expect(INTRO_DEMO_CONTENT).toContain('> Write without noise.');
  });

  it('respects showIntroDemo preference', () => {
    expect(initialIntroContent(true)).toBe(INTRO_DEMO_CONTENT);
    expect(initialIntroContent(false)).toBe('');
  });
});
