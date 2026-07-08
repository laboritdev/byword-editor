import {
  analyzeListLine,
  continuationPrefix,
  markerContainsCursor,
} from '@labword/domain/domain/markdown/list-line-marker';
import { lineAtPosition } from '@labword/domain/domain/markdown/text-line.utils';

export interface ListEditResult {
  readonly text: string;
  readonly cursor: number;
}

export function handleListEnter(text: string, cursor: number): ListEditResult | null {
  const line = lineAtPosition(text, cursor);
  const analyzed = analyzeListLine(line.text);
  if (analyzed === null) {
    return null;
  }

  const bodyIsEmpty = analyzed.body.trim().length === 0;

  if (bodyIsEmpty) {
    return exitEmptyListLine(text, line.from, line.to);
  }

  if (markerContainsCursor(analyzed.marker, line.offsetInLine)) {
    return continueListLine(text, cursor);
  }

  return continueListLine(text, cursor);
}

function continueListLine(text: string, cursor: number): ListEditResult {
  const line = lineAtPosition(text, cursor);
  const analyzed = analyzeListLine(line.text);
  if (analyzed === null) {
    return { text, cursor };
  }

  const insertAt = line.from + line.text.length;
  const prefix = continuationPrefix(analyzed.marker);
  const nextText = text.slice(0, insertAt) + prefix + text.slice(insertAt);
  return {
    text: nextText,
    cursor: insertAt + prefix.length,
  };
}

function exitEmptyListLine(text: string, lineFrom: number, lineTo: number): ListEditResult {
  const nextText = text.slice(0, lineFrom) + text.slice(lineTo);
  return {
    text: nextText,
    cursor: lineFrom,
  };
}
