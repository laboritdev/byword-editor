import { app, BrowserWindow, Menu, type MenuItemConstructorOptions } from 'electron';

function focusedWindow(): BrowserWindow | null {
  return BrowserWindow.getFocusedWindow();
}

function sendAction(action: string): void {
  focusedWindow()?.webContents.send('app:menu-action', action);
}

export function installApplicationMenu(): void {
  const isMac = process.platform === 'darwin';

  const template: MenuItemConstructorOptions[] = [
    ...(isMac
      ? [
          {
            label: app.name,
            submenu: [
              { role: 'about' as const },
              { type: 'separator' as const },
              { role: 'services' as const },
              { type: 'separator' as const },
              {
                label: `Hide ${app.name}`,
                click: (): void => {
                  app.hide();
                },
              },
              { role: 'hideOthers' as const },
              { role: 'unhide' as const },
              { type: 'separator' as const },
              { role: 'quit' as const },
            ],
          },
        ]
      : []),
    {
      label: 'File',
      submenu: [
        {
          label: 'New Document',
          accelerator: 'CmdOrCtrl+N',
          click: (): void => {
            sendAction('new');
          },
        },
        {
          label: 'Open…',
          accelerator: 'CmdOrCtrl+O',
          click: (): void => {
            sendAction('open');
          },
        },
        { type: 'separator' },
        {
          label: 'Save',
          accelerator: 'CmdOrCtrl+S',
          click: (): void => {
            sendAction('save');
          },
        },
        {
          label: 'Save As…',
          accelerator: 'CmdOrCtrl+Shift+S',
          click: (): void => {
            sendAction('save-as');
          },
        },
        {
          label: 'Rename…',
          accelerator: 'CmdOrCtrl+Shift+R',
          click: (): void => {
            sendAction('rename');
          },
        },
        { type: 'separator' },
        {
          label: 'Print…',
          accelerator: 'CmdOrCtrl+P',
          click: (): void => {
            sendAction('print');
          },
        },
        ...(isMac ? [{ role: 'close' as const }] : [{ role: 'quit' as const }]),
      ],
    },
    {
      label: 'View',
      submenu: [
        {
          label: 'Toggle Preview',
          accelerator: 'Alt+CmdOrCtrl+P',
          click: (): void => {
            sendAction('toggle-preview');
          },
        },
        {
          label: 'Focus Mode',
          accelerator: 'Ctrl+CmdOrCtrl+F',
          click: (): void => {
            sendAction('toggle-focus-mode');
          },
        },
        { type: 'separator' },
        {
          label: 'Increase Font Size',
          accelerator: 'CmdOrCtrl+Shift+>',
          click: (): void => {
            sendAction('increase-font-size');
          },
        },
        {
          label: 'Decrease Font Size',
          accelerator: 'CmdOrCtrl+Shift+<',
          click: (): void => {
            sendAction('decrease-font-size');
          },
        },
        { type: 'separator' },
        {
          label: 'Preferences…',
          accelerator: 'CmdOrCtrl+,',
          click: (): void => {
            sendAction('open-preferences');
          },
        },
        { type: 'separator' },
        {
          label: 'LabWord Agent',
          accelerator: 'CmdOrCtrl+/',
          click: (): void => {
            sendAction('toggle-agent');
          },
        },
        { type: 'separator' },
        { role: 'toggleDevTools' },
        { role: 'reload' },
      ],
    },
    {
      label: 'Edit',
      submenu: [
        { role: 'undo' },
        { role: 'redo' },
        { type: 'separator' },
        { role: 'cut' },
        { role: 'copy' },
        { role: 'paste' },
        { role: 'selectAll' },
        { type: 'separator' },
        {
          label: 'Formatting Palette…',
          accelerator: 'CmdOrCtrl+K',
          click: (): void => {
            sendAction('open-formatting-palette');
          },
        },
      ],
    },
    {
      label: 'Help',
      submenu: [
        {
          label: 'LabWord Help',
          accelerator: 'CmdOrCtrl+H',
          click: (): void => {
            sendAction('open-help');
          },
        },
      ],
    },
  ];

  Menu.setApplicationMenu(Menu.buildFromTemplate(template));
}
