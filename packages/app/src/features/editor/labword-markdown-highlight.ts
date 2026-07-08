import type { Extension } from '@codemirror/state';
import { RangeSetBuilder } from '@codemirror/state';
import {
  Decoration,
  EditorView,
  ViewPlugin,
  type DecorationSet,
  type ViewUpdate,
} from '@codemirror/view';
import { buildLineDecorationSpecs } from '@labword/app/features/editor/markdown-line-decorations';
import type { EditorColorPalette } from '@labword/domain/shared/theme/editor-theme';
import type { EditorLayoutConfig } from '@labword/app/features/editor/labword-markdown-highlight.types';

export type { EditorLayoutConfig } from '@labword/app/features/editor/labword-markdown-highlight.types';

function buildDecorations(
  view: EditorView,
  palette: EditorColorPalette,
  layout: EditorLayoutConfig,
): DecorationSet {
  const builder = new RangeSetBuilder<Decoration>();

  for (const { from, to } of view.visibleRanges) {
    let pos = from;
    while (pos <= to) {
      const line = view.state.doc.lineAt(pos);
      if (line.from > to) {
        break;
      }

      const specs = buildLineDecorationSpecs(line.text, line.from, palette, layout);
      for (const spec of specs) {
        builder.add(spec.from, spec.to, spec.decoration);
      }

      pos = line.to + 1;
    }
  }

  return builder.finish();
}

export function labwordMarkdownHighlight(
  palette: EditorColorPalette,
  layout: EditorLayoutConfig,
): ViewPlugin<{
  decorations: DecorationSet;
}> {
  return ViewPlugin.fromClass(
    class {
      decorations: DecorationSet;

      constructor(view: EditorView) {
        this.decorations = buildDecorations(view, palette, layout);
      }

      update(update: ViewUpdate): void {
        if (update.docChanged || update.viewportChanged) {
          this.decorations = buildDecorations(update.view, palette, layout);
        }
      }
    },
    {
      decorations: (value) => value.decorations,
    },
  );
}

export function labwordEditorTheme(
  palette: EditorColorPalette,
  layout: EditorLayoutConfig,
): Extension {
  const sideMargin = `max(${String(layout.horizontalMarginPx)}px, calc((100% - ${String(layout.columnWidthPx)}px) / 2))`;

  return EditorView.theme(
    {
      '&': {
        backgroundColor: palette.background,
        color: palette.text,
        height: '100%',
      },
      '.cm-scroller': {
        fontFamily: 'Menlo, "SF Mono", ui-monospace, monospace',
        fontSize: `${String(layout.fontSizePx)}px`,
        lineHeight: String(layout.lineHeight),
        WebkitFontSmoothing: 'antialiased',
        MozOsxFontSmoothing: 'grayscale',
      },
      '.cm-content': {
        maxWidth: `${String(layout.columnWidthPx)}px`,
        width: `min(${String(layout.columnWidthPx)}px, calc(100% - ${String(layout.horizontalMarginPx * 2)}px))`,
        margin: `0 ${sideMargin}`,
        padding: `${String(layout.verticalPaddingPx)}px 0`,
        caretColor: palette.text,
      },
      '.cm-line': {
        padding: '0',
      },
      '.cm-cursor, .cm-dropCursor': {
        borderLeftColor: palette.text,
        borderLeftWidth: '2px',
      },
      '&.cm-focused .cm-selectionBackground, .cm-selectionBackground, ::selection': {
        backgroundColor: palette.selection,
      },
      '.cm-lw-marker': {
        color: palette.syntaxMarker,
      },
      '.cm-lw-heading': {
        fontWeight: '600',
      },
      '.cm-gutters': {
        display: 'none',
      },
    },
    { dark: true },
  );
}

export function labwordEditorExtensions(
  palette: EditorColorPalette,
  layout: EditorLayoutConfig,
): readonly Extension[] {
  return [labwordEditorTheme(palette, layout), labwordMarkdownHighlight(palette, layout)];
}
