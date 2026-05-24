# Documento de Planeación Arquitectónica y Analítica
## Dataset E-commerce Olist / Ecommify

---

# 1. Introducción

Este documento presenta el análisis arquitectónico, técnico y estratégico basado en el EDA realizado sobre el dataset público de E-commerce de Olist/Ecommify. El enfoque adoptado corresponde a una arquitectura híbrida Transaccional-Analítica utilizando PostgreSQL para el módulo transaccional y MongoDB para el módulo analítico.

La propuesta busca equilibrar:

- Integridad referencial y consistencia transaccional
- Escalabilidad analítica
- Flexibilidad de esquema
- Optimización de consultas
- Rendimiento de lectura y escritura

La arquitectura se diseña considerando limitaciones reales de plataformas gratuitas y patrones de acceso identificados durante el EDA.

---

# 2. Enfoque Arquitectónico Seleccionado

## Arquitectura Transaccional-Analítica

### PostgreSQL – Módulo Transaccional

Se utilizará PostgreSQL para:

- Gestión de órdenes
- Gestión de clientes
- Pagos
- Vendedores
- Relaciones críticas
- Integridad referencial
- Procesamiento ACID

### MongoDB – Módulo Analítico

Se utilizará MongoDB para:

- Catálogo enriquecido de productos
- Documentos desnormalizados de órdenes
- Análisis de reseñas
- Consultas analíticas rápidas
- Agregaciones orientadas a lectura

---

# 3. Revisión del Diccionario Oficial de Datos

## 3.1 Entidades Identificadas

| Entidad | Registros | Propósito Principal |
|---|---:|---|
| customers | 99,441 | Información de clientes |
| orders | 99,441 | Transacciones principales |
| order_items | 112,650 | Detalle de productos vendidos |
| order_payments | 103,886 | Información de pagos |
| order_reviews | 99,224 | Reseñas y satisfacción |
| products | 32,951 | Catálogo de productos |
| sellers | 3,095 | Información de vendedores |
| geolocation | 1,000,163 | Datos geográficos |
| category_translation | 71 | Traducción de categorías |

---

## 3.2 Entidades Principales y Relaciones

### Customers

Entidad encargada del almacenamiento de clientes.

#### Llave primaria
- customer_id

#### Relaciones
- 1:N con orders

#### Datos relevantes
- Estado
- Ciudad
- Código postal

---

### Orders

Entidad central del sistema transaccional.

#### Llave primaria
- order_id

#### Relaciones
- N:1 con customers
- 1:N con order_items
- 1:N con order_payments
- 1:1 con order_reviews

#### Datos relevantes
- Estado de orden
- Fechas de compra
- Fechas de entrega
- Estado logístico

---

### Order Items

Representa el detalle de productos comprados por orden.

#### Relaciones
- N:1 con orders
- N:1 con products
- N:1 con sellers

#### Datos relevantes
- Precio
- Valor de envío
- Producto
- Vendedor

---

### Order Payments

Representa métodos y valores de pago.

#### Relaciones
- N:1 con orders

#### Datos relevantes
- Tipo de pago
- Número de cuotas
- Valor pagado

---

### Order Reviews

Contiene información de satisfacción del cliente.

#### Relaciones
- 1:1 con orders

#### Datos relevantes
- Calificación
- Comentarios
- Fechas de reseña

---

### Products

Catálogo de productos y atributos físicos.

#### Relaciones
- 1:N con order_items
- N:1 con category_translation

#### Datos relevantes
- Categoría
- Peso
- Dimensiones
- Fotografías

---

### Sellers

Información de vendedores.

#### Relaciones
- 1:N con order_items

#### Datos relevantes
- Estado
- Ciudad
- Código postal

---

# 4. Modelo Arquitectónico Propuesto

## 4.1 Distribución PostgreSQL

| Entidad | Justificación |
|---|---|
| customers | Integridad referencial |
| orders | Transacciones ACID |
| order_payments | Consistencia financiera |
| sellers | Relación transaccional |
| geolocation | Relación estructurada |

