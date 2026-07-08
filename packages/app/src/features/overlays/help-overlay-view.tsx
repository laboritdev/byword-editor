import { useState } from 'react';
import { SegmentedControl } from '@labword/app/features/overlays/overlay-controls';
import { FORMATTING_SECTIONS, HELP_SECTIONS } from '@labword/domain/shared/help/help-reference';

type HelpTab = 'shortcuts' | 'formatting';

const HELP_TABS = [
  { value: 'shortcuts' as const, label: 'Shortcuts' },
  { value: 'formatting' as const, label: 'Formatting' },
];

export interface HelpOverlayViewProps {
  readonly initialTab?: HelpTab;
}

export function HelpOverlayView(props: HelpOverlayViewProps): React.JSX.Element {
  const [selectedTab, setSelectedTab] = useState<HelpTab>(props.initialTab ?? 'shortcuts');

  return (
    <div className="help-overlay">
      <SegmentedControl
        label="Section"
        options={HELP_TABS}
        value={selectedTab}
        onChange={setSelectedTab}
      />

      <div className="help-overlay-scroll">
        <div className={selectedTab === 'shortcuts' ? 'help-tab-panel' : 'help-tab-panel is-hidden'}>
          <ShortcutsContent />
        </div>
        <div className={selectedTab === 'formatting' ? 'help-tab-panel' : 'help-tab-panel is-hidden'}>
          <FormattingContent />
        </div>
      </div>
    </div>
  );
}

function ShortcutsContent(): React.JSX.Element {
  return (
    <div className="help-sections">
      {HELP_SECTIONS.map((section) => (
        <section key={section.title} className="help-section">
          <h3 className="help-section-title">{section.title}</h3>
          <div className="help-shortcut-list">
            {section.shortcuts.map((item) => (
              <div key={item.action} className="help-shortcut-row">
                <span className="help-shortcut-action">{item.action}</span>
                <span className="help-shortcut-keys">{item.shortcut}</span>
              </div>
            ))}
          </div>
        </section>
      ))}
    </div>
  );
}

function FormattingContent(): React.JSX.Element {
  return (
    <div className="help-sections">
      {FORMATTING_SECTIONS.map((section) => (
        <section key={section.title} className="help-section">
          <h3 className="help-section-title">{section.title}</h3>
          {section.hints.map((hint) => (
            <div key={hint.syntax} className="help-format-row">
              <div className="help-format-heading">
                <span className="help-format-title">{hint.title}</span>
                <code className="help-format-syntax">{hint.syntax}</code>
              </div>
              <p className="help-format-description">{hint.description}</p>
            </div>
          ))}
        </section>
      ))}
    </div>
  );
}
