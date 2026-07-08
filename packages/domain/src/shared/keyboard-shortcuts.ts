interface FontShortcutEvent {
  readonly metaKey: boolean;
  readonly ctrlKey: boolean;
  readonly shiftKey: boolean;
  readonly altKey: boolean;
  readonly key: string;
}

export function isIncreaseFontSizeShortcut(event: FontShortcutEvent): boolean {
  const mod = event.metaKey || event.ctrlKey;
  if (!mod || !event.shiftKey || event.altKey) {
    return false;
  }
  return event.key === '>' || event.key === '.';
}

export function isDecreaseFontSizeShortcut(event: FontShortcutEvent): boolean {
  const mod = event.metaKey || event.ctrlKey;
  if (!mod || !event.shiftKey || event.altKey) {
    return false;
  }
  return event.key === '<' || event.key === ',';
}
