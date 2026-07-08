import type { PlatformPort } from '@labword/platform';

let activePlatform: PlatformPort | null = null;

export function installPlatform(platform: PlatformPort): void {
  activePlatform = platform;
}

export function resetPlatform(): void {
  activePlatform = null;
}

export function getPlatform(): PlatformPort {
  if (activePlatform === null) {
    throw new Error('Platform is not installed. Wrap the app with a platform adapter.');
  }
  return activePlatform;
}

export function getPlatformOptional(): PlatformPort | null {
  return activePlatform;
}
