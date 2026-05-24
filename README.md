# 📦 Ecommify - Análisis y Arquitectura Híbrida de E-commerce

## 📋 Descripción General

**Ecommify** es un proyecto integral de análisis arquitectónico y técnico basado en el dataset público de E-commerce de Olist. El proyecto implementa una **arquitectura híbrida transaccional-analítica** que combina:

- **PostgreSQL**: Módulo transaccional con integridad referencial y procesamiento ACID
- **MongoDB**: Módulo analítico con documentos desnormalizados optimizados para lectura

Este enfoque equilibra consistencia operativa, escalabilidad analítica, flexibilidad de esquema y optimización de consultas para casos de uso de e-commerce en tiempo real.

## 🎯 Objetivos del Proyecto

1. **Análisis Exploratorio de Datos (EDA)**: Comprender la estructura, volumen, calidad y patrones del dataset
2. **Arquitectura Híbrida**: Diseñar una solución que optimice tanto transacciones como análisis
3. **Criterios Técnicos**: Aplicar principios de CAP, normalización y patrones de acceso a la decisión arquitectónica
4. **Implementación**: Proveer esquemas DDL, scripts de bootstrap y notebooks ejecutables
5. **Documentación**: Consolidar análisis, decisiones y guías de implementación

## 📊 Dataset y Contexto

El proyecto utiliza el **dataset de E-commerce Olist**, público y ampliamente utilizado en análisis de datos:

| Entidad | Registros | Descripción |
|---------|-----------|-------------|
| **customers** | 99,441 | Información de clientes y ubicación |
| **orders** | 99,441 | Transacciones principales y ciclo de vida |
| **order_items** | 112,650 | Detalle de productos en cada orden |
| **order_payments** | 103,886 | Métodos de pago y montos |
| **order_reviews** | 99,224 | Reseñas y calificaciones |
| **products** | 32,951 | Catálogo de productos |
| **sellers** | 3,095 | Información de vendedores |
| **geolocation** | 1,000,163 | Datos geográficos por código postal |

**Total de registros**: 1,550,922 | **Uso de memoria**: 341.25 MB

## 🏗️ Arquitectura

### Decisión de Particionamiento

La arquitectura híbrida distribuye módulos basada en:

- **Teorema CAP**: Prioridad de Consistencia (C) para operaciones financieras, Disponibilidad (A) para análisis
- **Nivel de estructuración**: Datos normalizados en PostgreSQL, semi-estructurados en MongoDB
- **Patrón de acceso**: Transaccional vs. Analítico
- **Costo operativo**: Sincronización incremental asincrónica

### PostgreSQL - Módulo Transaccional

**Responsabilidades**:
- Gestión de clientes y órdenes (fuente canónica)
- Procesamiento de pagos con ACID
- Gestión de vendedores
- Referencia geográfica maestra
- Integridad referencial y consistencia

**Características**:
- Esquema normalizado en 3FN
- Particionamiento por rango en tablas de alto volumen
- Índices estratégicos para optimización de consultas
- Extensiones: `uuid-ossp`, `pg_trgm`, `pgcrypto`

### MongoDB - Módulo Analítico

**Responsabilidades**:
- Catálogo de productos enriquecido
- Órdenes desnormalizadas para lectura rápida
- Analítica de reseñas
- KPI y métricas por categoría

**Características**:
- Documentos desnormalizados con consistencia eventual
- Carga incremental desde PostgreSQL
- Optimizado para agregaciones y exploración
- Proyecciones y vistas analíticas

## 📁 Estructura del Proyecto

```
Ecommify/
├── README.md                                  # Este archivo
├── scripts/                                   # Scripts de inicialización
│   ├── 00_postgresql_ddl_final.sql           # Definición completa de tablas y relaciones
│   ├── 01_postgresql_schema.sql              # Esquema base y tablas
│   ├── 02_postgresql_indexes.sql             # Índices y optimización
│   ├── 03_postgresql_partitioning_notes.sql  # Estrategia de particionamiento
│   └── 04_mongodb_bootstrap.js               # Inicialización de colecciones MongoDB
├── notebooks/                                 # Análisis interactivos
│   ├── Exploracion.ipynb                     # EDA inicial y exploración
│   └── analisis_datos_avanzados.ipynb        # Análisis avanzado y visualizaciones
├── analisis/                                  # Documentación y análisis
│   ├── Analisis_EDA.md                       # Análisis exploratorio completo
│   ├── criterio_tecnico.md                   # Criterio de decisión arquitectónica
│   ├── documento_arquitectura_hibrida_eda_olist.md  # Arquitectura detallada
│   ├── analisis_formas_normales.md           # Normalización y formas normales
│   └── Extensiones_PostgreSQL_Ecommify.md    # Extensiones utilizadas
├── esquemas/                                  # Esquemas visuales
│   ├── Diagrama ER.png                       # Diagrama entidad - relación
│   ├── Diagrama Logico Relacional.png         # Diagrama Logico Relacional
│   ├── Diagrama_Arq_Hibrida.png               # Detalle de diagrama de arquitectura
│   ├── Esquema normalizado.png                # Esquema normalizado 
└── datos/                                     # Archivos CSV del dataset
    ├── olist_customers_dataset.csv
    ├── olist_orders_dataset.csv
    ├── olist_order_items_dataset.csv
    ├── olist_order_payments_dataset.csv
    ├── olist_order_reviews_dataset.csv
    ├── olist_products_dataset.csv
    ├── olist_sellers_dataset.csv
    ├── olist_geolocation_dataset.csv
    └── product_category_name_translation.csv
```

