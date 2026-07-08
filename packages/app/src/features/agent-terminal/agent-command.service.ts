import type { ParsedAgentCommand, AgentCommandResult } from '@labword/domain/domain/agent/agent.types';
import {
  helpCategoriesDocument,
  helpCommandsDocument,
  resolveAgentCommandRoot,
  resolveHelpTopic,
} from '@labword/domain/domain/agent/command-registry';
import { helpMarkdownDocument, helpShortcutsDocument } from '@labword/domain/shared/help/help-reference';
import type { DocumentContent } from '@labword/domain/domain/document/document.types';

export interface AgentCommandContext {
  readonly content: DocumentContent;
  readonly wordCount: number;
  readonly onSave: () => void;
  readonly onTogglePreview: () => void;
  readonly onOpenSettings: () => void;
}

export function parseAgentCommand(input: string): ParsedAgentCommand | null {
  const trimmed = input.trim();
  if (trimmed.length === 0) {
    return null;
  }
  if (trimmed.startsWith('/ai')) {
    const remainder = trimmed.slice(3).trim();
    return {
      root: 'ai',
      arguments: remainder.length > 0 ? [remainder] : [],
      raw: trimmed,
    };
  }
  const parts = trimmed.split(/\s+/);
  const first = parts[0]?.toLowerCase() ?? '';
  const resolvedRoot = resolveAgentCommandRoot(first);
  if (resolvedRoot !== null) {
    const trailingArguments = parts.slice(1).map((argument) => resolveHelpTopic(argument));
    return {
      root: resolvedRoot.root,
      arguments:
        resolvedRoot.arguments.length > 0
          ? [...resolvedRoot.arguments]
          : trailingArguments,
      raw: trimmed,
    };
  }
  if (first === 'help') {
    return {
      root: 'help',
      arguments: parts.slice(1).map((argument) => resolveHelpTopic(argument)),
      raw: trimmed,
    };
  }
  return {
    root: first,
    arguments: parts.slice(1),
    raw: trimmed,
  };
}

export function countWords(text: DocumentContent): number {
  const matches = text.trim().match(/\S+/g);
  return matches?.length ?? 0;
}

export function executeAgentCommand(
  input: string,
  context: AgentCommandContext,
): AgentCommandResult {
  const parsed = parseAgentCommand(input);
  if (parsed === null) {
    return { blocks: [], clearScrollback: false };
  }

  switch (parsed.root) {
    case 'help': {
      const topic = parsed.arguments[0]?.toLowerCase();
      if (topic === undefined) {
        return {
          blocks: [
            { kind: 'text', text: 'LabWord Agent' },
            { kind: 'text', text: 'Type `help <topic>` or use shortcuts like `hs`, `hc`, `hm`.' },
            { kind: 'help', document: helpCategoriesDocument() },
          ],
          clearScrollback: false,
        };
      }
      const resolvedTopic = resolveHelpTopic(topic);
      if (resolvedTopic === 'commands') {
        return { blocks: [{ kind: 'help', document: helpCommandsDocument() }], clearScrollback: false };
      }
      if (resolvedTopic === 'shortcuts') {
        return { blocks: [{ kind: 'help', document: helpShortcutsDocument() }], clearScrollback: false };
      }
      if (resolvedTopic === 'markdown') {
        return { blocks: [{ kind: 'help', document: helpMarkdownDocument() }], clearScrollback: false };
      }
      return {
        blocks: [
          { kind: 'text', text: `Unknown help topic: ${topic}` },
          { kind: 'text', text: 'Try: shortcuts, markdown, commands (or hs, hc, hm)' },
        ],
        clearScrollback: false,
      };
    }
    case 'stats':
    case 'wordcount':
      return {
        blocks: [
          { kind: 'text', text: 'Document statistics:' },
          { kind: 'text', text: `  Words: ${String(context.wordCount)}` },
          { kind: 'text', text: `  Characters: ${String(context.content.length)}` },
        ],
        clearScrollback: false,
      };
    case 'save':
      context.onSave();
      return { blocks: [{ kind: 'text', text: 'Saved.' }], clearScrollback: false };
    case 'preview':
      context.onTogglePreview();
      return { blocks: [{ kind: 'text', text: 'Toggled preview.' }], clearScrollback: false };
    case 'clear':
      return { blocks: [], clearScrollback: true };
    case 'settings':
    case 'prefs':
      context.onOpenSettings();
      return {
        blocks: [{ kind: 'text', text: 'Opened preferences. Use ⌘, for quick access.' }],
        clearScrollback: false,
      };
    default:
      return {
        blocks: [
          { kind: 'text', text: `Unknown command: ${parsed.root}` },
          { kind: 'text', text: 'Type `help` for available commands.' },
        ],
        clearScrollback: false,
      };
  }
}
