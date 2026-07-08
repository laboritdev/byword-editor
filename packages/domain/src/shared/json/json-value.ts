export type JsonPrimitive = string | number | boolean | null;

export type JsonObject = { readonly [key: string]: JsonValue };

export type JsonArray = readonly JsonValue[];

export type JsonValue = JsonPrimitive | JsonObject | JsonArray;

export function isJsonObject(value: JsonValue): value is JsonObject {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

export function isJsonArray(value: JsonValue): value is JsonArray {
  return Array.isArray(value);
}