### Justificación Técnica

- Requiere consistencia fuerte
- Uso intensivo de JOINs
- Relaciones complejas
- Procesamiento transaccional crítico
- Necesidad de auditoría y trazabilidad

---

## 4.2 Distribución MongoDB

| Colección | Justificación |
|---|---|
| products | Alta lectura y flexibilidad |
| orders_denormalized | Consultas analíticas rápidas |
| reviews_analytics | Agregaciones y métricas |
| category_metrics | KPIs por categoría |

### Justificación Técnica

- Consultas orientadas a lectura
- Desnormalización beneficiosa
- Agregaciones rápidas
- Escalabilidad horizontal
- Flexibilidad documental

---

# 5. Preguntas de Investigación

## Pregunta 1

### ¿Qué impacto tiene la desnormalización de órdenes en MongoDB sobre el tiempo de respuesta de consultas analíticas?

### Respuesta

La desnormalización permitirá reducir significativamente la cantidad de operaciones JOIN requeridas en consultas complejas. Debido a que MongoDB almacena documentos agregados, una orden podrá contener:

- Información del cliente
- Items comprados
- Información de pago
- Reseña asociada

Esto reducirá la latencia de lectura y mejorará el rendimiento de dashboards analíticos y consultas históricas.

---

## Pregunta 2

### ¿Por qué PostgreSQL es más adecuado para el manejo de órdenes y pagos?

### Respuesta

Las órdenes y pagos representan entidades críticas de negocio que requieren:

- Atomicidad
- Consistencia
- Aislamiento
- Durabilidad

PostgreSQL garantiza integridad referencial entre:

- Clientes
- Órdenes
- Pagos
- Vendedores

Además, soporta transacciones complejas y rollback seguro ante fallos.

---

## Pregunta 3

### ¿Cómo afecta la alta concentración geográfica de clientes al diseño arquitectónico?

### Respuesta

El análisis mostró que el 66.6% de las órdenes se concentran en tres estados principales:

- SP
- RJ
- MG

Esto permite:

- Optimizar índices geográficos
- Crear particiones regionales
- Implementar estrategias de caché específicas
- Diseñar agregaciones regionales eficientes

---

## Pregunta 4

### ¿Qué beneficios aporta MongoDB al análisis de reseñas y productos?

### Respuesta

MongoDB facilita:

- Agregaciones rápidas por categoría
- Búsqueda flexible de productos
- Análisis de sentimiento
- Consultas sobre atributos variables
- Escalabilidad horizontal

Además, las reseñas pueden embebirse dentro de documentos analíticos para acelerar consultas de experiencia de cliente.

---

## Pregunta 5

### ¿Qué riesgos existen al utilizar una arquitectura híbrida PostgreSQL + MongoDB?

### Respuesta

Los principales riesgos son:

- Duplicidad de datos
- Complejidad de sincronización
- Incremento de mantenimiento
- Posibles inconsistencias entre motores
- Mayor complejidad operativa

Para mitigarlos se propone:

- ETL incremental
- Replicación controlada
- Identificadores globales consistentes
- Validaciones periódicas
- Monitoreo automatizado

---

# 6. Métricas de Éxito Cuantificables

| Métrica | Objetivo |
|---|---|
| Tiempo promedio de consulta transaccional | < 100 ms |
| Tiempo promedio de agregación analítica | < 2 segundos |
| Disponibilidad del sistema | > 99% |
| Soporte concurrente de órdenes | 100,000 órdenes |
| Tiempo de sincronización ETL | < 5 minutos |
| Integridad referencial validada | 100% |
| Precisión de migración de datos | > 99.9% |
| Tiempo de respuesta dashboard analítico | < 3 segundos |

---

# 7. Limitaciones Técnicas de Plataformas Gratuitas

# 7.1 Supabase

## Ventajas

- PostgreSQL administrado
- API REST automática
- Autenticación integrada
- Storage incluido
- Dashboard administrativo

## Limitaciones

