export interface LineAtPosition {
  readonly lineNumber: number;
  readonly from: number;
  readonly to: number;
  readonly text: string;
  readonly offsetInLine: number;
}

export function lineAtPosition(text: string, position: number): LineAtPosition {
  const safePosition = Math.min(Math.max(0, position), text.length);
  let lineNumber = 1;
  let lineStart = 0;

  for (let index = 0; index < text.length; index += 1) {
    if (index >= safePosition) {
      break;
    }
    if (text[index] === '\n') {
      lineNumber += 1;
      lineStart = index + 1;
    }
  }

  let lineEnd = text.length;
  for (let index = lineStart; index < text.length; index += 1) {
    if (text[index] === '\n') {
      lineEnd = index + 1;
      break;
    }
  }

  return {
    lineNumber,
    from: lineStart,
    to: lineEnd,
    text: text.slice(lineStart, lineEnd === text.length ? lineEnd : lineEnd - 1),
    offsetInLine: safePosition - lineStart,
  };
}
