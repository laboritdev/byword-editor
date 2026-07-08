import type { EditorPreferences, TextWidthPreset } from '@labword/domain/shared/preferences/editor-preferences';
import { SegmentedControl } from '@labword/app/features/overlays/overlay-controls';

export interface PreferencesOverlayViewProps {
  readonly preferences: EditorPreferences;
  readonly onChange: (preferences: EditorPreferences) => void;
}

const TEXT_WIDTH_OPTIONS = [
  { value: 'narrow' as const, label: 'Narrow' },
  { value: 'medium' as const, label: 'Medium' },
  { value: 'wide' as const, label: 'Wide' },
];

export function PreferencesOverlayView(props: PreferencesOverlayViewProps): React.JSX.Element {
  const { preferences, onChange } = props;

  return (
    <div className="preferences-overlay">
      <p className="preferences-lead">Choose text size and column width for writing.</p>

      <label className="preferences-field">
        <span className="preferences-label">Size</span>
        <div className="preferences-slider-row">
          <input
            className="mac-slider"
            type="range"
            min={14}
            max={28}
            step={1}
            value={preferences.fontSizePx}
            onChange={(event) => {
              onChange({ ...preferences, fontSizePx: Number(event.target.value) });
            }}
          />
          <span className="preferences-value">{String(preferences.fontSizePx)} pt</span>
        </div>
      </label>

      <SegmentedControl<TextWidthPreset>
        label="Text Width"
        options={TEXT_WIDTH_OPTIONS}
        value={preferences.textWidth}
        onChange={(textWidth) => {
          onChange({ ...preferences, textWidth });
        }}
      />

      <label className="preferences-toggle">
        <input
          type="checkbox"
          checked={preferences.showIntroDemo}
          onChange={(event) => {
            onChange({ ...preferences, showIntroDemo: event.target.checked });
          }}
        />
        <span>Show intro demo on new documents</span>
      </label>

      <label className="preferences-toggle">
        <input
          type="checkbox"
          checked={preferences.showStatusBar}
          onChange={(event) => {
            onChange({ ...preferences, showStatusBar: event.target.checked });
          }}
        />
        <span>Show status bar</span>
      </label>
    </div>
  );
}
