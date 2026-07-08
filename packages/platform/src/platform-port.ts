import type { DocumentSnapshot } from '@labword/domain/domain/document/document.types';

export type MenuAction =
  | 'new'
  | 'open'
  | 'save'
  | 'save-as'
  | 'rename'
  | 'print'
  | 'toggle-preview'
  | 'toggle-focus-mode'
  | 'increase-font-size'
  | 'decrease-font-size'
  | 'open-formatting-palette'
  | 'toggle-agent'
  | 'open-help'
  | 'open-preferences';

export type PlatformKind = 'electron' | 'web';

export interface PlatformPort {
  readonly kind: PlatformKind;
  readonly supportsNativeMenu: boolean;
  openDocument(): Promise<DocumentSnapshot | null>;
  saveDocument(snapshot: DocumentSnapshot): Promise<DocumentSnapshot>;
  saveDocumentAs(snapshot: DocumentSnapshot): Promise<DocumentSnapshot | null>;
  renameDocument(snapshot: DocumentSnapshot, newName: string): Promise<DocumentSnapshot | null>;
  printDocument(snapshot: DocumentSnapshot): Promise<void>;
  toggleFullscreen(): Promise<void>;
  allowWindowClose(): Promise<void>;
  onMenuAction(handler: (action: MenuAction) => void): () => void;
  onCloseRequested(handler: () => void): () => void;
}
