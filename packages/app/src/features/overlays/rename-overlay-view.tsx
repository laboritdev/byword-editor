import { useEffect, useRef, useState, type SubmitEvent } from 'react';

export interface RenameOverlayViewProps {
  readonly currentName: string;
  readonly onConfirm: (newName: string) => void;
  readonly onCancel: () => void;
}

export function RenameOverlayView(props: RenameOverlayViewProps): React.JSX.Element {
  const { currentName, onConfirm, onCancel } = props;
  const [value, setValue] = useState(currentName);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    inputRef.current?.focus();
    inputRef.current?.select();
  }, []);

  const handleSubmit = (event: SubmitEvent): void => {
    event.preventDefault();
    const trimmed = value.trim();
    if (trimmed.length > 0) {
      onConfirm(trimmed);
    }
  };

  return (
    <form className="rename-overlay" onSubmit={handleSubmit}>
      <p className="rename-overlay-lead">Enter a new name for this file.</p>
      <input
        ref={inputRef}
        className="rename-overlay-input"
        type="text"
        value={value}
        onChange={(event) => {
          setValue(event.target.value);
        }}
        aria-label="New file name"
      />
      <div className="rename-overlay-actions">
        <button type="button" className="rename-overlay-button is-secondary" onClick={onCancel}>
          Cancel
        </button>
        <button type="submit" className="rename-overlay-button is-primary">
          Rename
        </button>
      </div>
    </form>
  );
}
