import { forwardRef, useEffect, useImperativeHandle, useRef } from 'react';
import { EditorState, type Extension } from '@codemirror/state';
import { EditorView, drawSelection, keymap } from '@codemirror/view';
import { defaultKeymap, history, historyKeymap } from '@codemirror/commands';
import type { DocumentContent } from '@labword/domain/domain/document/document.types';
import {
  CLASSIC_DARK,
  type EditorLayout,
} from '@labword/domain/shared/theme/editor-theme';
import type { MarkdownSnippet } from '@labword/domain/shared/markdown/markdown-snippets';
import { labwordEditorExtensions } from '@labword/app/features/editor/labword-markdown-highlight';
import { listEditorExtensions } from '@labword/app/features/editor/list-editor-extensions';

export interface CursorPosition {
  readonly line: number;
  readonly column: number;
}

export interface MarkdownEditorFeatureProps {
  readonly content: DocumentContent;
  readonly layout: EditorLayout;
  readonly onChange: (content: DocumentContent) => void;
  readonly onCursorChange: (cursor: CursorPosition) => void;
}

export interface MarkdownEditorFeatureHandle {
  readonly focusEditor: () => void;
  readonly insertSnippet: (snippet: Pick<MarkdownSnippet, 'insert' | 'selectionStart' | 'selectionEnd'>) => void;
}

function minimalEditorSetup(): readonly Extension[] {
  return [
    history(),
    drawSelection(),
    EditorView.lineWrapping,
    keymap.of([...defaultKeymap, ...historyKeymap]),
  ];
}

export const MarkdownEditorFeature = forwardRef<
  MarkdownEditorFeatureHandle,
  MarkdownEditorFeatureProps
>(function MarkdownEditorFeature(props, ref): React.JSX.Element {
  const hostRef = useRef<HTMLDivElement>(null);
  const viewRef = useRef<EditorView | null>(null);
  const { content, layout, onChange, onCursorChange } = props;

  useImperativeHandle(ref, () => ({
    focusEditor: (): void => {
      viewRef.current?.focus();
    },
    insertSnippet: (snippet): void => {
      const view = viewRef.current;
      if (view === null) {
        return;
      }
      const { from, to } = view.state.selection.main;
      view.dispatch({
        changes: { from, to, insert: snippet.insert },
        selection: {
          anchor: from + snippet.selectionStart,
          head: from + snippet.selectionEnd,
        },
      });
      view.focus();
    },
  }));

  useEffect(() => {
    const host = hostRef.current;
    if (host === null) {
      return undefined;
    }

    const view = new EditorView({
      state: EditorState.create({
        doc: content,
        extensions: [
          ...minimalEditorSetup(),
          ...labwordEditorExtensions(CLASSIC_DARK, layout),
          listEditorExtensions(),
          EditorView.updateListener.of((update) => {
            if (update.docChanged) {
              onChange(update.state.doc.toString() as DocumentContent);
            }
            if (update.selectionSet) {
              const head = update.state.selection.main.head;
              const line = update.state.doc.lineAt(head);
              onCursorChange({
                line: line.number,
                column: head - line.from + 1,
              });
            }
          }),
        ],
      }),
      parent: host,
    });

    viewRef.current = view;
    view.focus();

    return (): void => {
      view.destroy();
      viewRef.current = null;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps -- mount once
  }, []);

  useEffect(() => {
    const view = viewRef.current;
    if (view === null) {
      return;
    }
    const current = view.state.doc.toString();
    if (current !== content) {
      view.dispatch({
        changes: { from: 0, to: current.length, insert: content },
        selection: { anchor: 0 },
      });
    }
  }, [content]);

  return <div className="editor-host" ref={hostRef} />;
});
