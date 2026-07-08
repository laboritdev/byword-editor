import type { DocumentContent } from '@labword/domain/domain/document/document.types';
import { asDocumentContent } from '@labword/domain/domain/document/document.types';

export const INTRO_DEMO_CONTENT = `# Hello

Welcome to **LabWord** — **bold**, *italic*, \`code\` and [links](https://laborit.com.br).

- [ ] something to do
- [x] something done

> Write without noise.

⌘, preferences · delete anytime
` as const;

export function initialIntroContent(showIntroDemo: boolean): DocumentContent {
  if (!showIntroDemo) {
    return asDocumentContent('');
  }
  return asDocumentContent(INTRO_DEMO_CONTENT);
}
