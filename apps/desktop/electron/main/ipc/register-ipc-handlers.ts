import { ipcMain } from 'electron';
import type { IpcArgs, IpcChannel, IpcResult } from '@labword/platform-electron/ipc/ipc-channels';
import {
  readDocumentFromPath,
  renameDocumentFile,
  saveDocumentToPath,
  showOpenFileDialog,
  showSaveFileDialog,
} from '../services/document-service';
import { printHtmlDocument, toggleFocusedWindowFullscreen, allowFocusedWindowClose } from '../services/window-service';

function registerHandler<TChannel extends IpcChannel>(
  channel: TChannel,
  handler: (args: IpcArgs<TChannel>) => Promise<IpcResult<TChannel>> | IpcResult<TChannel>,
): void {
  ipcMain.removeHandler(channel);
  ipcMain.handle(channel, (_event, args: IpcArgs<TChannel>) => handler(args));
}

export function registerIpcHandlers(): void {
  registerHandler('document:read', (args) => readDocumentFromPath(args.path));
  registerHandler('document:save', (args) => saveDocumentToPath(args));
  registerHandler('document:rename', (args) => renameDocumentFile(args));
  registerHandler('dialog:open-file', (args) => showOpenFileDialog(args));
  registerHandler('dialog:save-file', (args) => showSaveFileDialog(args));
  registerHandler('window:print-html', async (args) => {
    await printHtmlDocument(args.html);
    return undefined;
  });
  registerHandler('window:toggle-fullscreen', () => {
    const isFullScreen = toggleFocusedWindowFullscreen();
    return { isFullScreen };
  });
  registerHandler('window:allow-close', () => {
    allowFocusedWindowClose();
    return undefined;
  });
}
