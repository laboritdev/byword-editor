import { app, BrowserWindow, nativeImage, shell, type NativeImage } from 'electron';
import { existsSync } from 'node:fs';
import { join } from 'node:path';
import { installApplicationMenu } from './application-menu';
import { registerIpcHandlers } from './ipc/register-ipc-handlers';
import { setupWindowCloseHandler } from './services/window-service';

const BACKGROUND_COLOR = '#161615';
const ICON_RELATIVE_PATH = 'resources/icons/AppIcon-dock.png';
const ICON_FALLBACK_PATH = 'resources/icons/AppIcon.png';

function resolveResourcePath(relativePath: string): string | undefined {
  const bases = [
    join(__dirname, '../..'),
    app.getAppPath(),
    process.cwd(),
  ];

  for (const base of bases) {
    const candidate = join(base, relativePath);
    if (existsSync(candidate)) {
      return candidate;
    }
  }

  return undefined;
}

function loadNativeImage(relativePath: string): NativeImage | undefined {
  const path = resolveResourcePath(relativePath);
  if (path === undefined) {
    return undefined;
  }

  const image = nativeImage.createFromPath(path);
  if (image.isEmpty()) {
    return undefined;
  }

  return image;
}

function loadAppIcon(): NativeImage | undefined {
  return (
    loadNativeImage(ICON_FALLBACK_PATH)
    ?? loadNativeImage('resources/icons/AppIcon.iconset/icon_512x512@2x.png')
  );
}

function loadDockIcon(): NativeImage | undefined {
  return loadNativeImage(ICON_RELATIVE_PATH) ?? loadAppIcon();
}

function applyDockIcon(icon: NativeImage): void {
  if (process.platform !== 'darwin' || app.dock === undefined) {
    return;
  }

  try {
    // Full-bleed 1024×1024 PNG; macOS applies the squircle mask in the Dock.
    app.dock.setIcon(icon);
  } catch (error: unknown) {
    console.warn('Failed to set dock icon:', error);
  }
}

function createMainWindow(): BrowserWindow {
  const icon = loadAppIcon();
  const window = new BrowserWindow({
    width: 960,
    height: 720,
    minWidth: 640,
    minHeight: 480,
    title: 'LabWord',
    backgroundColor: BACKGROUND_COLOR,
    titleBarStyle: 'hiddenInset',
    trafficLightPosition: { x: 16, y: 14 },
    ...(icon !== undefined ? { icon } : {}),
    webPreferences: {
      preload: join(__dirname, '../preload/index.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
    },
  });

  window.webContents.setWindowOpenHandler(({ url }) => {
    void shell.openExternal(url);
    return { action: 'deny' };
  });

  setupWindowCloseHandler(window);

  if (process.env.ELECTRON_RENDERER_URL !== undefined) {
    void window.loadURL(process.env.ELECTRON_RENDERER_URL);
  } else {
    void window.loadFile(join(__dirname, '../renderer/index.html'));
  }

  return window;
}

void app.whenReady().then(() => {
  const dockIcon = loadDockIcon();
  if (dockIcon !== undefined) {
    applyDockIcon(dockIcon);
  }

  installApplicationMenu();
  registerIpcHandlers();
  createMainWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createMainWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
