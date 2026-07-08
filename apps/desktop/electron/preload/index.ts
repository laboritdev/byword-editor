import { contextBridge, ipcRenderer, type IpcRendererEvent } from 'electron';
import type { IpcChannel, IpcArgs, IpcResult, IpcInvoke } from '@labword/platform-electron/ipc/ipc-channels';
import type { LabwordApi, MenuAction } from '@labword/platform-electron/ipc/labword-api.types';

const invoke: IpcInvoke = <TChannel extends IpcChannel>(
  channel: TChannel,
  args: IpcArgs<TChannel>,
): Promise<IpcResult<TChannel>> => {
  return ipcRenderer.invoke(channel, args) as Promise<IpcResult<TChannel>>;
};

const onMenuAction: LabwordApi['onMenuAction'] = (handler) => {
  const listener = (_event: IpcRendererEvent, action: MenuAction): void => {
    handler(action);
  };
  ipcRenderer.on('app:menu-action', listener);
  return () => {
    ipcRenderer.removeListener('app:menu-action', listener);
  };
};

const onCloseRequested: LabwordApi['onCloseRequested'] = (handler) => {
  const listener = (): void => {
    handler();
  };
  ipcRenderer.on('app:close-requested', listener);
  return () => {
    ipcRenderer.removeListener('app:close-requested', listener);
  };
};

const labwordApi: LabwordApi = { invoke, onMenuAction, onCloseRequested };

contextBridge.exposeInMainWorld('labword', labwordApi);
