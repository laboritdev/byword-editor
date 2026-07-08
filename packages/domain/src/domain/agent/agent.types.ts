export interface ParsedAgentCommand {
  readonly root: string;
  readonly arguments: readonly string[];
  readonly raw: string;
}

export interface TerminalHelpRow {
  readonly label: string;
  readonly value: string;
}

export interface TerminalHelpSection {
  readonly title: string;
  readonly rows: readonly TerminalHelpRow[];
}

export interface TerminalHelpDocument {
  readonly title: string;
  readonly sections: readonly TerminalHelpSection[];
}

export type AgentTerminalBlock =
  | { readonly kind: 'text'; readonly text: string }
  | { readonly kind: 'help'; readonly document: TerminalHelpDocument };

export interface AgentCommandResult {
  readonly blocks: readonly AgentTerminalBlock[];
  readonly clearScrollback: boolean;
}

export interface AgentCommandDefinition {
  readonly name: string;
  readonly aliases: readonly string[];
  readonly usage: string;
  readonly summary: string;
}

export interface AgentProviderPort {
  readonly label: string;
  readonly isCloud: boolean;
  streamResponse(prompt: string, selection: string | null): AsyncIterable<string>;
}
