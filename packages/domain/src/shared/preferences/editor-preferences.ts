import type { EditorLayout } from '@labword/domain/shared/theme/editor-theme';
import {
  FONT_SIZE_STEP_PX,
  MAX_FONT_SIZE_PX,
  MIN_FONT_SIZE_PX,
} from '@labword/domain/shared/constants/app.constants';

export type TextWidthPreset = 'narrow' | 'medium' | 'wide';

export interface EditorPreferences {
  readonly fontSizePx: number;
  readonly lineHeight: number;
  readonly textWidth: TextWidthPreset;
  readonly showStatusBar: boolean;
  readonly showIntroDemo: boolean;
}

const STORAGE_KEY = 'labword.editor.preferences';

export const DEFAULT_EDITOR_PREFERENCES: EditorPreferences = {
  fontSizePx: 19,
  lineHeight: 1.55,
  textWidth: 'medium',
  showStatusBar: true,
  showIntroDemo: true,
};

const COLUMN_WIDTHS: Record<TextWidthPreset, number> = {
  narrow: 480,
  medium: 580,
  wide: 720,
};

export function columnWidthForPreset(preset: TextWidthPreset): number {
  return COLUMN_WIDTHS[preset];
}

export function layoutFromPreferences(preferences: EditorPreferences): EditorLayout {
  return {
    fontSizePx: preferences.fontSizePx,
    lineHeight: preferences.lineHeight,
    columnWidthPx: columnWidthForPreset(preferences.textWidth),
    horizontalMarginPx: 72,
    verticalPaddingPx: 72,
  };
}

export function loadEditorPreferences(): EditorPreferences {
  if (typeof localStorage === 'undefined') {
    return DEFAULT_EDITOR_PREFERENCES;
  }

  const raw = localStorage.getItem(STORAGE_KEY);
  if (raw === null) {
    return DEFAULT_EDITOR_PREFERENCES;
  }

  try {
    const parsed = JSON.parse(raw) as Partial<EditorPreferences>;
    return {
      fontSizePx: parsed.fontSizePx ?? DEFAULT_EDITOR_PREFERENCES.fontSizePx,
      lineHeight: parsed.lineHeight ?? DEFAULT_EDITOR_PREFERENCES.lineHeight,
      textWidth: parsed.textWidth ?? DEFAULT_EDITOR_PREFERENCES.textWidth,
      showStatusBar: parsed.showStatusBar ?? DEFAULT_EDITOR_PREFERENCES.showStatusBar,
      showIntroDemo: parsed.showIntroDemo ?? DEFAULT_EDITOR_PREFERENCES.showIntroDemo,
    };
  } catch {
    return DEFAULT_EDITOR_PREFERENCES;
  }
}

export function saveEditorPreferences(preferences: EditorPreferences): void {
  if (typeof localStorage === 'undefined') {
    return;
  }
  localStorage.setItem(STORAGE_KEY, JSON.stringify(preferences));
}

export function increaseFontSize(preferences: EditorPreferences): EditorPreferences {
  const next = Math.min(preferences.fontSizePx + FONT_SIZE_STEP_PX, MAX_FONT_SIZE_PX);
  if (next === preferences.fontSizePx) {
    return preferences;
  }
  return { ...preferences, fontSizePx: next };
}

export function decreaseFontSize(preferences: EditorPreferences): EditorPreferences {
  const next = Math.max(preferences.fontSizePx - FONT_SIZE_STEP_PX, MIN_FONT_SIZE_PX);
  if (next === preferences.fontSizePx) {
    return preferences;
  }
  return { ...preferences, fontSizePx: next };
}
