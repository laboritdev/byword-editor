import type { DocumentSnapshot } from '@labword/domain/domain/document/document.types';
import {
  createDocumentId,
  displayTitleFromSnapshot,
} from '@labword/domain/domain/document/document.types';
import { initialIntroContent } from '@labword/domain/shared/content/intro-demo-content';
import { getPlatform } from '@labword/platform';

export function createEmptyDocument(showIntroDemo = true): DocumentSnapshot {
  const content = initialIntroContent(showIntroDemo);
  const snapshot: DocumentSnapshot = {
    id: createDocumentId(),
    filePath: null,
    content,
    isDirty: false,
    title: 'Untitled',
  };
  return {
    ...snapshot,
    title: displayTitleFromSnapshot(snapshot),
  };
}

export function createInitialDocument(showIntroDemo: boolean): DocumentSnapshot {
  return createEmptyDocument(showIntroDemo);
}

export async function openDocumentFromDialog(): Promise<DocumentSnapshot | null> {
  return getPlatform().openDocument();
}

export async function saveDocumentAsFromDialog(
  snapshot: DocumentSnapshot,
): Promise<DocumentSnapshot | null> {
  return getPlatform().saveDocumentAs(snapshot);
}

export async function saveDocumentSnapshot(snapshot: DocumentSnapshot): Promise<DocumentSnapshot> {
  return getPlatform().saveDocument(snapshot);
}

export async function renameDocument(
  snapshot: DocumentSnapshot,
  newName: string,
): Promise<DocumentSnapshot | null> {
  return getPlatform().renameDocument(snapshot, newName);
}

export async function printDocument(snapshot: DocumentSnapshot): Promise<void> {
  return getPlatform().printDocument(snapshot);
}
