import { describe, expect, it } from 'vitest';
import {
  renderMarkdownPreviewBody,
  renderMarkdownPreviewDocument,
} from '@labword/domain/shared/services/markdown-renderer.service';
import { asDocumentContent } from '@labword/domain/domain/document/document.types';

describe('renderMarkdownPreviewBody', () => {
  it('renders headings and task lists', () => {
    const content = asDocumentContent('# Title\n\n- [ ] Task\n- [x] Done');
    const html = renderMarkdownPreviewBody(content);
    expect(html).toContain('<h1>Title</h1>');
    expect(html).toContain('type="checkbox"');
    expect(html).toContain('checked');
  });

  it('renders blockquotes and dividers', () => {
    const content = asDocumentContent('> Quote\n\n---\n\nParagraph');
    const html = renderMarkdownPreviewBody(content);
    expect(html).toContain('<blockquote>');
    expect(html).toContain('<hr>');
    expect(html).toContain('<p>Paragraph</p>');
  });
});

describe('renderMarkdownPreviewDocument', () => {
  it('wraps body in a full html document', () => {
    const content = asDocumentContent('# Hello');
    const html = renderMarkdownPreviewDocument(content, 'Hello');
    expect(html).toContain('<!DOCTYPE html>');
    expect(html).toContain('<title>Hello</title>');
    expect(html).toContain('<h1>Hello</h1>');
  });
});
