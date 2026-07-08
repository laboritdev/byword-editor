import { describe, expect, it } from 'vitest';
import { buildLineDecorationSpecs, decorationSpecsOverlap } from '@labword/app/features/editor/markdown-line-decorations';
import { CLASSIC_DARK, DEFAULT_LAYOUT } from '@labword/domain/shared/theme/editor-theme';

describe('buildLineDecorationSpecs', () => {
  it('highlights heading markers and content', () => {
    const specs = buildLineDecorationSpecs('# Title', 0, CLASSIC_DARK, DEFAULT_LAYOUT);
    expect(specs.length).toBeGreaterThanOrEqual(2);
    expect(decorationSpecsOverlap(specs)).toBe(false);
  });

  it('highlights blockquote lines', () => {
    const specs = buildLineDecorationSpecs('> Quote text', 0, CLASSIC_DARK, DEFAULT_LAYOUT);
    expect(specs.length).toBeGreaterThanOrEqual(2);
  });

  it('highlights divider lines', () => {
    const specs = buildLineDecorationSpecs('---', 0, CLASSIC_DARK, DEFAULT_LAYOUT);
    expect(specs).toHaveLength(1);
  });

  it('highlights bold, italic, and inline code', () => {
    const text = '**bold** and *italic* and `code`';
    const specs = buildLineDecorationSpecs(text, 0, CLASSIC_DARK, DEFAULT_LAYOUT);
    expect(specs.length).toBeGreaterThanOrEqual(6);
    expect(decorationSpecsOverlap(specs)).toBe(false);
  });

  it('highlights markdown and autolinks', () => {
    const text = '[LabWord](https://example.com) and <https://example.com>';
    const specs = buildLineDecorationSpecs(text, 0, CLASSIC_DARK, DEFAULT_LAYOUT);
    expect(specs.length).toBe(2);
  });

  it('highlights checklist lines', () => {
    const specs = buildLineDecorationSpecs('- [ ] Task item', 0, CLASSIC_DARK, DEFAULT_LAYOUT);
    expect(specs.length).toBeGreaterThanOrEqual(4);
  });

  it('highlights bullet and numbered list markers', () => {
    const bulletSpecs = buildLineDecorationSpecs('- Item', 0, CLASSIC_DARK, DEFAULT_LAYOUT);
    const numberedSpecs = buildLineDecorationSpecs('1. Item', 0, CLASSIC_DARK, DEFAULT_LAYOUT);
    expect(bulletSpecs.length).toBeGreaterThanOrEqual(1);
    expect(numberedSpecs.length).toBeGreaterThanOrEqual(1);
  });
});
