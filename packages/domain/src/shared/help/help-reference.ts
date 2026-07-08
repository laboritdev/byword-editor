import type { TerminalHelpDocument } from '@labword/domain/domain/agent/agent.types';

export interface HelpShortcut {
  readonly action: string;
  readonly shortcut: string;
}

export interface HelpSection {
  readonly title: string;
  readonly shortcuts: readonly HelpShortcut[];
}

export interface FormattingHint {
  readonly title: string;
  readonly syntax: string;
  readonly description: string;
}

export interface FormattingSection {
  readonly title: string;
  readonly hints: readonly FormattingHint[];
}

export const HELP_SECTIONS: readonly HelpSection[] = [
  {
    title: 'File',
    shortcuts: [
      { action: 'New Document', shortcut: '⌘N' },
      { action: 'Open', shortcut: '⌘O' },
      { action: 'Save', shortcut: '⌘S' },
      { action: 'Save As', shortcut: '⇧⌘S' },
      { action: 'Rename', shortcut: '⇧⌘R' },
      { action: 'Print', shortcut: '⌘P' },
    ],
  },
  {
    title: 'Edit',
    shortcuts: [
      { action: 'Undo', shortcut: '⌘Z' },
      { action: 'Redo', shortcut: '⇧⌘Z' },
      { action: 'Find', shortcut: '⌘F' },
      { action: 'Find Next', shortcut: '⌘G' },
      { action: 'Find Previous', shortcut: '⇧⌘G' },
      { action: 'Formatting Palette', shortcut: '⌘K' },
      { action: 'Insert Checklist Item', shortcut: '⇧⌘L' },
    ],
  },
  {
    title: 'View',
    shortcuts: [
      { action: 'Toggle Preview', shortcut: '⌥⌘P' },
      { action: 'Focus Mode', shortcut: '⌃⌘F' },
      { action: 'Increase Font Size', shortcut: '⇧⌘>' },
      { action: 'Decrease Font Size', shortcut: '⇧⌘<' },
      { action: 'Preferences', shortcut: '⌘,' },
      { action: 'Formatting Hints', shortcut: '⇧⌘/' },
      { action: 'LabWord Agent', shortcut: '⌘/' },
      { action: 'Close Panel / Exit Focus Mode', shortcut: 'Esc' },
    ],
  },
] as const;

export const FORMATTING_SECTIONS: readonly FormattingSection[] = [
  {
    title: 'Structure',
    hints: [
      { title: 'Heading', syntax: '# Title', description: 'Use 1–6 # symbols for heading levels.' },
      { title: 'Quote', syntax: '> Quote', description: 'Prefix a line with > for blockquotes.' },
      { title: 'Divider', syntax: '---', description: 'Three or more dashes on their own line.' },
    ],
  },
  {
    title: 'Emphasis',
    hints: [
      { title: 'Bold', syntax: '**bold**', description: 'Wrap text with double asterisks.' },
      { title: 'Italic', syntax: '*italic*', description: 'Wrap text with single asterisks.' },
      { title: 'Code', syntax: '`code`', description: 'Wrap inline code with backticks.' },
    ],
  },
  {
    title: 'Lists',
    hints: [
      { title: 'Bullet', syntax: '- Item', description: 'Start a line with -, *, or +.' },
      { title: 'Numbered', syntax: '1. Item', description: 'Start a line with a number and period.' },
      {
        title: 'Checklist',
        syntax: '- [ ] Task',
        description: 'Click the checkbox in the editor to toggle done. Use - [x] for completed items.',
      },
    ],
  },
  {
    title: 'Links',
    hints: [
      { title: 'Link', syntax: '[label](https://url)', description: 'Markdown link syntax.' },
      { title: 'Auto link', syntax: '<https://url>', description: 'Angle brackets for bare URLs.' },
    ],
  },
] as const;

export const HELP_TERMINAL_RULE = '─'.repeat(52);

export function helpShortcutsDocument(): TerminalHelpDocument {
  return {
    title: 'Keyboard shortcuts',
    sections: HELP_SECTIONS.map((section) => ({
      title: section.title,
      rows: section.shortcuts.map((shortcut) => ({
        label: shortcut.action,
        value: shortcut.shortcut,
      })),
    })),
  };
}

export function helpMarkdownDocument(): TerminalHelpDocument {
  return {
    title: 'Markdown formatting',
    sections: FORMATTING_SECTIONS.map((section) => ({
      title: section.title,
      rows: section.hints.map((hint) => ({
        label: hint.title,
        value: hint.syntax,
      })),
    })),
  };
}
