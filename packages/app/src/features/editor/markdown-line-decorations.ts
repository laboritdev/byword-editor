import { Decoration } from '@codemirror/view';
import type { EditorColorPalette } from '@labword/domain/shared/theme/editor-theme';
import type { EditorLayoutConfig } from '@labword/app/features/editor/labword-markdown-highlight.types';

export interface DecorationSpec {
  readonly from: number;
  readonly to: number;
  readonly decoration: Decoration;
}

const HEADING_PATTERN = /^(#{1,6})(\s+)(.+)$/;
const TASK_PATTERN = /^(\s*[-*+]\s+\[)([ xX])(\])(\s*)(.*)$/;
const BULLET_PATTERN = /^(\s*[-*+]\s+)(.+)$/;
const NUMBERED_PATTERN = /^(\s*\d+\.\s+)(.+)$/;
const BLOCKQUOTE_PATTERN = /^(>\s?)(.*)$/;
const DIVIDER_PATTERN = /^(-{3,}|\*{3,})$/;

const CODE_PATTERN = /(`)([^`]+)(`)/g;
const BOLD_PATTERN = /(\*\*)(.+?)(\*\*)|(__)(.+?)(__)/g;
const ITALIC_PATTERN = /(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)|(?<!_)_(?!_)(.+?)(?<!_)_(?!_)/g;
const MARKDOWN_LINK_PATTERN = /(\[[^\]]+\]\([^)]+\))/g;
const AUTO_LINK_PATTERN = /(<https?:\/\/[^>]+>)/g;

function headingSizeBoost(level: number): number {
  switch (level) {
    case 1:
      return 6;
    case 2:
      return 4;
    case 3:
      return 2;
    case 4:
      return 1;
    default:
      return 0;
  }
}

function headingKern(level: number): number {
  switch (level) {
    case 1:
      return 0.6;
    case 2:
      return 0.45;
    case 3:
      return 0.3;
    default:
      return 0.15;
  }
}

function markerDecoration(className = 'cm-lw-marker'): Decoration {
  return Decoration.mark({ class: className });
}

function styleDecoration(style: string, className?: string): Decoration {
  if (className !== undefined) {
    return Decoration.mark({
      class: className,
      attributes: { style },
    });
  }
  return Decoration.mark({
    attributes: { style },
  });
}

function pushMarkSpec(
  specs: DecorationSpec[],
  from: number,
  to: number,
  decoration: Decoration,
): void {
  if (from < to) {
    specs.push({ from, to, decoration });
  }
}

function pushLineSpec(specs: DecorationSpec[], lineStart: number, decoration: Decoration): void {
  specs.push({ from: lineStart, to: lineStart, decoration });
}

function applyHeadingDecorations(
  specs: DecorationSpec[],
  text: string,
  lineStart: number,
  palette: EditorColorPalette,
  layout: EditorLayoutConfig,
): void {
  const match = HEADING_PATTERN.exec(text);
  if (match === null) {
    return;
  }

  const hashes = match[1] ?? '';
  const space = match[2] ?? '';
  const markerEnd = lineStart + hashes.length + space.length;
  const level = hashes.length;
  const fontSize = layout.fontSizePx + headingSizeBoost(level);

  pushMarkSpec(specs, lineStart, markerEnd, markerDecoration());
  pushMarkSpec(
    specs,
    markerEnd,
    lineStart + text.length,
    styleDecoration(
      [
        `color: ${palette.heading}`,
        `font-size: ${String(fontSize)}px`,
        'font-weight: 600',
        `letter-spacing: ${String(headingKern(level))}px`,
      ].join('; '),
      'cm-lw-heading',
    ),
  );
}

function applyTaskDecorations(
  specs: DecorationSpec[],
  text: string,
  lineStart: number,
  palette: EditorColorPalette,
): boolean {
  const match = TASK_PATTERN.exec(text);
  if (match === null) {
    return false;
  }

  const prefix = match[1] ?? '';
  const check = match[2] ?? '';
  const bracket = match[3] ?? '';
  const gap = match[4] ?? '';

  const prefixEnd = lineStart + prefix.length;
  const checkEnd = prefixEnd + check.length;
  const bracketEnd = checkEnd + bracket.length;
  const gapEnd = bracketEnd + gap.length;

  pushMarkSpec(specs, lineStart, prefixEnd, markerDecoration());
  if (check.toLowerCase() === 'x') {
    pushMarkSpec(
      specs,
      prefixEnd,
      checkEnd,
      styleDecoration(`color: ${palette.taskChecked}`, 'cm-lw-task-checked'),
    );
  } else {
    pushMarkSpec(specs, prefixEnd, checkEnd, markerDecoration());
  }
  pushMarkSpec(specs, checkEnd, bracketEnd, markerDecoration());
  pushMarkSpec(specs, bracketEnd, gapEnd, markerDecoration());

  if (check.toLowerCase() === 'x' && gapEnd < lineStart + text.length) {
    pushMarkSpec(
      specs,
      gapEnd,
      lineStart + text.length,
      styleDecoration('opacity: 0.45; text-decoration: line-through', 'cm-lw-task-done'),
    );
  }

  return true;
}

function applyListDecorations(specs: DecorationSpec[], text: string, lineStart: number): void {
  const bulletMatch = BULLET_PATTERN.exec(text);
  if (bulletMatch !== null) {
    const marker = bulletMatch[1] ?? '';
    pushMarkSpec(specs, lineStart, lineStart + marker.length, markerDecoration());
    return;
  }

  const numberedMatch = NUMBERED_PATTERN.exec(text);
  if (numberedMatch !== null) {
    const marker = numberedMatch[1] ?? '';
    pushMarkSpec(specs, lineStart, lineStart + marker.length, markerDecoration());
  }
}

function applyBlockquoteDecorations(
  specs: DecorationSpec[],
  text: string,
  lineStart: number,
  palette: EditorColorPalette,
): boolean {
  const match = BLOCKQUOTE_PATTERN.exec(text);
  if (match === null || text.length === 0) {
    return false;
  }

  const marker = match[1] ?? '';
  const markerEnd = lineStart + marker.length;

  pushLineSpec(
    specs,
    lineStart,
    Decoration.line({
      attributes: {
        class: 'cm-lw-blockquote-line',
        style: `color: ${palette.blockquote}; font-style: italic`,
      },
    }),
  );
  pushMarkSpec(specs, lineStart, markerEnd, markerDecoration());
  return true;
}

function applyDividerDecoration(
  specs: DecorationSpec[],
  text: string,
  lineStart: number,
  palette: EditorColorPalette,
): boolean {
  if (!DIVIDER_PATTERN.test(text)) {
    return false;
  }
  pushLineSpec(
    specs,
    lineStart,
    Decoration.line({
      attributes: {
        class: 'cm-lw-divider-line',
        style: `color: ${palette.syntaxMarker}`,
      },
    }),
  );
  return true;
}

function applyDelimitedMatches(
  specs: DecorationSpec[],
  text: string,
  lineStart: number,
  pattern: RegExp,
  contentStyle: string,
): void {
  const regex = new RegExp(pattern.source, pattern.flags.includes('g') ? pattern.flags : `${pattern.flags}g`);
  for (const match of text.matchAll(regex)) {
    const matchIndex = match.index;
    const start = lineStart + matchIndex;

    if (match[1] !== undefined && match[2] !== undefined && match[3] !== undefined) {
      pushMarkSpec(specs, start, start + match[1].length, markerDecoration());
      pushMarkSpec(
        specs,
        start + match[1].length,
        start + match[1].length + match[2].length,
        styleDecoration(contentStyle),
      );
      pushMarkSpec(
        specs,
        start + match[1].length + match[2].length,
        start + match[0].length,
        markerDecoration(),
      );
      continue;
    }

    if (match[1] !== undefined && match[2] !== undefined) {
      pushMarkSpec(specs, start, start + match[1].length, markerDecoration());
      pushMarkSpec(specs, start + match[1].length, start + match[0].length, styleDecoration(contentStyle));
    }
  }
}

function applyWholeMatchDecorations(
  specs: DecorationSpec[],
  text: string,
  lineStart: number,
  pattern: RegExp,
  contentStyle: string,
): void {
  const regex = new RegExp(pattern.source, pattern.flags.includes('g') ? pattern.flags : `${pattern.flags}g`);
  for (const match of text.matchAll(regex)) {
    if (match[0].length === 0) {
      continue;
    }
    const start = lineStart + match.index;
    pushMarkSpec(specs, start, start + match[0].length, styleDecoration(contentStyle, 'cm-lw-link'));
  }
}

function applyInlineDecorations(
  specs: DecorationSpec[],
  text: string,
  lineStart: number,
  palette: EditorColorPalette,
  layout: EditorLayoutConfig,
): void {
  const codeSize = Math.max(11, layout.fontSizePx - 0.5);

  applyDelimitedMatches(
    specs,
    text,
    lineStart,
    CODE_PATTERN,
    `color: ${palette.code}; font-family: Menlo, "SF Mono", ui-monospace, monospace; font-size: ${String(codeSize)}px`,
  );

  applyDelimitedMatches(
    specs,
    text,
    lineStart,
    BOLD_PATTERN,
    `color: ${palette.bold}; font-weight: 600`,
  );

  applyDelimitedMatches(
    specs,
    text,
    lineStart,
    ITALIC_PATTERN,
    `color: ${palette.italic}; font-style: italic`,
  );

  applyWholeMatchDecorations(
    specs,
    text,
    lineStart,
    MARKDOWN_LINK_PATTERN,
    `color: ${palette.link}; text-decoration: underline`,
  );

  applyWholeMatchDecorations(
    specs,
    text,
    lineStart,
    AUTO_LINK_PATTERN,
    `color: ${palette.link}; text-decoration: underline`,
  );
}

export function buildLineDecorationSpecs(
  text: string,
  lineStart: number,
  palette: EditorColorPalette,
  layout: EditorLayoutConfig,
): readonly DecorationSpec[] {
  const specs: DecorationSpec[] = [];

  if (applyDividerDecoration(specs, text, lineStart, palette)) {
    return specs;
  }

  applyBlockquoteDecorations(specs, text, lineStart, palette);
  applyHeadingDecorations(specs, text, lineStart, palette, layout);

  const isTask = applyTaskDecorations(specs, text, lineStart, palette);
  if (!isTask) {
    applyListDecorations(specs, text, lineStart);
  }

  applyInlineDecorations(specs, text, lineStart, palette, layout);

  specs.sort((left, right) => left.from - right.from || left.to - right.to);
  return specs;
}

export function decorationSpecsOverlap(specs: readonly DecorationSpec[]): boolean {
  for (let index = 1; index < specs.length; index += 1) {
    const previous = specs[index - 1];
    const current = specs[index];
    if (previous !== undefined && current !== undefined && current.from < previous.to) {
      return true;
    }
  }
  return false;
}
