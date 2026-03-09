# SISTEMA EDUCATIVO RUBEN - Backend CEA

Este es el backend profesional desarrollado en Python (Flask) para el sistema académico CEA Bolivia.

## Requisitos
- Python 3.11+
- MySQL Server

## Instalación
1. Clonar el repositorio.
2. Instalar dependencias: `pip install -r requirements.txt`.
3. Configurar variables de entorno (DB_HOST, DB_USER, etc.).
4. Ejecutar: `python app.py`.

## Despliegue en Render
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `gunicorn app:app`
