export interface MarkdownSnippet {
  readonly id: string;
  readonly category: string;
  readonly title: string;
  readonly syntax: string;
  readonly insert: string;
  readonly selectionStart: number;
  readonly selectionEnd: number;
  readonly keywords: readonly string[];
}

export const MARKDOWN_SNIPPETS: readonly MarkdownSnippet[] = [
  {
    id: 'task',
    category: 'Lists',
    title: 'Checklist item',
    syntax: '- [ ] Task',
    insert: '- [ ] ',
    selectionStart: 6,
    selectionEnd: 6,
    keywords: ['task', 'todo', 'check', 'checklist', 'checkbox', 'lista', 'tarefa'],
  },
  {
    id: 'task-done',
    category: 'Lists',
    title: 'Completed checklist item',
    syntax: '- [x] Task',
    insert: '- [x] ',
    selectionStart: 6,
    selectionEnd: 6,
    keywords: ['done', 'checked', 'complete', 'concluido', 'concluído'],
  },
  {
    id: 'bullet',
    category: 'Lists',
    title: 'Bullet list',
    syntax: '- Item',
    insert: '- ',
    selectionStart: 2,
    selectionEnd: 2,
    keywords: ['bullet', 'list', 'item', 'lista', 'marcador'],
  },
  {
    id: 'numbered',
    category: 'Lists',
    title: 'Numbered list',
    syntax: '1. Item',
    insert: '1. ',
    selectionStart: 3,
    selectionEnd: 3,
    keywords: ['numbered', 'ordered', 'list', 'numerada', 'numero'],
  },
  {
    id: 'heading-1',
    category: 'Structure',
    title: 'Heading 1',
    syntax: '# Title',
    insert: '# ',
    selectionStart: 2,
    selectionEnd: 2,
    keywords: ['heading', 'h1', 'title', 'titulo', 'título'],
  },
  {
    id: 'heading-2',
    category: 'Structure',
    title: 'Heading 2',
    syntax: '## Title',
    insert: '## ',
    selectionStart: 3,
    selectionEnd: 3,
    keywords: ['heading', 'h2', 'subtitle', 'subtitulo'],
  },
  {
    id: 'heading-3',
    category: 'Structure',
    title: 'Heading 3',
    syntax: '### Title',
    insert: '### ',
    selectionStart: 4,
    selectionEnd: 4,
    keywords: ['heading', 'h3'],
  },
  {
    id: 'quote',
    category: 'Structure',
    title: 'Blockquote',
    syntax: '> Quote',
    insert: '> ',
    selectionStart: 2,
    selectionEnd: 2,
    keywords: ['quote', 'blockquote', 'citação', 'citacao'],
  },
  {
    id: 'divider',
    category: 'Structure',
    title: 'Divider',
    syntax: '---',
    insert: '---\n',
    selectionStart: 4,
    selectionEnd: 4,
    keywords: ['divider', 'hr', 'line', 'separador', 'linha'],
  },
  {
    id: 'bold',
    category: 'Emphasis',
    title: 'Bold',
    syntax: '**bold**',
    insert: '**bold**',
    selectionStart: 2,
    selectionEnd: 6,
    keywords: ['bold', 'strong', 'negrito'],
  },
  {
    id: 'italic',
    category: 'Emphasis',
    title: 'Italic',
    syntax: '*italic*',
    insert: '*italic*',
    selectionStart: 1,
    selectionEnd: 7,
    keywords: ['italic', 'emphasis', 'italico', 'itálico'],
  },
  {
    id: 'code',
    category: 'Emphasis',
    title: 'Inline code',
    syntax: '`code`',
    insert: '`code`',
    selectionStart: 1,
    selectionEnd: 5,
    keywords: ['code', 'inline', 'mono', 'codigo', 'código'],
  },
  {
    id: 'link',
    category: 'Links',
    title: 'Link',
    syntax: '[label](https://url)',
    insert: '[label](https://url)',
    selectionStart: 1,
    selectionEnd: 6,
    keywords: ['link', 'url', 'href', 'ligacao', 'ligação'],
  },
  {
    id: 'autolink',
    category: 'Links',
    title: 'Auto link',
    syntax: '<https://url>',
    insert: '<https://url>',
    selectionStart: 1,
    selectionEnd: 12,
    keywords: ['autolink', 'url', 'bare'],
  },
] as const;

export function findMarkdownSnippet(id: string): MarkdownSnippet | undefined {
  return MARKDOWN_SNIPPETS.find((snippet) => snippet.id === id);
}
