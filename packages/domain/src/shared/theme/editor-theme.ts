export interface EditorColorPalette {
  readonly background: string;
  readonly text: string;
  readonly heading: string;
  readonly bold: string;
  readonly italic: string;
  readonly link: string;
  readonly code: string;
  readonly blockquote: string;
  readonly syntaxMarker: string;
  readonly listMarker: string;
  readonly taskChecked: string;
  readonly selection: string;
  readonly activeLine: string;
  readonly statusText: string;
}

export interface EditorLayout {
  readonly fontSizePx: number;
  readonly lineHeight: number;
  readonly columnWidthPx: number;
  readonly horizontalMarginPx: number;
  readonly verticalPaddingPx: number;
}

export const CLASSIC_DARK: EditorColorPalette = {
  background: '#161615',
  text: '#ecebe7',
  heading: '#faf9f6',
  bold: '#faf9f6',
  italic: '#d6d5d1',
  link: '#85b8f5',
  code: '#ccc9c7',
  blockquote: '#8c8b87',
  syntaxMarker: '#61615e',
  listMarker: '#61615e',
  taskChecked: '#7ac28a',
  selection: 'rgba(71, 122, 199, 0.32)',
  activeLine: 'rgba(255, 255, 255, 0.03)',
  statusText: 'rgba(236, 235, 231, 0.32)',
};

export const DEFAULT_LAYOUT: EditorLayout = {
  fontSizePx: 19,
  lineHeight: 1.55,
  columnWidthPx: 580,
  horizontalMarginPx: 72,
  verticalPaddingPx: 72,
};

export const EDITOR_FONT_STACK =
  'Menlo, "SF Mono", ui-monospace, "Cascadia Code", monospace';

export const STATUS_FONT_STACK =
  'ui-monospace, Menlo, "SF Mono", monospace';
