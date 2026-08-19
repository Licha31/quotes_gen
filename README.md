# Presupuestador Adrytentaciones

Aplicación web para crear presupuestos de Adrytentaciones de forma rápida y
clara.

## Requisitos

- Python 3.12 o superior.
- [uv](https://docs.astral.sh/uv/).

## Preparar el proyecto

```powershell
uv sync
```

## Ejecutar la aplicación

```powershell
uv run uvicorn app.main:app --reload
```

La pantalla de nuevo presupuesto queda disponible en
`http://127.0.0.1:8000/quotes/new`.

## Verificar el proyecto

```powershell
uv run pytest
uv run ruff check .
uv run ruff format --check .
```

Para aplicar el formato automáticamente:

```powershell
uv run ruff format .
```
