import type { ReactNode } from 'react';
import { OverlayCloseButton } from '@labword/app/features/overlays/overlay-controls';

export interface EditorOverlayContainerProps {
  readonly title: string;
  readonly onDismiss: () => void;
  readonly fixedSize?: boolean;
  readonly children: ReactNode;
}

export function EditorOverlayContainer(props: EditorOverlayContainerProps): React.JSX.Element {
  const { title, onDismiss, fixedSize = false, children } = props;

  return (
    <div className="editor-overlay-backdrop" onClick={onDismiss}>
      <div
        className={fixedSize ? 'editor-overlay-panel is-fixed-size' : 'editor-overlay-panel'}
        onClick={(event) => {
          event.stopPropagation();
        }}
        role="dialog"
        aria-modal="true"
        aria-label={title}
      >
        <header className="editor-overlay-header">
          <h2 className="editor-overlay-title">{title}</h2>
          <OverlayCloseButton onClick={onDismiss} />
        </header>
        {children}
      </div>
    </div>
  );
}
