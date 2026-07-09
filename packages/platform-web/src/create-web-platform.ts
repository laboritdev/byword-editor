import type { DocumentSnapshot } from '@labword/domain/domain/document/document.types';
import {
  asDocumentContent,
  asFilePath,
  createDocumentId,
  displayTitleFromSnapshot,
} from '@labword/domain/domain/document/document.types';
import { renderMarkdownPreviewDocument } from '@labword/domain/shared/services/markdown-renderer.service';
import type { PlatformPort } from '@labword/platform';

const MARKDOWN_TYPES: readonly string[] = ['.md', '.markdown', '.txt'];

type FilePickerAcceptType = {
  description: string;
  accept: Record<string, string[]>;
};

type OpenFilePickerOptions = {
  multiple?: boolean;
  types?: FilePickerAcceptType[];
};

type SaveFilePickerOptions = {
  suggestedName?: string;
  types?: FilePickerAcceptType[];
};

let currentFileHandle: FileSystemFileHandle | null = null;

function hasOpenFilePicker(windowObject: Window): windowObject is Window & {
  showOpenFilePicker: (options: OpenFilePickerOptions) => Promise<FileSystemFileHandle[]>;
} {
  return 'showOpenFilePicker' in windowObject;
}

function hasSaveFilePicker(windowObject: Window): windowObject is Window & {
  showSaveFilePicker: (options: SaveFilePickerOptions) => Promise<FileSystemFileHandle>;
} {
  return 'showSaveFilePicker' in windowObject;
}

function extensionAllowed(name: string): boolean {
  const lower = name.toLowerCase();
  return MARKDOWN_TYPES.some((extension) => lower.endsWith(extension));
}

async function readFileFromInput(): Promise<DocumentSnapshot | null> {
  return new Promise((resolve) => {
    const input = window.document.createElement('input');
    input.type = 'file';
    input.accept = MARKDOWN_TYPES.join(',');
    input.onchange = (): void => {
      const file = input.files?.[0];
      if (file === undefined) {
        resolve(null);
        return;
      }
      void file.text().then((text) => {
        currentFileHandle = null;
        const snapshot: DocumentSnapshot = {
          id: createDocumentId(),
          filePath: asFilePath(file.name),
          content: asDocumentContent(text),
          isDirty: false,
          title: file.name,
        };
        resolve({
          ...snapshot,
          title: displayTitleFromSnapshot(snapshot),
        });
      });
    };
    input.click();
  });
}

async function openWithFilePicker(): Promise<DocumentSnapshot | null> {
  if (!hasOpenFilePicker(window)) {
    return readFileFromInput();
  }
  try {
    const handles = await window.showOpenFilePicker({
      multiple: false,
      types: [
        {
          description: 'Markdown',
          accept: {
            'text/markdown': ['.md', '.markdown'],
            'text/plain': ['.txt'],
          },
        },
      ],
    });
    const handle = handles[0];
    if (handle === undefined) {
      return null;
    }
    const file = await handle.getFile();
    if (!extensionAllowed(file.name)) {
      return null;
    }
    currentFileHandle = handle;
    const snapshot: DocumentSnapshot = {
      id: createDocumentId(),
      filePath: asFilePath(file.name),
      content: asDocumentContent(await file.text()),
      isDirty: false,
      title: file.name,
    };
    return {
      ...snapshot,
      title: displayTitleFromSnapshot(snapshot),
    };
  } catch {
    return null;
  }
}

function saveWithDownload(snapshot: DocumentSnapshot, fileName: string): Promise<DocumentSnapshot> {
  const blob = new Blob([snapshot.content], { type: 'text/markdown;charset=utf-8' });
  const url = URL.createObjectURL(blob);
  const anchor = window.document.createElement('a');
  anchor.href = url;
  anchor.download = fileName;
  anchor.click();
  URL.revokeObjectURL(url);
  return Promise.resolve({
    ...snapshot,
    filePath: asFilePath(fileName),
    isDirty: false,
    title: displayTitleFromSnapshot({
      ...snapshot,
      filePath: asFilePath(fileName),
      isDirty: false,
    }),
  });
}

async function saveWithFilePicker(snapshot: DocumentSnapshot): Promise<DocumentSnapshot | null> {
  if (hasSaveFilePicker(window)) {
    try {
      const handle =
        currentFileHandle ??
        (await window.showSaveFilePicker({
          suggestedName: `${snapshot.title}.md`,
          types: [
            {
              description: 'Markdown',
              accept: { 'text/markdown': ['.md'] },
            },
          ],
        }));
      const writable = await handle.createWritable();
      await writable.write(snapshot.content);
      await writable.close();
      currentFileHandle = handle;
      const file = await handle.getFile();
      const saved: DocumentSnapshot = {
        ...snapshot,
        filePath: asFilePath(file.name),
        isDirty: false,
      };
      return {
        ...saved,
        title: displayTitleFromSnapshot(saved),
      };
    } catch {
      return null;
    }
  }
  return saveWithDownload(snapshot, `${snapshot.title}.md`);
}

export function createWebPlatform(): PlatformPort {
  return {
    kind: 'web',
    supportsNativeMenu: false,

    openDocument: openWithFilePicker,

    async saveDocument(snapshot: DocumentSnapshot): Promise<DocumentSnapshot> {
      if (currentFileHandle !== null) {
        const writable = await currentFileHandle.createWritable();
        await writable.write(snapshot.content);
        await writable.close();
        return { ...snapshot, isDirty: false };
      }
      const saved = await this.saveDocumentAs(snapshot);
      return saved ?? snapshot;
    },

    saveDocumentAs: saveWithFilePicker,

    renameDocument(snapshot: DocumentSnapshot, newName: string): Promise<DocumentSnapshot | null> {
      const trimmed = newName.trim();
      if (trimmed.length === 0) {
        return Promise.resolve(null);
      }
      currentFileHandle = null;
      const renamed: DocumentSnapshot = {
        ...snapshot,
        filePath: asFilePath(trimmed),
      };
      return Promise.resolve({
        ...renamed,
        title: displayTitleFromSnapshot(renamed),
      });
    },

    printDocument(snapshot: DocumentSnapshot): Promise<void> {
      const html = renderMarkdownPreviewDocument(snapshot.content, snapshot.title);
      const printWindow = window.open('', '_blank');
      if (printWindow === null) {
        return Promise.resolve();
      }
      const blob = new Blob([html], { type: 'text/html;charset=utf-8' });
      const blobUrl = URL.createObjectURL(blob);
      printWindow.location.href = blobUrl;
      printWindow.onload = (): void => {
        printWindow.focus();
        printWindow.print();
        URL.revokeObjectURL(blobUrl);
      };
      return Promise.resolve();
    },

    async toggleFullscreen(): Promise<void> {
      if (window.document.fullscreenElement === null) {
        await window.document.documentElement.requestFullscreen();
        return;
      }
      await window.document.exitFullscreen();
    },

    async allowWindowClose(): Promise<void> {
      // Browser tabs close without an explicit allow step.
    },

    onMenuAction(): () => void {
      return (): void => undefined;
    },

    onCloseRequested(handler: () => void): () => void {
      const listener = (event: BeforeUnloadEvent): void => {
        event.preventDefault();
        handler();
      };
      window.addEventListener('beforeunload', listener);
      return (): void => {
        window.removeEventListener('beforeunload', listener);
      };
    },
  };
}
