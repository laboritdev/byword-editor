import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import type { DocumentContent, DocumentSnapshot } from '@labword/domain/domain/document/document.types';
import { windowTitleFromSnapshot } from '@labword/domain/domain/document/document.types';
import type { EditorPanel } from '@labword/domain/domain/editor/editor-panel';
import { AgentTerminalFeature } from '@labword/app/features/agent-terminal/agent-terminal-feature';
import { WebToolbar } from '@labword/app/features/chrome/web-toolbar';
import {
  MarkdownEditorFeature,
  type CursorPosition,
  type MarkdownEditorFeatureHandle,
} from '@labword/app/features/editor/markdown-editor-feature';
import { MarkdownPreviewFeature } from '@labword/app/features/editor/markdown-preview-feature';
import { StatusBar } from '@labword/app/features/editor/status-bar';
import {
  createInitialDocument,
  openDocumentFromDialog,
  printDocument,
  renameDocument,
  saveDocumentAsFromDialog,
  saveDocumentSnapshot,
} from '@labword/app/features/editor/document-io.service';
import { EditorOverlayContainer } from '@labword/app/features/overlays/editor-overlay-container';
import { HelpOverlayView } from '@labword/app/features/overlays/help-overlay-view';
import { PreferencesOverlayView } from '@labword/app/features/overlays/preferences-overlay-view';
import { RenameOverlayView } from '@labword/app/features/overlays/rename-overlay-view';
import { UnsavedChangesOverlayView } from '@labword/app/features/overlays/unsaved-changes-overlay-view';
import { FormattingPaletteOverlayView } from '@labword/app/features/overlays/formatting-palette-overlay-view';
import type { MarkdownSnippet } from '@labword/domain/shared/markdown/markdown-snippets';
import {
  decreaseFontSize,
  increaseFontSize,
  layoutFromPreferences,
  loadEditorPreferences,
  saveEditorPreferences,
  type EditorPreferences,
} from '@labword/domain/shared/preferences/editor-preferences';
import {
  isDecreaseFontSizeShortcut,
  isIncreaseFontSizeShortcut,
} from '@labword/domain/shared/keyboard-shortcuts';
import { CLASSIC_DARK } from '@labword/domain/shared/theme/editor-theme';
import type { PlatformPort } from '@labword/platform';
import { installPlatform, resetPlatform } from '@labword/platform';

export type ViewMode = 'editor' | 'preview';

interface UnsavedPrompt {
  readonly onProceed: () => void;
  readonly closeWindow: boolean;
}

export interface LabwordAppProps {
  readonly platform: PlatformPort;
}

