import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { LabwordApp } from '@labword/app';
import { createElectronPlatform } from '@labword/platform-electron';
import '@labword/app/styles/app.css';

const rootElement = document.getElementById('root');
if (rootElement === null) {
  throw new Error('Root element #root not found');
}

const platform = createElectronPlatform();

createRoot(rootElement).render(
  <StrictMode>
    <LabwordApp platform={platform} />
  </StrictMode>,
);
