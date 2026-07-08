import type {
  DocumentSnapshot,
  OpenFileDialogRequest,
  OpenFileDialogResult,
  PrintDocumentRequest,
  RenameDocumentRequest,
  RenameDocumentResult,
  SaveDocumentRequest,
  SaveDocumentResult,
  SaveFileDialogRequest,
  SaveFileDialogResult,
  ToggleFullscreenResult,
} from '@labword/domain/domain/document/document.types';
import type { FilePath } from '@labword/domain/domain/document/document.types';

export interface IpcContract {
  readonly 'document:read': {
    readonly args: { readonly path: FilePath };
    readonly result: DocumentSnapshot;
  };
  readonly 'document:save': {
    readonly args: SaveDocumentRequest;
    readonly result: SaveDocumentResult;
  };
  readonly 'dialog:open-file': {
    readonly args: OpenFileDialogRequest;
    readonly result: OpenFileDialogResult;
  };
  readonly 'dialog:save-file': {
    readonly args: SaveFileDialogRequest;
    readonly result: SaveFileDialogResult;
  };
  readonly 'document:rename': {
    readonly args: RenameDocumentRequest;
    readonly result: RenameDocumentResult;
  };
  readonly 'window:print-html': {
    readonly args: PrintDocumentRequest;
    readonly result: undefined;
  };
  readonly 'window:toggle-fullscreen': {
    readonly args: Record<string, never>;
    readonly result: ToggleFullscreenResult;
  };
  readonly 'window:allow-close': {
    readonly args: Record<string, never>;
    readonly result: undefined;
  };
}

export type IpcChannel = keyof IpcContract;

export type IpcArgs<TChannel extends IpcChannel> = IpcContract[TChannel]['args'];

export type IpcResult<TChannel extends IpcChannel> = IpcContract[TChannel]['result'];

export type IpcInvoke = <TChannel extends IpcChannel>(
  channel: TChannel,
  args: IpcArgs<TChannel>,
) => Promise<IpcResult<TChannel>>;
