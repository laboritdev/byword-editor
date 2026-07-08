export interface UnsavedChangesOverlayViewProps {
  readonly documentTitle: string;
  readonly onSave: () => void;
  readonly onDiscard: () => void;
  readonly onCancel: () => void;
}

export function UnsavedChangesOverlayView(
  props: UnsavedChangesOverlayViewProps,
): React.JSX.Element {
  const { documentTitle, onSave, onDiscard, onCancel } = props;

  return (
    <div className="unsaved-overlay">
      <p className="unsaved-overlay-lead">
        Do you want to save the changes made to &ldquo;{documentTitle}&rdquo;?
      </p>
      <div className="unsaved-overlay-actions">
        <button type="button" className="unsaved-overlay-button is-secondary" onClick={onCancel}>
          Cancel
        </button>
        <button type="button" className="unsaved-overlay-button is-secondary" onClick={onDiscard}>
          Don&apos;t Save
        </button>
        <button type="button" className="unsaved-overlay-button is-primary" onClick={onSave}>
          Save
        </button>
      </div>
    </div>
  );
}