| Restricción | Detalle |
|---|---|
| Base de datos | Recursos limitados |
| CPU y RAM | Compartidos |
| Escalabilidad | Limitada en plan gratuito |
| Conexiones concurrentes | Reducidas |
| Backups avanzados | No disponibles |
| Replicación | No disponible |
| Alta disponibilidad | Limitada |

## Riesgos Técnicos

- Degradación bajo alta concurrencia
- Limitación en cargas analíticas pesadas
- Restricción para pruebas de escalabilidad real

---

# 7.2 MongoDB Atlas M0

## Ventajas

- MongoDB administrado
- Fácil despliegue
- Integración cloud
- Monitoreo básico

## Limitaciones

| Restricción | Detalle |
|---|---|
| Almacenamiento | 512 MB |
| RAM compartida | Sí |
| Sin autoscaling | Sí |
| Sin backups continuos | Sí |
| Throughput limitado | Sí |
| Sin sharding | Sí |
| Conexiones limitadas | Sí |

## Riesgos Técnicos

- Saturación rápida del almacenamiento
- Rendimiento inconsistente
- Restricciones de escalabilidad horizontal
- Limitaciones para pruebas masivas

---

# 7.3 Google Colab

## Ventajas

- Ejecución gratuita de notebooks
- Integración Python
- Librerías de Data Science
- GPU temporal

## Limitaciones

| Restricción | Detalle |
|---|---|
| Sesiones temporales | Sí |
| Tiempo máximo de ejecución | Limitado |
| Persistencia | No garantizada |
| Recursos variables | Sí |
| Dependencia de internet | Alta |
| Procesamiento distribuido | Limitado |

## Riesgos Técnicos

- Pérdida de sesiones
- Reinicio inesperado
- Inestabilidad en procesos largos
- Limitaciones para pipelines continuos

---

# 8. Estrategia de Integración PostgreSQL + MongoDB

## Flujo Arquitectónico

1. PostgreSQL almacena transacciones oficiales
2. ETL incremental extrae cambios
3. MongoDB recibe documentos desnormalizados
4. Dashboards y analítica consultan MongoDB
5. PostgreSQL mantiene consistencia oficial

---

## Estrategia ETL

### Extracción

- Lectura incremental por timestamp
- Identificación de cambios
- Validación de integridad

### Transformación

- Desnormalización
- Embebimiento de documentos
- Agregaciones analíticas

### Carga

- Inserción batch en MongoDB
- Actualización incremental
- Validación posterior a carga

---

# 9. Recomendaciones de Indexación

## PostgreSQL

### Índices críticos

```sql
CREATE INDEX idx_orders_customer_id
ON orders(customer_id);

CREATE INDEX idx_orders_status
ON orders(order_status);

CREATE INDEX idx_orders_purchase_date
ON orders(order_purchase_timestamp);

CREATE INDEX idx_order_items_product_id
ON order_items(product_id);
```

---

## MongoDB

### Índices críticos

```javascript
db.orders_denormalized.createIndex({ order_id: 1 })
db.orders_denormalized.createIndex({ customer_id: 1 })
db.orders_denormalized.createIndex({ "items.product_id": 1 })
db.products.createIndex({ product_category_name: 1 })
```

---

# 10. Cronograma de Proyecto – 7 Semanas

## Equipo de Trabajo

| Integrante | Rol |
|---|---|
| Integrante 1 | Arquitecto de Datos |
| Integrante 2 | DBA PostgreSQL |
| Integrante 3 | Ingeniero MongoDB |
| Integrante 4 | Científico de Datos |

---

## Semana 1 – Planeación y Comprensión del Dataset

| Actividad | Responsable |
|---|---|
| Revisión del dataset | Científico de Datos |
| Validación de estructura | Arquitecto de Datos |
| Identificación de entidades | DBA PostgreSQL |
| Preparación de ambiente | Ingeniero MongoDB |
| Definición de objetivos | Todo el equipo |

### Entregables
- Diccionario de datos validado
- Objetivos del proyecto
- Arquitectura preliminar

