import { useEffect, useRef, useState } from 'react';
import type { MarkdownSnippet } from '@labword/domain/shared/markdown/markdown-snippets';
import { filterMarkdownSnippets } from '@labword/domain/domain/markdown/formatting-palette.service';
import { OverlayCloseButton } from '@labword/app/features/overlays/overlay-controls';

export interface FormattingPaletteOverlayViewProps {
  readonly onSelect: (snippet: MarkdownSnippet) => void;
  readonly onDismiss: () => void;
}

export function FormattingPaletteOverlayView(
  props: FormattingPaletteOverlayViewProps,
): React.JSX.Element {
  const { onSelect, onDismiss } = props;
  const [query, setQuery] = useState('');
  const [selectedIndex, setSelectedIndex] = useState(0);
  const inputRef = useRef<HTMLInputElement>(null);
  const results = filterMarkdownSnippets(query);

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  useEffect(() => {
    setSelectedIndex(0);
  }, [query]);

  useEffect(() => {
    if (results.length === 0) {
      setSelectedIndex(0);
      return;
    }
    if (selectedIndex >= results.length) {
      setSelectedIndex(results.length - 1);
    }
  }, [results.length, selectedIndex]);

  const selectSnippet = (snippet: MarkdownSnippet): void => {
    onSelect(snippet);
  };

  const handleKeyDown = (event: React.KeyboardEvent): void => {
    if (event.key === 'Escape') {
      event.preventDefault();
      onDismiss();
      return;
    }

    if (event.key === 'ArrowDown') {
      event.preventDefault();
      if (results.length === 0) {
        return;
      }
      setSelectedIndex((current) => (current + 1) % results.length);
      return;
    }

    if (event.key === 'ArrowUp') {
      event.preventDefault();
      if (results.length === 0) {
        return;
      }
      setSelectedIndex((current) => (current - 1 + results.length) % results.length);
      return;
    }

    if (event.key === 'Enter') {
      event.preventDefault();
      const selected = results[selectedIndex];
      if (selected !== undefined) {
        selectSnippet(selected);
      }
    }
  };

  return (
    <div className="formatting-palette" onKeyDown={handleKeyDown}>
      <div className="formatting-palette-search-row">
        <input
          ref={inputRef}
          className="formatting-palette-input"
          type="search"
          value={query}
          placeholder="Insert formatting…  task, heading, quote"
          aria-label="Search formatting snippets"
          onChange={(event) => {
            setQuery(event.target.value);
          }}
        />
        <OverlayCloseButton onClick={onDismiss} />
      </div>

      <div className="formatting-palette-results" role="listbox" aria-label="Formatting snippets">
        {results.length === 0 ? (
          <p className="formatting-palette-empty">No matching formatting.</p>
        ) : (
          results.map((snippet, index) => (
            <button
              key={snippet.id}
              type="button"
              className={
                index === selectedIndex
                  ? 'formatting-palette-row is-selected'
                  : 'formatting-palette-row'
              }
              role="option"
              aria-selected={index === selectedIndex}
              onMouseEnter={() => {
                setSelectedIndex(index);
              }}
              onClick={() => {
                selectSnippet(snippet);
              }}
            >
              <span className="formatting-palette-title">{snippet.title}</span>
              <code className="formatting-palette-syntax">{snippet.syntax}</code>
              <span className="formatting-palette-category">{snippet.category}</span>
            </button>
          ))
        )}
      </div>
    </div>
  );
}
