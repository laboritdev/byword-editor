import { useMemo } from 'react';
import type { DocumentContent } from '@labword/domain/domain/document/document.types';
import { renderMarkdownPreviewDocument } from '@labword/domain/shared/services/markdown-renderer.service';

export interface MarkdownPreviewFeatureProps {
  readonly content: DocumentContent;
  readonly title: string;
}

export function MarkdownPreviewFeature(props: MarkdownPreviewFeatureProps): React.JSX.Element {
  const { content, title } = props;
  const html = useMemo(() => renderMarkdownPreviewDocument(content, title), [content, title]);

  return (
    <div className="preview-host">
      <iframe
        className="preview-frame"
        title="Markdown preview"
        sandbox=""
        srcDoc={html}
      />
    </div>
  );
}
