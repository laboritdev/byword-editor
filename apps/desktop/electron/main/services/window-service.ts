import { BrowserWindow } from 'electron';

let closeConfirmed = false;

export function setupWindowCloseHandler(window: BrowserWindow): void {
  window.on('close', (event) => {
    if (closeConfirmed) {
      closeConfirmed = false;
      return;
    }
    event.preventDefault();
    window.webContents.send('app:close-requested');
  });
}

export function allowFocusedWindowClose(): void {
  const window = BrowserWindow.getFocusedWindow();
  if (window === null) {
    return;
  }
  closeConfirmed = true;
  window.close();
}

export async function printHtmlDocument(html: string): Promise<void> {
  const printWindow = new BrowserWindow({
    show: false,
    webPreferences: {
      sandbox: true,
      contextIsolation: true,
    },
  });

  const dataUrl = `data:text/html;charset=utf-8,${encodeURIComponent(html)}`;
  await printWindow.loadURL(dataUrl);

  await new Promise<void>((resolve, reject) => {
    printWindow.webContents.print(
      { silent: false, printBackground: true },
      (success, failureReason) => {
        printWindow.destroy();
        if (success) {
          resolve();
          return;
        }
        reject(new Error(failureReason));
      },
    );
  });
}

export function toggleFocusedWindowFullscreen(): boolean {
  const window = BrowserWindow.getFocusedWindow();
  if (window === null) {
    return false;
  }
  const next = !window.isFullScreen();
  window.setFullScreen(next);
  return next;
}
