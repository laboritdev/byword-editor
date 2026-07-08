import type { IpcInvoke } from './ipc-channels';
import type { MenuAction } from '@labword/platform';

export type { MenuAction };

export interface LabwordApi {
  readonly invoke: IpcInvoke;
  readonly onMenuAction: (handler: (action: MenuAction) => void) => () => void;
  readonly onCloseRequested: (handler: () => void) => () => void;
}

declare global {
  interface Window {
    readonly labword?: LabwordApi;
  }
}

export {};
