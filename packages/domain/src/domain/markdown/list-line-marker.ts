export type ListLineMarker =
  | { readonly kind: 'bullet'; readonly indent: string; readonly marker: string; readonly prefixLength: number }
  | {
      readonly kind: 'task';
      readonly indent: string;
      readonly marker: string;
      readonly checked: boolean;
      readonly prefixLength: number;
    }
  | { readonly kind: 'numbered'; readonly indent: string; readonly number: number; readonly prefixLength: number };

const TASK_PATTERN = /^(\s*)([-*+])\s+\[( |x|X)\](\s*)(.*)$/;
const BULLET_PATTERN = /^(\s*)([-*+])(\s+)(.*)$/;
const BULLET_MARKER_ONLY_PATTERN = /^(\s*)([-*+])$/;
const NUMBERED_PATTERN = /^(\s*)(\d+)\.(\s*)(.*)$/;

export function continuationPrefix(marker: ListLineMarker): string {
  switch (marker.kind) {
    case 'bullet':
      return `\n${marker.indent}${marker.marker} `;
    case 'task':
      return `\n${marker.indent}${marker.marker} [ ] `;
    case 'numbered':
      return `\n${marker.indent}${String(marker.number + 1)}. `;
  }
}

export function markerContainsCursor(marker: ListLineMarker, offsetInLine: number): boolean {
  return offsetInLine < marker.prefixLength;
}

export function analyzeListLine(line: string): { readonly marker: ListLineMarker; readonly body: string } | null {
  if (line.length === 0) {
    return null;
  }

  const taskMatch = TASK_PATTERN.exec(line);
  if (taskMatch !== null) {
    const indent = taskMatch[1] ?? '';
    const markerChar = taskMatch[2] ?? '-';
    const checked = (taskMatch[3] ?? ' ') !== ' ';
    const body = taskMatch[5] ?? '';
    const prefixLength = line.length - body.length;
    return {
      marker: {
        kind: 'task',
        indent,
        marker: markerChar,
        checked,
        prefixLength,
      },
      body,
    };
  }

  const bulletMatch = BULLET_PATTERN.exec(line);
  if (bulletMatch !== null) {
    const indent = bulletMatch[1] ?? '';
    const markerChar = bulletMatch[2] ?? '-';
    const body = bulletMatch[4] ?? '';
    const prefixLength = line.length - body.length;
    return {
      marker: {
        kind: 'bullet',
        indent,
        marker: markerChar,
        prefixLength,
      },
      body,
    };
  }

  const markerOnlyMatch = BULLET_MARKER_ONLY_PATTERN.exec(line);
  if (markerOnlyMatch !== null) {
    const indent = markerOnlyMatch[1] ?? '';
    const markerChar = markerOnlyMatch[2] ?? '-';
    return {
      marker: {
        kind: 'bullet',
        indent,
        marker: markerChar,
        prefixLength: line.length,
      },
      body: '',
    };
  }

  const numberedMatch = NUMBERED_PATTERN.exec(line);
  if (numberedMatch !== null) {
    const indent = numberedMatch[1] ?? '';
    const number = Number.parseInt(numberedMatch[2] ?? '1', 10);
    const body = numberedMatch[4] ?? '';
    const prefixLength = line.length - body.length;
    return {
      marker: {
        kind: 'numbered',
        indent,
        number,
        prefixLength,
      },
      body,
    };
  }

  return null;
}
