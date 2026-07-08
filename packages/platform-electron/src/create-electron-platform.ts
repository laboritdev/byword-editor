import type { DocumentSnapshot } from '@labword/domain/domain/document/document.types';
import { displayTitleFromSnapshot } from '@labword/domain/domain/document/document.types';
import { SUPPORTED_EXTENSIONS } from '@labword/domain/shared/constants/app.constants';
import { renderMarkdownPreviewDocument } from '@labword/domain/shared/services/markdown-renderer.service';
import type { PlatformPort } from '@labword/platform';
import type { IpcChannel, IpcArgs, IpcResult } from '@labword/platform-electron/ipc/ipc-channels';
import type { LabwordApi, MenuAction } from '@labword/platform-electron/ipc/labword-api.types';

function getLabwordApi(): LabwordApi {
  const api = window.labword;
  if (api === undefined) {
    throw new Error('LabWord preload bridge is unavailable. Restart the app.');
  }
  return api;
}

async function invoke<TChannel extends IpcChannel>(
  channel: TChannel,
  args: IpcArgs<TChannel>,
): Promise<IpcResult<TChannel>> {
  return getLabwordApi().invoke(channel, args);
}

export function createElectronPlatform(): PlatformPort {
  return {
    kind: 'electron',
    supportsNativeMenu: true,

    async openDocument(): Promise<DocumentSnapshot | null> {
      const dialogResult = await invoke('dialog:open-file', {
        extensions: SUPPORTED_EXTENSIONS,
      });
      if (dialogResult.filePath === null) {
        return null;
      }
      const snapshot = await invoke('document:read', { path: dialogResult.filePath });
      return {
        ...snapshot,
        title: displayTitleFromSnapshot(snapshot),
      };
    },

    async saveDocument(snapshot: DocumentSnapshot): Promise<DocumentSnapshot> {
      if (snapshot.filePath === null) {
        return this.saveDocumentAs(snapshot).then((saved) => saved ?? snapshot);
      }
      await invoke('document:save', {
        filePath: snapshot.filePath,
        content: snapshot.content,
      });
      return { ...snapshot, isDirty: false };
    },

    async saveDocumentAs(snapshot: DocumentSnapshot): Promise<DocumentSnapshot | null> {
      const defaultName = snapshot.filePath !== null ? snapshot.title : `${snapshot.title}.md`;
      const dialogResult = await invoke('dialog:save-file', {
        defaultName,
        extensions: SUPPORTED_EXTENSIONS,
      });
      if (dialogResult.filePath === null) {
        return null;
      }
      await invoke('document:save', {
        filePath: dialogResult.filePath,
        content: snapshot.content,
      });
      const saved: DocumentSnapshot = {
        ...snapshot,
        filePath: dialogResult.filePath,
        isDirty: false,
      };
      return {
        ...saved,
        title: displayTitleFromSnapshot(saved),
      };
    },

    async renameDocument(snapshot: DocumentSnapshot, newName: string): Promise<DocumentSnapshot | null> {
      if (snapshot.filePath === null) {
        return null;
      }
      const trimmed = newName.trim();
      if (trimmed.length === 0) {
        return null;
      }
      const result = await invoke('document:rename', {
        filePath: snapshot.filePath,
        newName: trimmed,
      });
      const renamed: DocumentSnapshot = {
        ...snapshot,
        filePath: result.filePath,
      };
      return {
        ...renamed,
        title: displayTitleFromSnapshot(renamed),
      };
    },

    async printDocument(snapshot: DocumentSnapshot): Promise<void> {
      const html = renderMarkdownPreviewDocument(snapshot.content, snapshot.title);
      await invoke('window:print-html', { html });
    },

    async toggleFullscreen(): Promise<void> {
      await invoke('window:toggle-fullscreen', {});
    },

    async allowWindowClose(): Promise<void> {
      await invoke('window:allow-close', {});
    },

    onMenuAction(handler: (action: MenuAction) => void): () => void {
      return getLabwordApi().onMenuAction(handler);
    },

    onCloseRequested(handler: () => void): () => void {
      return getLabwordApi().onCloseRequested(handler);
    },
  };
}

declare global {
  interface Window {
    readonly labword?: LabwordApi;
  }
}
