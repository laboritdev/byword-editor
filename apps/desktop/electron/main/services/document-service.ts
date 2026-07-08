import { rename as renamePath } from 'node:fs/promises';
import { readFile, writeFile } from 'node:fs/promises';
import { basename, dirname, extname, join } from 'node:path';
import { dialog } from 'electron';
import type {
  DocumentSnapshot,
  FilePath,
  OpenFileDialogRequest,
  OpenFileDialogResult,
  RenameDocumentRequest,
  RenameDocumentResult,
  SaveDocumentRequest,
  SaveDocumentResult,
  SaveFileDialogRequest,
  SaveFileDialogResult,
} from '@labword/domain/domain/document/document.types';
import {
  asDocumentContent,
  asFilePath,
  createDocumentId,
  displayTitleFromSnapshot,
} from '@labword/domain/domain/document/document.types';

export async function readDocumentFromPath(path: FilePath): Promise<DocumentSnapshot> {
  const raw = await readFile(path, 'utf8');
  const snapshot: DocumentSnapshot = {
    id: createDocumentId(),
    filePath: path,
    content: asDocumentContent(raw),
    isDirty: false,
    title: basename(path),
  };
  return {
    ...snapshot,
    title: displayTitleFromSnapshot(snapshot),
  };
}

export async function saveDocumentToPath(
  request: SaveDocumentRequest,
): Promise<SaveDocumentResult> {
  await writeFile(request.filePath, request.content, 'utf8');
  return {
    savedAt: new Date().toISOString(),
    filePath: request.filePath,
  };
}

export async function showSaveFileDialog(
  request: SaveFileDialogRequest,
): Promise<SaveFileDialogResult> {
  const result = await dialog.showSaveDialog({
    defaultPath: request.defaultName,
    filters: [{ name: 'Markdown', extensions: [...request.extensions] }],
  });
  if (result.canceled) {
    return { filePath: null };
  }
  return { filePath: asFilePath(result.filePath) };
}

export async function renameDocumentFile(
  request: RenameDocumentRequest,
): Promise<RenameDocumentResult> {
  const directory = dirname(request.filePath);
  const extension = extname(request.filePath);
  const normalizedExtension = extension.length > 0 ? extension : '.md';
  let nextName = request.newName.trim();
  if (!nextName.toLowerCase().endsWith(normalizedExtension.toLowerCase())) {
    nextName = `${nextName}${normalizedExtension}`;
  }
  const destination = asFilePath(join(directory, nextName));
  await renamePath(request.filePath, destination);
  return { filePath: destination };
}

export async function showOpenFileDialog(
  request: OpenFileDialogRequest,
): Promise<OpenFileDialogResult> {
  const result = await dialog.showOpenDialog({
    properties: ['openFile'],
    filters: [{ name: 'Markdown', extensions: [...request.extensions] }],
  });
  if (result.canceled || result.filePaths.length === 0) {
    return { filePath: null };
  }
  const selected = result.filePaths[0];
  if (selected === undefined) {
    return { filePath: null };
  }
  return { filePath: asFilePath(selected) };
}
