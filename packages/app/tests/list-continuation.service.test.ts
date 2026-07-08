import { describe, expect, it } from 'vitest';
import { handleListEnter } from '@labword/domain/domain/markdown/list-continuation.service';

describe('handleListEnter', () => {
  it('continues bullet list on enter', () => {
    const source = '- Item';
    const result = handleListEnter(source, source.length);
    expect(result).toEqual({ text: '- Item\n- ', cursor: 9 });
  });

  it('exits bullet list on empty item', () => {
    const source = '- Item\n- ';
    const result = handleListEnter(source, source.length);
    expect(result).toEqual({ text: '- Item\n', cursor: 7 });
  });

  it('continues numbered list on enter', () => {
    const source = '1. teste';
    const result = handleListEnter(source, source.length);
    expect(result).toEqual({ text: '1. teste\n2. ', cursor: 12 });
  });

  it('exits numbered list on empty item', () => {
    const source = '1. teste\n2. ';
    const result = handleListEnter(source, source.length);
    expect(result).toEqual({ text: '1. teste\n', cursor: 9 });
  });

  it('continues task list on enter', () => {
    const source = '- [ ] hyperion sso hml';
    const result = handleListEnter(source, source.length);
    expect(result).toEqual({ text: '- [ ] hyperion sso hml\n- [ ] ', cursor: 29 });
  });

  it('exits task list on empty item', () => {
    const source = '- [ ] hyperion\n- [ ] ';
    const result = handleListEnter(source, source.length);
    expect(result).toEqual({ text: '- [ ] hyperion\n', cursor: 15 });
  });

  it('exits bare bullet marker line', () => {
    const source = '- teste\n-';
    const result = handleListEnter(source, source.length);
    expect(result).toEqual({ text: '- teste\n', cursor: 8 });
  });

  it('continues task item before a blank line and following block', () => {
    const source = '- [ ] something to do\n- [ ] something done\n\n> Write without noise.';
    const cursor = source.indexOf('done') + 4;
    const result = handleListEnter(source, cursor);
    expect(result?.text).toBe(
      '- [ ] something to do\n- [ ] something done\n- [ ] \n\n> Write without noise.',
    );
    expect(result?.cursor).toBe(source.indexOf('done') + 4 + '- [ ] \n'.length);
  });

  it('continues task item at body start without duplicating the next item', () => {
    const source = '- [x] something to do\n\n- [ ] something done';
    const cursor = source.indexOf('something to do');
    const result = handleListEnter(source, cursor);
    expect(result?.text).toBe('- [x] something to do\n- [ ] \n\n- [ ] something done');
    expect(result?.text.includes('- [ ] - [ ]')).toBe(false);
  });

  it('continues task item when enter is inside the marker prefix', () => {
    const source = '- [ ] something to do';
    const result = handleListEnter(source, 2);
    expect(result?.text).toBe('- [ ] something to do\n- [ ] ');
    expect(result?.cursor).toBe(result?.text.length);
  });
});
