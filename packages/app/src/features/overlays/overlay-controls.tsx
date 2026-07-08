export interface SegmentedOption<T extends string> {
  readonly value: T;
  readonly label: string;
}

export interface SegmentedControlProps<T extends string> {
  readonly label: string;
  readonly options: readonly SegmentedOption<T>[];
  readonly value: T;
  readonly onChange: (value: T) => void;
}

export function SegmentedControl<T extends string>(
  props: SegmentedControlProps<T>,
): React.JSX.Element {
  const { label, options, value, onChange } = props;

  return (
    <div className="mac-segmented-field">
      <span className="mac-segmented-label">{label}</span>
      <div className="mac-segmented" role="tablist" aria-label={label}>
        {options.map((option) => (
          <button
            key={option.value}
            type="button"
            role="tab"
            aria-selected={value === option.value}
            className={value === option.value ? 'mac-segment is-active' : 'mac-segment'}
            onClick={() => {
              onChange(option.value);
            }}
          >
            {option.label}
          </button>
        ))}
      </div>
    </div>
  );
}

export function OverlayCloseButton(props: { readonly onClick: () => void }): React.JSX.Element {
  return (
    <button
      type="button"
      className="editor-overlay-close"
      onClick={props.onClick}
      aria-label="Close"
    >
      <svg width="18" height="18" viewBox="0 0 18 18" aria-hidden="true">
        <circle cx="9" cy="9" r="9" fill="currentColor" opacity="0.22" />
        <path
          d="M6.1 6.1a.55.55 0 0 1 .78 0L9 8.22l2.12-2.12a.55.55 0 1 1 .78.78L9.78 9l2.12 2.12a.55.55 0 1 1-.78.78L9 9.78 6.88 11.9a.55.55 0 1 1-.78-.78L8.22 9 6.1 6.88a.55.55 0 0 1 0-.78Z"
          fill="currentColor"
        />
      </svg>
    </button>
  );
}
