import { useCallback, useEffect, useRef, useState, type KeyboardEvent, type SubmitEvent } from 'react';
import type { AgentTerminalBlock } from '@labword/domain/domain/agent/agent.types';
import { autocompleteCommand } from '@labword/domain/domain/agent/command-registry';
import {
  countWords,
  executeAgentCommand,
  type AgentCommandContext,
} from '@labword/app/features/agent-terminal/agent-command.service';
import { AgentHelpTableView } from '@labword/app/features/agent-terminal/agent-help-table-view';
import type { DocumentContent } from '@labword/domain/domain/document/document.types';

export interface AgentTerminalFeatureProps {
  readonly content: DocumentContent;
  readonly onSave: () => void;
  readonly onTogglePreview: () => void;
  readonly onOpenSettings: () => void;
  readonly onClose: () => void;
}

interface TerminalInputLine {
  readonly id: string;
  readonly text: string;
}

interface TerminalOutputBlock {
  readonly id: string;
  readonly block: AgentTerminalBlock;
}

type TerminalEntry = TerminalInputLine | TerminalOutputBlock;

function isInputLine(entry: TerminalEntry): entry is TerminalInputLine {
  return 'text' in entry;
}

export function AgentTerminalFeature(props: AgentTerminalFeatureProps): React.JSX.Element {
  const [entries, setEntries] = useState<readonly TerminalEntry[]>([]);
  const [draft, setDraft] = useState<string>('');
  const historyRef = useRef<readonly string[]>([]);
  const historyIndexRef = useRef<number | null>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const scrollbackRef = useRef<HTMLDivElement>(null);
  const bottomAnchorRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  useEffect(() => {
    const scrollToLatest = (): void => {
      bottomAnchorRef.current?.scrollIntoView({ block: 'end' });
      const scrollback = scrollbackRef.current;
      if (scrollback !== null) {
        scrollback.scrollTop = scrollback.scrollHeight;
      }
    };

    scrollToLatest();
    const frame = window.requestAnimationFrame(() => {
      scrollToLatest();
    });
    return (): void => {
      window.cancelAnimationFrame(frame);
    };
  }, [entries]);

  const buildContext = useCallback((): AgentCommandContext => {
    return {
      content: props.content,
      wordCount: countWords(props.content),
      onSave: props.onSave,
      onTogglePreview: props.onTogglePreview,
      onOpenSettings: props.onOpenSettings,
    };
  }, [props.content, props.onSave, props.onTogglePreview, props.onOpenSettings]);

  const runCommand = useCallback(
    (raw: string) => {
      const trimmed = raw.trim();
      if (trimmed.length === 0) {
        return;
      }

      const inputLine: TerminalInputLine = {
        id: crypto.randomUUID(),
        text: `> ${trimmed}`,
      };
      historyRef.current = [...historyRef.current.filter((item) => item !== trimmed), trimmed];
      historyIndexRef.current = null;

      const result = executeAgentCommand(trimmed, buildContext());
      if (result.clearScrollback) {
        setEntries([]);
        return;
      }

      const outputBlocks: TerminalOutputBlock[] = result.blocks.map((block) => ({
        id: crypto.randomUUID(),
        block,
      }));

      setEntries((current) => [...current, inputLine, ...outputBlocks]);
    },
    [buildContext],
  );

  const handleSubmit = (event: SubmitEvent<HTMLFormElement>): void => {
    event.preventDefault();
    runCommand(draft);
    setDraft('');
    inputRef.current?.focus();
  };

  const handleKeyDown = (event: KeyboardEvent<HTMLInputElement>): void => {
    if (event.key === 'ArrowUp') {
      event.preventDefault();
      const history = historyRef.current;
      if (history.length === 0) {
        return;
      }
      const index =
        historyIndexRef.current === null
          ? history.length - 1
          : Math.max(historyIndexRef.current - 1, 0);
      historyIndexRef.current = index;
      const entry = history[index];
      if (entry !== undefined) {
        setDraft(entry);
      }
      return;
    }

    if (event.key === 'ArrowDown') {
      event.preventDefault();
      const history = historyRef.current;
      if (historyIndexRef.current === null) {
        return;
      }
      if (historyIndexRef.current >= history.length - 1) {
        historyIndexRef.current = null;
        setDraft('');
        return;
      }
      const nextIndex = historyIndexRef.current + 1;
      historyIndexRef.current = nextIndex;
      const entry = history[nextIndex];
      if (entry !== undefined) {
        setDraft(entry);
      }
      return;
    }

    if (event.key === 'Escape') {
      event.preventDefault();
      props.onClose();
      return;
    }

    if (event.key === 'Tab') {
      event.preventDefault();
      const completion = autocompleteCommand(draft);
      if (completion !== null) {
        setDraft(completion);
      }
    }
  };

  return (
    <section className="agent-terminal">
      <div className="agent-scrollback" ref={scrollbackRef}>
        {entries.length === 0 ? (
          <p className="agent-muted">LabWord Agent — try `?`, `hs`, or `stats`</p>
        ) : (
          entries.map((entry) => {
            if (isInputLine(entry)) {
              return (
                <div key={entry.id} className="agent-line agent-line-input">
                  {entry.text}
                </div>
              );
            }

            if (entry.block.kind === 'help') {
              return (
                <div key={entry.id} className="agent-line agent-line-output">
                  <AgentHelpTableView document={entry.block.document} />
                </div>
              );
            }

            return (
              <div key={entry.id} className="agent-line agent-line-output">
                {entry.block.text}
              </div>
            );
          })
        )}
        <div ref={bottomAnchorRef} className="agent-scroll-anchor" aria-hidden="true" />
      </div>
      <form className="agent-input-row" onSubmit={handleSubmit}>
        <span className="agent-prompt">&gt;</span>
        <input
          ref={inputRef}
          className="agent-input"
          type="text"
          value={draft}
          placeholder="?"
          spellCheck={false}
          autoComplete="off"
          onChange={(event) => {
            setDraft(event.target.value);
          }}
          onKeyDown={handleKeyDown}
        />
      </form>
    </section>
  );
}
