import type { TerminalHelpDocument } from '@labword/domain/domain/agent/agent.types';
import { HELP_TERMINAL_RULE } from '@labword/domain/shared/help/help-reference';

export interface AgentHelpTableViewProps {
  readonly document: TerminalHelpDocument;
}

export function AgentHelpTableView(props: AgentHelpTableViewProps): React.JSX.Element {
  const { document } = props;

  return (
    <div className="agent-help">
      <div className="agent-help-header">{document.title}</div>
      <div className="agent-help-rule">{HELP_TERMINAL_RULE}</div>
      <div className="agent-help-grid">
        {document.sections.map((section) => (
          <section key={section.title} className="agent-help-section">
            <h4 className="agent-help-section-title">{section.title}</h4>
            {section.rows.map((row) => (
              <div key={`${section.title}-${row.label}`} className="agent-help-row">
                <span className="agent-help-label">{row.label}</span>
                <span className="agent-help-leader" aria-hidden="true" />
                <span className="agent-help-value">{row.value}</span>
              </div>
            ))}
          </section>
        ))}
      </div>
    </div>
  );
}
