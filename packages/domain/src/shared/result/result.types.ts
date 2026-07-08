export type Result<TValue, TError extends string = string> =
  | { readonly ok: true; readonly value: TValue }
  | { readonly ok: false; readonly error: TError };

export function ok<TValue>(value: TValue): Result<TValue, never> {
  return { ok: true, value };
}

export function err<TError extends string>(error: TError): Result<never, TError> {
  return { ok: false, error };
}
