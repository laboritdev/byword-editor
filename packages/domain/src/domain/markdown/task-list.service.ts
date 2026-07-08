import { lineAtPosition } from '@labword/domain/domain/markdown/text-line.utils';

export interface TaskListEditResult {
  readonly text: string;
  readonly cursor: number;
}

const TASK_LINE_PATTERN = /^(\s*[-*+]\s+\[)( |x|X)(\])/;
const CHECKBOX_PATTERN = /\[( |x|X)\]/;

interface CheckboxClickRange {
  readonly from: number;
  readonly to: number;
}

function checkboxClickRange(line: string): CheckboxClickRange | null {
  const match = CHECKBOX_PATTERN.exec(line);
  if (match === null) {
    return null;
  }
  return {
    from: match.index,
    to: match.index + match[0].length,
  };
}

function isClickInsideCheckbox(lineText: string, clickOffset: number): boolean {
  const range = checkboxClickRange(lineText);
  if (range === null) {
    return false;
  }
  return clickOffset >= range.from && clickOffset < range.to;
}

export function toggleTaskCheckbox(text: string, location: number): TaskListEditResult | null {
  const line = lineAtPosition(text, location);
  const match = TASK_LINE_PATTERN.exec(line.text);
  if (match === null) {
    return null;
  }

  const clickOffset = location - line.from;
  if (!isClickInsideCheckbox(line.text, clickOffset)) {
    return null;
  }

  const stateGroup = match[2];
  const nextState = stateGroup === ' ' ? 'x' : ' ';
  const markerGroup = match[1];
  if (markerGroup === undefined) {
    return null;
  }
  const stateStartInLine = match.index + markerGroup.length;
  const stateFrom = line.from + stateStartInLine;
  const updatedText = text.slice(0, stateFrom) + nextState + text.slice(stateFrom + 1);
  return {
    text: updatedText,
    cursor: location,
  };
}

export function toggleTaskCheckboxNear(text: string, location: number): TaskListEditResult | null {
  return toggleTaskCheckbox(text, location);
}

export function isCheckedTaskLine(line: string): boolean {
  const match = TASK_LINE_PATTERN.exec(line);
  if (match === null) {
    return false;
  }
  return match[2] !== ' ';
}