## 🚀 Inicio Rápido

### Requisitos Previos

- **Python** 3.11 o superior
- **PostgreSQL** 13 o superior
- **MongoDB** 4.0 o superior
- **pip** (gestor de paquetes de Python)
- **Git** (para control de versiones)

### Instalación

#### 1. Clonar el Repositorio

```bash
git clone <repository-url>
cd Ecommify
```

#### 2. Configurar Entorno Virtual de Python

```bash
# Windows (PowerShell)
python -m venv .venv
.\.venv\Scripts\Activate.ps1

# Linux/macOS
python -m venv .venv
source .venv/bin/activate
```

#### 3. Instalar Dependencias

```bash
pip install -r requirements.txt
```

*Dependencias principales*:
- `pandas` - Manipulación de datos
- `numpy` - Computación numérica
- `jupyterlab` - Notebooks interactivos
- `psycopg2-binary` - Driver PostgreSQL
- `pymongo` - Driver MongoDB
- `matplotlib`, `seaborn` - Visualización
- `sqlalchemy` - ORM

### Ejecutar Notebooks

```bash
# Iniciar Jupyter Lab
jupyter lab

# O usar Jupyter Notebook
jupyter notebook

# Abrir: http://localhost:8888
```

## 📚 Documentación

### Análisis y Decisiones Arquitectónicas

- **[Análisis EDA](analisis/Analisis_EDA.md)**: Exploración exhaustiva de estructura, volumen y calidad
- **[Criterio Técnico](analisis/criterio_tecnico.md)**: Marco de decisión basado en CAP, normalización y patrones
- **[Arquitectura Híbrida](analisis/documento_arquitectura_hibrida_eda_olist.md)**: Diseño completo del sistema
- **[Formas Normales](analisis/analisis_formas_normales.md)**: Análisis de normalización en PostgreSQL
- **[Extensiones PostgreSQL](analisis/Extensiones_PostgreSQL_Ecommify.md)**: Extensiones utilizadas y configuración

### Notebooks Interactivos

- **[Exploración](notebooks/Exploracion.ipynb)**: EDA inicial, visualizaciones y patrones
- **[Análisis Avanzado](notebooks/analisis_datos_avanzados.ipynb)**: Análisis profundo y derivación de métricas

## 🔍 Características Principales

### Análisis Exploratorio
- ✅ Exploración de 1.5 millones de registros
- ✅ Análisis de calidad: nulos, duplicados, cardinalidad
- ✅ Distribución univariada y bivariada
- ✅ Correlaciones y patrones temporales

### Arquitectura Transaccional-Analítica
- ✅ Separación clara de responsabilidades
- ✅ PostgreSQL como fuente canónica
- ✅ MongoDB como capa analítica desnormalizada
- ✅ Sincronización incremental asincrónica

### Optimización
- ✅ Particionamiento por rango en tablas grandes
- ✅ Índices estratégicos (B-tree, BRIN, GiST)
- ✅ Extensiones PostgreSQL avanzadas
- ✅ Proyecciones desnormalizadas en MongoDB

### Documentación Completa
- ✅ Criterios técnicos explícitos
- ✅ Decisiones arquitectónicas justificadas
- ✅ Guías de implementación
- ✅ Análisis de normalización

## 📊 Casos de Uso Soportados

### Transaccional (PostgreSQL)
- Procesamiento de nuevas órdenes
- Gestión de clientes y vendedores
- Procesamiento de pagos
- Auditoría y trazabilidad

### Analítico (MongoDB)
- Dashboards de ventas por categoría
- Análisis de satisfacción (reseñas)
- Exploración del catálogo de productos
- Métricas por región geográfica
- Tendencias de precios y demanda

## 🔐 Seguridad y Consideraciones

- Usar credenciales seguras en configuración
- Configurar firewalls para PostgreSQL y MongoDB
- Implementar backups regularmente
- Validar datos en el punto de entrada
- Usar transacciones ACID para operaciones críticas

## 🤝 Contribuciones

Este proyecto es un trabajo académico desarrollado como parte de estudios de Diseño y optimización en bases de atos. Las contribuciones pueden incluir:

- Mejoras en análisis y visualizaciones
- Optimizaciones de esquema
- Scripts de sincronización
- Documentación adicional
- Casos de uso específicos


## 👨‍💼 Autor

Desarrollado como proyecto de investigación en **Diseño y optimización en bases de atos** - Maestría Arquitectura de software.

---


