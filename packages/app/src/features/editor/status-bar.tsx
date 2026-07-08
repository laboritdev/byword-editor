import type { DocumentContent, DocumentSnapshot } from '@labword/domain/domain/document/document.types';
import type { CursorPosition } from '@labword/app/features/editor/markdown-editor-feature';

export interface StatusBarProps {
  readonly document: DocumentSnapshot;
  readonly cursor: CursorPosition;
}

export function countWords(text: DocumentContent): number {
  const matches = text.trim().match(/\S+/g);
  return matches?.length ?? 0;
}

export function StatusBar(props: StatusBarProps): React.JSX.Element {
  const { document, cursor } = props;
  const words = countWords(document.content);
  const chars = document.content.length;
  const wordLabel = words === 1 ? 'word' : 'words';
  const charLabel = chars === 1 ? 'character' : 'characters';
  const pathLabel = document.filePath ?? 'Untitled';
  const saveLabel = document.filePath === null
    ? document.isDirty
      ? 'Edited'
      : 'Untitled'
    : document.isDirty
      ? 'Edited'
      : 'Saved';

  return (
    <footer className="status-bar">
      <span className="status-bar-path">{pathLabel}</span>
      <span className="status-bar-meta">
        Markdown · {words} {wordLabel} · {chars} {charLabel}
      </span>
      <span className="status-bar-meta">
        Ln {cursor.line}, Col {cursor.column}
      </span>
      <span className="status-bar-save">{saveLabel}</span>
    </footer>
  );
}
