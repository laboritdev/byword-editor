import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { LabwordApp } from '@labword/app';
import { createWebPlatform } from '@labword/platform-web';
import '@labword/app/styles/app.css';

const rootElement = document.getElementById('root');
if (rootElement === null) {
  throw new Error('Root element #root not found');
}

const platform = createWebPlatform();

createRoot(rootElement).render(
  <StrictMode>
    <LabwordApp platform={platform} />
  </StrictMode>,
);
