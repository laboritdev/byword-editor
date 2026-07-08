import type { DocumentContent } from '@labword/domain/domain/document/document.types';

function escapeHtml(text: string): string {
  return text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
}

function renderInlineMarkdown(text: string): string {
  let html = escapeHtml(text);
  html = html.replace(/`([^`]+)`/g, '<code>$1</code>');
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
  html = html.replace(/__(.+?)__/g, '<strong>$1</strong>');
  html = html.replace(/(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)/g, '<em>$1</em>');
  html = html.replace(
    /\[([^\]]+)\]\(([^)]+)\)/g,
    '<a href="$2" target="_blank" rel="noopener noreferrer">$1</a>',
  );
  return html;
}

const TASK_LINE = /^(\s*[-*+]\s+\[( |x|X)\]\s+)(.*)$/;
const HEADING_LINE = /^(#{1,6})\s+(.+)$/;
const BULLET_LINE = /^(\s*[-*+]\s+)(.+)$/;
const NUMBERED_LINE = /^(\s*\d+\.\s+)(.+)$/;
const BLOCKQUOTE_LINE = /^>\s?(.*)$/;
const DIVIDER_LINE = /^(-{3,}|\*{3,})$/;

export function renderMarkdownPreviewBody(content: DocumentContent): string {
  const lines = content.split('\n');
  const parts: string[] = [];
  let index = 0;

  while (index < lines.length) {
    const line = lines[index] ?? '';

    if (line.trim().length === 0) {
      index += 1;
      continue;
    }

    const headingMatch = HEADING_LINE.exec(line);
    if (headingMatch !== null) {
      const level = Math.min(Math.max((headingMatch[1] ?? '#').length, 1), 6);
      const text = headingMatch[2] ?? '';
      parts.push(`<h${String(level)}>${renderInlineMarkdown(text)}</h${String(level)}>`);
      index += 1;
      continue;
    }

    if (DIVIDER_LINE.test(line)) {
      parts.push('<hr>');
      index += 1;
      continue;
    }

    const blockquoteMatch = BLOCKQUOTE_LINE.exec(line);
    if (blockquoteMatch !== null) {
      const quoteLines: string[] = [];
      while (index < lines.length) {
        const quoteLine = lines[index] ?? '';
        const match = BLOCKQUOTE_LINE.exec(quoteLine);
        if (match === null) {
          break;
        }
        quoteLines.push(renderInlineMarkdown(match[1] ?? ''));
        index += 1;
      }
      parts.push(`<blockquote><p>${quoteLines.join('<br>')}</p></blockquote>`);
      continue;
    }

    const taskItems: string[] = [];
    while (index < lines.length) {
      const taskLine = lines[index] ?? '';
      const match = TASK_LINE.exec(taskLine);
      if (match === null) {
        break;
      }
      const checked = (match[2] ?? ' ').toLowerCase() === 'x';
      const label = renderInlineMarkdown(match[3] ?? '');
      taskItems.push(
        `<li><label><input type="checkbox" disabled${checked ? ' checked' : ''}> ${label}</label></li>`,
      );
      index += 1;
    }
    if (taskItems.length > 0) {
      parts.push(`<ul class="task-list">${taskItems.join('')}</ul>`);
      continue;
    }

    const bulletItems: string[] = [];
    while (index < lines.length) {
      const bulletLine = lines[index] ?? '';
      const match = BULLET_LINE.exec(bulletLine);
      if (match === null || TASK_LINE.test(bulletLine)) {
        break;
      }
      bulletItems.push(`<li>${renderInlineMarkdown(match[2] ?? '')}</li>`);
      index += 1;
    }
    if (bulletItems.length > 0) {
      parts.push(`<ul>${bulletItems.join('')}</ul>`);
      continue;
    }

    const numberedItems: string[] = [];
    while (index < lines.length) {
      const numberedLine = lines[index] ?? '';
      const match = NUMBERED_LINE.exec(numberedLine);
      if (match === null) {
        break;
      }
      numberedItems.push(`<li>${renderInlineMarkdown(match[2] ?? '')}</li>`);
      index += 1;
    }
    if (numberedItems.length > 0) {
      parts.push(`<ol>${numberedItems.join('')}</ol>`);
      continue;
    }

    const paragraphLines: string[] = [];
    while (index < lines.length) {
      const paragraphLine = lines[index] ?? '';
      if (paragraphLine.trim().length === 0) {
        break;
      }
      if (
        HEADING_LINE.test(paragraphLine) ||
        DIVIDER_LINE.test(paragraphLine) ||
        BLOCKQUOTE_LINE.test(paragraphLine) ||
        TASK_LINE.test(paragraphLine) ||
        BULLET_LINE.test(paragraphLine) ||
        NUMBERED_LINE.test(paragraphLine)
      ) {
        break;
      }
      paragraphLines.push(renderInlineMarkdown(paragraphLine));
      index += 1;
    }
    parts.push(`<p>${paragraphLines.join('<br>')}</p>`);
  }

  return parts.join('\n');
}

export function renderMarkdownPreviewDocument(content: DocumentContent, title: string): string {
  const body = renderMarkdownPreviewBody(content);
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>${escapeHtml(title)}</title>
<style>
body { font-family: Menlo, "SF Mono", ui-monospace, monospace; line-height: 1.55; max-width: 580px; margin: 72px auto; padding: 0 72px; color: #ecebe7; background: #161615; }
h1,h2,h3,h4,h5,h6 { color: #faf9f6; font-weight: 600; }
a { color: #85b8f5; }
code { color: #ccc9c7; font-size: 0.95em; }
blockquote { border-left: 3px solid #61615e; margin: 0; padding-left: 1rem; color: #8c8b87; font-style: italic; }
hr { border: none; border-top: 1px solid #383836; margin: 1.5rem 0; }
ul, ol { padding-left: 1.25rem; }
ul.task-list { list-style: none; padding-left: 0; }
ul.task-list li { margin: 0.35rem 0; }
ul.task-list input { margin-right: 0.5rem; }
p { margin: 0 0 1rem; }
</style>
</head>
<body>${body}</body>
</html>`;
}
