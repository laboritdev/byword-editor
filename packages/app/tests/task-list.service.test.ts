import { describe, expect, it } from 'vitest';
import {
  isCheckedTaskLine,
  toggleTaskCheckbox,
  toggleTaskCheckboxNear,
} from '@labword/domain/domain/markdown/task-list.service';

describe('toggleTaskCheckbox', () => {
  it('toggles unchecked to checked when clicking inside checkbox', () => {
    const source = '- [ ] Todo item';
    const spaceInsideIndex = source.indexOf('[') + 1;
    const result = toggleTaskCheckbox(source, spaceInsideIndex);
    expect(result?.text).toBe('- [x] Todo item');
  });

  it('toggles checked to unchecked', () => {
    const source = '- [x] Done';
    const checkboxIndex = source.indexOf('x');
    const result = toggleTaskCheckbox(source, checkboxIndex);
    expect(result?.text).toBe('- [ ] Done');
  });

  it('toggles when clicking opening or closing bracket', () => {
    const source = '- [ ] Todo';
    const openBracket = source.indexOf('[');
    const closeBracket = source.indexOf(']');
    expect(toggleTaskCheckbox(source, openBracket)?.text).toBe('- [x] Todo');
    expect(toggleTaskCheckbox(source, closeBracket)?.text).toBe('- [x] Todo');
  });

  it('does not toggle when clicking task body text', () => {
    const source = '- [ ] something to do';
    const bodyIndex = source.indexOf('something');
    expect(toggleTaskCheckbox(source, bodyIndex)).toBeNull();
    expect(toggleTaskCheckbox(source, bodyIndex + 2)).toBeNull();
  });

  it('does not toggle when clicking bullet marker or space after checkbox', () => {
    const source = '- [ ] Todo item';
    expect(toggleTaskCheckbox(source, source.indexOf('-'))).toBeNull();
    expect(toggleTaskCheckbox(source, source.indexOf(']') + 1)).toBeNull();
  });

  it('does not toggle via nearby offset outside checkbox', () => {
    const source = '- [ ] something to do';
    const bodyIndex = source.indexOf('something');
    expect(toggleTaskCheckboxNear(source, bodyIndex)).toBeNull();
    expect(toggleTaskCheckboxNear(source, bodyIndex + 1)).toBeNull();
  });
});

describe('isCheckedTaskLine', () => {
  it('detects checked and unchecked lines', () => {
    expect(isCheckedTaskLine('- [x] Done')).toBe(true);
    expect(isCheckedTaskLine('- [ ] Todo')).toBe(false);
  });
});
