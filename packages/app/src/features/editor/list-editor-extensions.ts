import type { Extension } from '@codemirror/state';
import { Prec } from '@codemirror/state';
import { keymap, EditorView } from '@codemirror/view';
import { handleListEnter } from '@labword/domain/domain/markdown/list-continuation.service';
import { toggleTaskCheckboxNear } from '@labword/domain/domain/markdown/task-list.service';

function applyTextEdit(
  view: EditorView,
  text: string,
  cursor: number,
): void {
  const current = view.state.doc.toString();
  if (current === text) {
    view.dispatch({
      selection: { anchor: Math.min(cursor, text.length) },
    });
    return;
  }

  view.dispatch({
    changes: { from: 0, to: current.length, insert: text },
    selection: { anchor: Math.min(cursor, text.length) },
  });
}

export function listEditorExtensions(): Extension {
  return [
    Prec.highest(
      keymap.of([
        {
          key: 'Enter',
          run: (view): boolean => {
            const cursor = view.state.selection.main.head;
            const result = handleListEnter(view.state.doc.toString(), cursor);
            if (result === null) {
              return false;
            }
            applyTextEdit(view, result.text, result.cursor);
            return true;
          },
        },
      ]),
    ),
    EditorView.domEventHandlers({
      mousedown: (event, view): boolean => {
        if (event.button !== 0) {
          return false;
        }

        const coords = { x: event.clientX, y: event.clientY };
        const pos = view.posAtCoords(coords);
        if (pos === null) {
          return false;
        }

        const result = toggleTaskCheckboxNear(view.state.doc.toString(), pos);
        if (result === null) {
          return false;
        }

        event.preventDefault();
        applyTextEdit(view, result.text, result.cursor);
        return true;
      },
    }),
  ];
}