---

## Semana 2 – Análisis Exploratorio de Datos

| Actividad | Responsable |
|---|---|
| Análisis univariado | Científico de Datos |
| Análisis bivariado | Científico de Datos |
| Evaluación de calidad | DBA PostgreSQL |
| Validación de integridad | Arquitecto de Datos |
| Detección de anomalías | Todo el equipo |

### Entregables
- Informe EDA
- Métricas de calidad
- Hallazgos estadísticos

---

## Semana 3 – Diseño Arquitectónico

| Actividad | Responsable |
|---|---|
| Diseño relacional PostgreSQL | DBA PostgreSQL |
| Diseño documental MongoDB | Ingeniero MongoDB |
| Estrategia híbrida | Arquitecto de Datos |
| Diseño ETL | Científico de Datos |
| Validación técnica | Todo el equipo |

### Entregables
- Modelo relacional
- Modelo documental
- Diseño ETL

---

## Semana 4 – Implementación PostgreSQL

| Actividad | Responsable |
|---|---|
| Creación de tablas | DBA PostgreSQL |
| Creación de índices | DBA PostgreSQL |
| Implementación constraints | DBA PostgreSQL |
| Carga inicial | Arquitecto de Datos |
| Validación ACID | Todo el equipo |

### Entregables
- Base de datos PostgreSQL funcional
- Scripts SQL
- Validación transaccional

---

## Semana 5 – Implementación MongoDB

| Actividad | Responsable |
|---|---|
| Diseño de colecciones | Ingeniero MongoDB |
| Desnormalización | Ingeniero MongoDB |
| Creación de índices | Ingeniero MongoDB |
| Migración analítica | Científico de Datos |
| Validación documental | Todo el equipo |

### Entregables
- Base MongoDB funcional
- Colecciones analíticas
- Índices implementados

---

## Semana 6 – Integración y ETL

| Actividad | Responsable |
|---|---|
| Desarrollo ETL | Científico de Datos |
| Integración PostgreSQL-MongoDB | Arquitecto de Datos |
| Validación de sincronización | Ingeniero MongoDB |
| Optimización consultas | DBA PostgreSQL |
| Monitoreo | Todo el equipo |

### Entregables
- Pipeline ETL
- Integración validada
- Métricas de rendimiento

---

## Semana 7 – Validación Final y Presentación

| Actividad | Responsable |
|---|---|
| Pruebas de rendimiento | Todo el equipo |
| Validación de métricas | Arquitecto de Datos |
| Ajustes finales | DBA PostgreSQL |
| Elaboración de presentación | Científico de Datos |
| Documentación final | Ingeniero MongoDB |

### Entregables
- Informe final
- Presentación ejecutiva
- Resultados de métricas
- Arquitectura validada

---

# 11. Conclusiones

La arquitectura híbrida PostgreSQL + MongoDB resulta adecuada para el dataset Olist/Ecommify debido a:

- Separación clara entre procesamiento transaccional y analítico
- Necesidad de integridad referencial en órdenes y pagos
- Alta eficiencia analítica mediante desnormalización
- Escalabilidad orientada a lectura
- Flexibilidad documental para productos y reseñas

El análisis EDA permitió identificar:

- Alta concentración geográfica
- Patrones de compra relevantes
- Relaciones críticas entre entidades
- Necesidad de optimización híbrida
- Beneficios claros de una estrategia SQL + NoSQL

Finalmente, la solución propuesta permite:

- Mantener consistencia ACID en operaciones críticas
- Mejorar rendimiento analítico
- Escalar horizontalmente consultas de lectura
- Facilitar análisis de comportamiento y negocio
- Implementar pipelines modernos de datos

---

# 12. Referencias Técnicas

- Documentación oficial PostgreSQL
- Documentación MongoDB Atlas
- Supabase Documentation
- Google Colab Documentation
- Kimball Data Warehouse Toolkit
- MongoDB Data Modeling Best Practices
- PostgreSQL Performance Tuning Guide