export function LabwordApp(props: LabwordAppProps): React.JSX.Element {
  const { platform } = props;
  const [document, setDocument] = useState<DocumentSnapshot>(() =>
    createInitialDocument(loadEditorPreferences().showIntroDemo),
  );
  const [viewMode, setViewMode] = useState<ViewMode>('editor');
  const [focusMode, setFocusMode] = useState<boolean>(false);
  const [showAgent, setShowAgent] = useState<boolean>(false);
  const [activePanel, setActivePanel] = useState<EditorPanel | null>(null);
  const [showRename, setShowRename] = useState<boolean>(false);
  const [unsavedPrompt, setUnsavedPrompt] = useState<UnsavedPrompt | null>(null);
  const [showFormattingPalette, setShowFormattingPalette] = useState<boolean>(false);
  const [helpInitialTab, setHelpInitialTab] = useState<'shortcuts' | 'formatting'>('shortcuts');
  const [cursor, setCursor] = useState<CursorPosition>({ line: 1, column: 1 });
  const [preferences, setPreferences] = useState<EditorPreferences>(() => loadEditorPreferences());
  const editorRef = useRef<MarkdownEditorFeatureHandle>(null);

  const editorLayout = useMemo(() => layoutFromPreferences(preferences), [preferences]);
  const chromeHidden = focusMode;
  const windowTitle = useMemo(() => windowTitleFromSnapshot(document), [document]);

  useEffect(() => {
    installPlatform(platform);
    return (): void => {
      resetPlatform();
    };
  }, [platform]);

  const applyPreferences = useCallback((next: EditorPreferences) => {
    setPreferences(next);
    saveEditorPreferences(next);
  }, []);

  const handleContentChange = useCallback((content: DocumentContent) => {
    setDocument((current) => ({
      ...current,
      content,
      isDirty: true,
    }));
  }, []);

  const handleSave = useCallback(() => {
    void saveDocumentSnapshot(document).then((saved) => {
      setDocument(saved);
    });
  }, [document]);

  const handleSaveAs = useCallback(() => {
    void saveDocumentAsFromDialog(document).then((saved) => {
      if (saved !== null) {
        setDocument(saved);
      }
    });
  }, [document]);

  const performOpen = useCallback(() => {
    void openDocumentFromDialog().then((opened) => {
      if (opened !== null) {
        setDocument(opened);
        setViewMode('editor');
      }
    });
  }, []);

  const promptIfDirty = useCallback(
    (onProceed: () => void, closeWindow = false) => {
      if (!document.isDirty) {
        onProceed();
        return;
      }
      setUnsavedPrompt({ onProceed, closeWindow });
    },
    [document.isDirty],
  );

  const handleOpen = useCallback(() => {
    promptIfDirty(performOpen);
  }, [performOpen, promptIfDirty]);

  const handleCloseWindow = useCallback(() => {
    promptIfDirty(
      () => {
        void platform.allowWindowClose();
      },
      true,
    );
  }, [platform, promptIfDirty]);

  const dismissUnsavedPrompt = useCallback(() => {
    setUnsavedPrompt(null);
  }, []);

  const proceedAfterUnsaved = useCallback((prompt: UnsavedPrompt) => {
    setUnsavedPrompt(null);
    if (prompt.closeWindow) {
      void platform.allowWindowClose();
      return;
    }
    prompt.onProceed();
  }, [platform]);

  const handleUnsavedSave = useCallback(() => {
    void saveDocumentSnapshot(document).then((saved) => {
      setDocument(saved);
      if (saved.isDirty) {
        return;
      }
      setUnsavedPrompt((current) => {
        if (current === null) {
          return null;
        }
        if (current.closeWindow) {
          void platform.allowWindowClose();
        } else {
          current.onProceed();
        }
        return null;
      });
    });
  }, [document, platform]);

  const handleUnsavedDiscard = useCallback(() => {
    setUnsavedPrompt((current) => {
      if (current !== null) {
        proceedAfterUnsaved(current);
      }
      return null;
    });
  }, [proceedAfterUnsaved]);

  const handleNewDocument = useCallback(() => {
    setDocument(createInitialDocument(preferences.showIntroDemo));
    setViewMode('editor');
    setShowRename(false);
  }, [preferences.showIntroDemo]);

  const requestNewDocument = useCallback(() => {
    promptIfDirty(handleNewDocument);
  }, [handleNewDocument, promptIfDirty]);

  const handlePrint = useCallback(() => {
    void printDocument(document);
  }, [document]);

  const togglePreview = useCallback(() => {
    setViewMode((current) => (current === 'editor' ? 'preview' : 'editor'));
  }, []);

  const toggleFocusMode = useCallback(() => {
    setFocusMode((current) => !current);
    setActivePanel(null);
    setShowRename(false);
    setShowAgent(false);

    void platform.toggleFullscreen().catch(() => {
      // Fullscreen may be unavailable in some shells; chrome hiding still applies.
    });
  }, [platform]);

  const bumpFontSize = useCallback(
    (direction: 'increase' | 'decrease') => {
      applyPreferences(
        direction === 'increase'
          ? increaseFontSize(preferences)
          : decreaseFontSize(preferences),
      );
    },
    [applyPreferences, preferences],
  );

  const openRename = useCallback(() => {
    if (document.filePath === null) {
      return;
    }
    setShowRename(true);
  }, [document.filePath]);

  const confirmRename = useCallback(
    (newName: string) => {
      void renameDocument(document, newName).then((renamed) => {
        if (renamed !== null) {
          setDocument(renamed);
        }
        setShowRename(false);
      });
    },
    [document],
  );

  const toggleAgent = useCallback(() => {
    setShowAgent((current) => !current);
  }, []);

  const openHelp = useCallback((tab: 'shortcuts' | 'formatting' = 'shortcuts') => {
    setHelpInitialTab(tab);
    setActivePanel('help');
  }, []);

  const openPreferences = useCallback(() => {
    setActivePanel('preferences');
  }, []);

  const openFormattingPalette = useCallback(() => {
    if (viewMode !== 'editor') {
      setViewMode('editor');
    }
    setShowFormattingPalette(true);
  }, [viewMode]);

  const closeFormattingPalette = useCallback(() => {
    setShowFormattingPalette(false);
    window.requestAnimationFrame(() => {
      editorRef.current?.focusEditor();
    });
  }, []);

  const handleFormattingSnippet = useCallback((snippet: MarkdownSnippet) => {
    editorRef.current?.insertSnippet(snippet);
    setShowFormattingPalette(false);
    window.requestAnimationFrame(() => {
      editorRef.current?.focusEditor();
    });
  }, []);

  const dismissPanel = useCallback(() => {
    setActivePanel(null);
    setShowRename(false);
  }, []);

  const handlePreferencesChange = useCallback(
    (next: EditorPreferences) => {
      applyPreferences(next);
    },
    [applyPreferences],
  );

  useEffect(() => {
    if (viewMode !== 'editor') {
      return;
    }
    const frame = window.requestAnimationFrame(() => {
      editorRef.current?.focusEditor();
    });
    return (): void => {
      window.cancelAnimationFrame(frame);
    };
  }, [document.id, viewMode]);

  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent): void => {
      const mod = event.metaKey || event.ctrlKey;

      if (event.key === 'Escape') {
        if (showFormattingPalette) {
          event.preventDefault();
          closeFormattingPalette();
          return;
        }
        if (unsavedPrompt !== null) {
          event.preventDefault();
          dismissUnsavedPrompt();
          return;
        }
        if (showRename) {
          event.preventDefault();
          setShowRename(false);
          return;
        }
        if (activePanel !== null) {
          event.preventDefault();
          dismissPanel();
          return;
        }
        if (focusMode) {
          event.preventDefault();
          toggleFocusMode();
          return;
        }
        if (showAgent) {
          event.preventDefault();
          setShowAgent(false);
        }
        return;
      }

      if (isIncreaseFontSizeShortcut(event)) {
        if (!platform.supportsNativeMenu) {
          event.preventDefault();
          bumpFontSize('increase');
        }
        return;
      }

      if (isDecreaseFontSizeShortcut(event)) {
        if (!platform.supportsNativeMenu) {
          event.preventDefault();
          bumpFontSize('decrease');
        }
        return;
      }

      if (mod && event.key.toLowerCase() === 'k' && !event.shiftKey && !event.altKey && !event.ctrlKey) {
        if (!platform.supportsNativeMenu) {
          event.preventDefault();
          openFormattingPalette();
        }
        return;
      }

      if (mod && event.key === ',') {
        if (!platform.supportsNativeMenu) {
          event.preventDefault();
          openPreferences();
        }
        return;
      }

      if (mod && event.key.toLowerCase() === 'h' && !event.shiftKey && !event.altKey) {
        if (!platform.supportsNativeMenu) {
          event.preventDefault();
          openHelp();
        }
        return;
      }

      if (mod && event.shiftKey && event.key === '/') {
        event.preventDefault();
        openHelp('formatting');
        return;
      }

      if (mod && event.shiftKey && event.key.toLowerCase() === 's') {
        if (!platform.supportsNativeMenu) {
          event.preventDefault();
          handleSaveAs();
        }
        return;
      }

      if (mod && event.key.toLowerCase() === 's' && !event.shiftKey) {
        if (!platform.supportsNativeMenu) {
          event.preventDefault();
          handleSave();
        }
        return;
      }

      if (mod && event.key.toLowerCase() === 'o' && !event.shiftKey) {
        if (!platform.supportsNativeMenu) {
          event.preventDefault();
          handleOpen();
        }
        return;
      }

      if (mod && event.key.toLowerCase() === 'n' && !event.shiftKey && !event.altKey) {
        if (!platform.supportsNativeMenu) {
          event.preventDefault();
          requestNewDocument();
        }
        return;
      }

      if (mod && event.shiftKey && event.key.toLowerCase() === 'r') {
        if (!platform.supportsNativeMenu) {
          event.preventDefault();
          openRename();
        }
        return;
      }

      if (mod && event.key.toLowerCase() === 'p' && !event.shiftKey && !event.altKey) {
        if (!platform.supportsNativeMenu) {
          event.preventDefault();
          handlePrint();
        }
        return;
      }

      if (mod && event.altKey && event.key.toLowerCase() === 'p') {
        if (!platform.supportsNativeMenu) {
          event.preventDefault();
          togglePreview();
        }
        return;
      }

      if (mod && event.ctrlKey && event.key.toLowerCase() === 'f') {
        if (!platform.supportsNativeMenu) {
          event.preventDefault();
          toggleFocusMode();
        }
        return;
      }

      if (mod && event.key === '/' && !event.shiftKey) {
        if (!platform.supportsNativeMenu) {
          event.preventDefault();
          toggleAgent();
        }
      }
    };

    window.addEventListener('keydown', onKeyDown);
    return (): void => {
      window.removeEventListener('keydown', onKeyDown);
    };
  }, [
    activePanel,
    bumpFontSize,
    closeFormattingPalette,
    dismissPanel,
    dismissUnsavedPrompt,
    focusMode,
    openFormattingPalette,
    requestNewDocument,
    handleOpen,
    handlePrint,
    handleSave,
    handleSaveAs,
    openHelp,
    openPreferences,
    openRename,
    showAgent,
    showFormattingPalette,
    showRename,
    toggleAgent,
    toggleFocusMode,
    togglePreview,
    unsavedPrompt,
    platform,
  ]);

  useEffect(() => {
    return platform.onMenuAction((action) => {
      if (action === 'new') {
        requestNewDocument();
      }
      if (action === 'open') {
        handleOpen();
      }
      if (action === 'save') {
        handleSave();
      }
      if (action === 'save-as') {
        handleSaveAs();
      }
      if (action === 'rename') {
        openRename();
      }
      if (action === 'print') {
        handlePrint();
      }
      if (action === 'toggle-preview') {
        togglePreview();
      }
      if (action === 'toggle-focus-mode') {
        toggleFocusMode();
      }
      if (action === 'increase-font-size') {
        bumpFontSize('increase');
      }
      if (action === 'decrease-font-size') {
        bumpFontSize('decrease');
      }
      if (action === 'open-formatting-palette') {
        openFormattingPalette();
      }
      if (action === 'toggle-agent') {
        toggleAgent();
      }
      if (action === 'open-help') {
        openHelp();
      }
      if (action === 'open-preferences') {
        openPreferences();
      }
    });
  }, [
    bumpFontSize,
    requestNewDocument,
    handleOpen,
    handlePrint,
    handleSave,
    handleSaveAs,
    openHelp,
    openFormattingPalette,
    openPreferences,
    openRename,
    toggleAgent,
    toggleFocusMode,
    togglePreview,
    platform,
  ]);

  useEffect(() => {
    if (platform.kind === 'web') {
      if (!document.isDirty) {
        return undefined;
      }
      const listener = (event: BeforeUnloadEvent): void => {
        event.preventDefault();
      };
      window.addEventListener('beforeunload', listener);
      return (): void => {
        window.removeEventListener('beforeunload', listener);
      };
    }
    return platform.onCloseRequested(() => {
      handleCloseWindow();
    });
  }, [document.isDirty, handleCloseWindow, platform]);

  return (
    <div
      className={chromeHidden ? 'app-shell focus-mode' : 'app-shell'}
      style={{ backgroundColor: CLASSIC_DARK.background }}
    >
      {chromeHidden ? null : (
        <>
          {!platform.supportsNativeMenu ? (
            <WebToolbar
              onNew={requestNewDocument}
              onOpen={handleOpen}
              onSave={handleSave}
              onSaveAs={handleSaveAs}
              onTogglePreview={togglePreview}
              onToggleAgent={toggleAgent}
              onOpenHelp={() => {
                openHelp();
              }}
              onOpenPreferences={openPreferences}
            />
          ) : null}
          <div className="titlebar-drag">
            <span className="titlebar-title">{windowTitle}</span>
          </div>
        </>
      )}

      <main className="editor-main">
        {viewMode === 'editor' ? (
          <MarkdownEditorFeature
            ref={editorRef}
            key={`${document.id}-${String(preferences.fontSizePx)}-${preferences.textWidth}`}
            content={document.content}
            layout={editorLayout}
            onChange={handleContentChange}
            onCursorChange={setCursor}
          />
        ) : (
          <MarkdownPreviewFeature content={document.content} title={document.title} />
        )}
      </main>

      {showAgent && !chromeHidden ? (
        <AgentTerminalFeature
          content={document.content}
          onSave={handleSave}
          onTogglePreview={togglePreview}
          onOpenSettings={openPreferences}
          onClose={toggleAgent}
        />
      ) : null}

      {preferences.showStatusBar && !chromeHidden ? (
        <StatusBar document={document} cursor={cursor} />
      ) : null}

      {activePanel === 'help' && !chromeHidden ? (
        <EditorOverlayContainer title="Help" onDismiss={dismissPanel} fixedSize>
          <HelpOverlayView key={helpInitialTab} initialTab={helpInitialTab} />
        </EditorOverlayContainer>
      ) : null}

      {activePanel === 'preferences' && !chromeHidden ? (
        <EditorOverlayContainer title="Preferences" onDismiss={dismissPanel}>
          <PreferencesOverlayView preferences={preferences} onChange={handlePreferencesChange} />
        </EditorOverlayContainer>
      ) : null}

      {showRename && !chromeHidden ? (
        <EditorOverlayContainer title="Rename Document" onDismiss={dismissPanel}>
          <RenameOverlayView
            currentName={document.title}
            onConfirm={confirmRename}
            onCancel={() => {
              setShowRename(false);
            }}
          />
        </EditorOverlayContainer>
      ) : null}

      {showFormattingPalette && viewMode === 'editor' ? (
        <div className="editor-overlay-backdrop" onClick={closeFormattingPalette}>
          <div
            className="formatting-palette-panel"
            onClick={(event) => {
              event.stopPropagation();
            }}
            role="dialog"
            aria-modal="true"
            aria-label="Formatting palette"
          >
            <FormattingPaletteOverlayView
              onSelect={handleFormattingSnippet}
              onDismiss={closeFormattingPalette}
            />
          </div>
        </div>
      ) : null}

      {unsavedPrompt !== null && !chromeHidden ? (
        <EditorOverlayContainer title="Save Changes?" onDismiss={dismissUnsavedPrompt}>
          <UnsavedChangesOverlayView
            documentTitle={document.title}
            onSave={handleUnsavedSave}
            onDiscard={handleUnsavedDiscard}
            onCancel={dismissUnsavedPrompt}
          />
        </EditorOverlayContainer>
      ) : null}
    </div>
  );
}
