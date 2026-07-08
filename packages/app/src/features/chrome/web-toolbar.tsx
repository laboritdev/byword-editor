export interface WebToolbarProps {
  readonly onNew: () => void;
  readonly onOpen: () => void;
  readonly onSave: () => void;
  readonly onSaveAs: () => void;
  readonly onTogglePreview: () => void;
  readonly onToggleAgent: () => void;
  readonly onOpenHelp: () => void;
  readonly onOpenPreferences: () => void;
}

export function WebToolbar(props: WebToolbarProps): React.JSX.Element {
  const {
    onNew,
    onOpen,
    onSave,
    onSaveAs,
    onTogglePreview,
    onToggleAgent,
    onOpenHelp,
    onOpenPreferences,
  } = props;

  return (
    <div className="web-toolbar">
      <button type="button" className="web-toolbar-button" onClick={onNew}>
        New
      </button>
      <button type="button" className="web-toolbar-button" onClick={onOpen}>
        Open
      </button>
      <button type="button" className="web-toolbar-button" onClick={onSave}>
        Save
      </button>
      <button type="button" className="web-toolbar-button" onClick={onSaveAs}>
        Save As
      </button>
      <span className="web-toolbar-separator" aria-hidden="true" />
      <button type="button" className="web-toolbar-button" onClick={onTogglePreview}>
        Preview
      </button>
      <button type="button" className="web-toolbar-button" onClick={onToggleAgent}>
        Agent
      </button>
      <button type="button" className="web-toolbar-button" onClick={onOpenHelp}>
        Help
      </button>
      <button type="button" className="web-toolbar-button" onClick={onOpenPreferences}>
        Preferences
      </button>
    </div>
  );
}
