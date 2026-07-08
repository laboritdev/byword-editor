# LabWord (Turborepo)

.PHONY: help install dev dev-desktop dev-web test lint build typecheck

.DEFAULT_GOAL := help

help:
	@echo "LabWord monorepo (Turbo + pnpm)"
	@echo ""
	@echo "  make install       pnpm install"
	@echo "  make dev           dev all apps"
	@echo "  make dev-desktop   Electron app"
	@echo "  make dev-web       Web SPA"
	@echo "  make test          turbo test"
	@echo "  make typecheck     turbo typecheck"
	@echo "  make lint          turbo lint"
	@echo "  make build         turbo build"

install:
	pnpm install

dev:
	pnpm dev

dev-desktop:
	pnpm dev:desktop

dev-web:
	pnpm dev:web

test:
	pnpm test

typecheck:
	pnpm typecheck

lint:
	pnpm lint

build:
	pnpm build
