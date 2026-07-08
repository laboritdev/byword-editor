import type { AgentCommandDefinition, TerminalHelpDocument } from '@labword/domain/domain/agent/agent.types';
import { HELP_TERMINAL_RULE } from '@labword/domain/shared/help/help-reference';

export const HELP_ROOT_ALIASES = ['?'] as const;

export const HELP_TOPIC_ALIASES: Readonly<Record<string, string>> = {
  hs: 'shortcuts',
  hc: 'commands',
  hm: 'markdown',
};

export const HELP_TOPIC_COMMANDS = ['hs', 'hc', 'hm'] as const;

export const AGENT_COMMANDS: readonly AgentCommandDefinition[] = [
  {
    name: 'help',
    aliases: ['?'],
    usage: 'help [shortcuts|markdown|commands]',
    summary: 'Show help topics (?, hs, hc, hm)',
  },
  { name: 'save', aliases: [], usage: 'save', summary: 'Save the current document' },
  { name: 'stats', aliases: ['wordcount'], usage: 'stats', summary: 'Show document statistics' },
  { name: 'clear', aliases: [], usage: 'clear', summary: 'Clear terminal scrollback' },
  { name: 'preview', aliases: [], usage: 'preview', summary: 'Toggle preview mode' },
  { name: 'find', aliases: [], usage: 'find <text>', summary: 'Open find with query' },
  { name: 'checklist', aliases: [], usage: 'checklist', summary: 'Insert checklist item' },
  { name: 'settings', aliases: ['prefs'], usage: 'settings', summary: 'Open preferences' },
  { name: 'ai', aliases: ['/ai'], usage: 'ai <prompt>', summary: 'Ask AI provider when enabled' },
] as const;

export function resolveHelpTopic(topic: string): string {
  return HELP_TOPIC_ALIASES[topic.toLowerCase()] ?? topic.toLowerCase();
}

export function resolveAgentCommandRoot(
  token: string,
): { readonly root: string; readonly arguments: readonly string[] } | null {
  const lower = token.toLowerCase();
  if (lower === '?') {
    return { root: 'help', arguments: [] };
  }
  const topic = HELP_TOPIC_ALIASES[lower];
  if (topic !== undefined) {
    return { root: 'help', arguments: [topic] };
  }
  return null;
}

export function listCommandNames(): readonly string[] {
  return [
    ...AGENT_COMMANDS.flatMap((command) => [command.name, ...command.aliases]),
    ...HELP_TOPIC_COMMANDS,
  ];
}

export function autocompleteCommand(input: string): string | null {
  const trimmed = input.trim();
  if (trimmed.length === 0) {
    return null;
  }
  const parts = trimmed.split(/\s+/);
  if (parts.length !== 1) {
    return null;
  }
  const prefix = parts[0]?.toLowerCase() ?? '';
  const match = listCommandNames().find(
    (name) => name.toLowerCase().startsWith(prefix) && name.toLowerCase() !== prefix,
  );
  return match ?? null;
}

export function helpCategoriesDocument(): TerminalHelpDocument {
  return {
    title: 'Help topics',
    sections: [
      {
        title: 'Topics',
        rows: [
          { label: 'help', value: '?' },
          { label: 'help shortcuts', value: 'hs' },
          { label: 'help markdown', value: 'hm' },
          { label: 'help commands', value: 'hc' },
        ],
      },
    ],
  };
}

export function helpCommandsDocument(): TerminalHelpDocument {
  return {
    title: 'Agent commands',
    sections: [
      {
        title: 'Commands',
        rows: AGENT_COMMANDS.map((command) => ({
          label: command.usage,
          value: command.summary,
        })),
      },
    ],
  };
}

export { HELP_TERMINAL_RULE };
