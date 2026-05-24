# Extensiones PostgreSQL para Ecommify

## 1. Objetivo

Este documento consolida la decisión técnica sobre la aplicabilidad de extensiones de PostgreSQL en Ecommify, considerando el dataset Olist, el modelo híbrido PostgreSQL + MongoDB y los patrones de acceso identificados en la exploración de datos.

Las extensiones evaluadas son:

- PostGIS
- pg_trgm
- hstore
- pgcrypto

## 2. Criterio de evaluación

Cada extensión se evalúa con base en:

- alineación con casos de uso reales del dominio
- valor funcional sobre el modelo actual
- complejidad operativa y compatibilidad de despliegue
- beneficio esperado frente a alternativas nativas o ya adoptadas

## 3. Análisis de aplicabilidad por extensión

| Extensión | Caso de uso en Ecommify | Aplicabilidad | Decisión preliminar |
|---|---|---|---|
| PostGIS | Cálculo de distancia vendedor-cliente, optimización logística y análisis geográfico | Alta | Adoptar |
| pg_trgm | Búsqueda tolerante a errores tipográficos en productos y categorías | Alta | Adoptar |
| hstore | Atributos variables ligeros en formato clave-valor | Media-Baja | No priorizar |
| pgcrypto | Hash, seudonimización y protección de identificadores sensibles | Media | Adoptar condicionalmente |

## 4. Evaluación detallada

### 4.1 PostGIS

**Caso de uso principal**

Optimización de costos de envío basados en distancia entre vendedor y cliente.

**Justificación**

Ecommify dispone de información geográfica derivable a partir de prefijos postales y una tabla depurada de geolocalización. PostGIS permite:

- calcular distancias reales con tipos geográficos
- crear consultas de proximidad y cobertura
- optimizar análisis logísticos por región
- enriquecer métricas de entrega y fulfillment

**Ejemplo de valor técnico**

- estimar un costo de envío en función de kilómetros entre seller y customer
- detectar zonas con mayor concentración de órdenes
- comparar tiempo de entrega vs distancia real

**Decisión**

**Adoptar**. Es la extensión con mayor impacto funcional para el caso logístico y geográfico del proyecto.

### 4.2 pg_trgm

**Caso de uso principal**

Búsqueda de productos tolerante a errores tipográficos.

**Justificación**

Los nombres de categorías y atributos de producto pueden beneficiarse de similitud textual cuando el usuario:

- escribe con errores ortográficos
- usa variantes lingüísticas
- omite acentos o espacios
- consulta categorías similares sin conocer el texto exacto

**Ejemplo de valor técnico**

- buscar `beleza e saude` y recuperar `beleza_saude`
- ranking de coincidencias aproximadas en catálogo
- soporte a autocompletado y fuzzy matching

**Decisión**

**Adoptar**. Tiene alto valor para catálogo, buscador y experiencia de usuario con bajo costo de implementación.

### 4.3 hstore

**Caso de uso principal**

Almacenamiento ligero de pares clave-valor para atributos variables.

**Justificación**

Aunque hstore puede ser útil en estructuras planas, Ecommify requiere con más frecuencia:

- jerarquía de atributos
- anidación de documentos
- flexibilidad de consulta sobre estructuras complejas

En ese contexto, JSONB ofrece mejores operadores, mayor expresividad y mejor alineación con el modelado de `product_specifications`.

**Decisión**

**No priorizar**. JSONB cubre mejor las necesidades del proyecto. hstore solo sería razonable en casos muy acotados de key-value simple y plano.

### 4.4 pgcrypto

**Caso de uso principal**

Protección de identificadores sensibles y seudonimización para analítica o publicación de datos.

**Justificación**

Aunque el dataset Olist no expone información financiera completa, sí existen identificadores que podrían requerir protección en escenarios como:

- publicación académica del proyecto
- exposición de vistas analíticas compartidas
- integración con capas externas de reporting

pgcrypto permite:

- hash de identificadores
- generación de tokens
- mecanismos básicos de protección criptográfica a nivel SQL

**Decisión**

**Adoptar condicionalmente**. No es crítico para el núcleo actual, pero sí recomendable si se comparten datos o se incorporan capas con requisitos de privacidad.

## 5. Decisión final

| Extensión | Decisión final | Prioridad | Motivo principal |
|---|---|---|---|
| PostGIS | Sí | Alta | Aporta valor directo a logística, distancia seller-customer y análisis espacial |
| pg_trgm | Sí | Alta | Mejora búsqueda tolerante a errores en productos y categorías |
| hstore | No por ahora | Baja | JSONB cubre mejor los casos semi-estructurados del proyecto |
| pgcrypto | Condicional | Media | Útil si se requiere seudonimización o protección de identificadores |

## 6. Recomendación ejecutiva

La ruta recomendada para Ecommify es:

1. incorporar **PostGIS** para analítica geográfica y optimización de costos de envío;
2. incorporar **pg_trgm** para búsquedas aproximadas sobre catálogo;
3. mantener **JSONB** como primera opción frente a **hstore** para atributos semi-estructurados;
4. reservar **pgcrypto** para escenarios con requerimientos explícitos de privacidad o exposición externa.

Con esta selección, PostgreSQL amplía sus capacidades sin degradar el diseño relacional base y fortalece la viabilidad de una arquitectura híbrida con soporte operacional y analítico.