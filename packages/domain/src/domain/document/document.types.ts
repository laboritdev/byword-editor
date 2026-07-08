export type DocumentId = string & { readonly __brand: 'DocumentId' };

export type FilePath = string & { readonly __brand: 'FilePath' };

export type DocumentContent = string & { readonly __brand: 'DocumentContent' };

export interface DocumentSnapshot {
  readonly id: DocumentId;
  readonly filePath: FilePath | null;
  readonly content: DocumentContent;
  readonly isDirty: boolean;
  readonly title: string;
}

export interface SaveDocumentRequest {
  readonly filePath: FilePath;
  readonly content: DocumentContent;
}

export interface SaveDocumentResult {
  readonly savedAt: string;
  readonly filePath: FilePath;
}

export interface OpenFileDialogRequest {
  readonly extensions: readonly string[];
}

export interface OpenFileDialogResult {
  readonly filePath: FilePath | null;
}

export interface SaveFileDialogRequest {
  readonly defaultName: string;
  readonly extensions: readonly string[];
}

export interface SaveFileDialogResult {
  readonly filePath: FilePath | null;
}

export interface RenameDocumentRequest {
  readonly filePath: FilePath;
  readonly newName: string;
}

export interface RenameDocumentResult {
  readonly filePath: FilePath;
}

export interface PrintDocumentRequest {
  readonly html: string;
}

export interface ToggleFullscreenResult {
  readonly isFullScreen: boolean;
}

export function createDocumentId(): DocumentId {
  return crypto.randomUUID() as DocumentId;
}

export function asFilePath(value: string): FilePath {
  return value as FilePath;
}

export function asDocumentContent(value: string): DocumentContent {
  return value as DocumentContent;
}

export function displayTitleFromSnapshot(snapshot: DocumentSnapshot): string {
  if (snapshot.filePath !== null) {
    const segments = snapshot.filePath.split(/[/\\]/);
    const last = segments[segments.length - 1];
    return last ?? 'Untitled';
  }
  const firstLine = snapshot.content.split('\n')[0] ?? '';
  const heading = firstLine.replace(/^#\s*/, '').trim();
  return heading.length > 0 ? heading : 'Untitled';
}

export function windowTitleFromSnapshot(snapshot: DocumentSnapshot): string {
  if (!snapshot.isDirty) {
    return snapshot.title;
  }
  return `${snapshot.title} *`;
}
