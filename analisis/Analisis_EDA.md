# Análisis Exploratorio de Datos (EDA) - Dataset Ecommify/Olist

## Objetivo
Conducir un **EDA exhaustivo** sobre el dataset de E-commerce público de Olist (Ecommify) para:
- Entender la estructura, volumen y relaciones de los datos
- Evaluar la calidad e identificar inconsistencias
- Analizar patrones univariados y bivariados
- Diseñar arquitectura híbrida PostgreSQL + MongoDB
- Generar matriz de decisiones arquitectónicas

## Archivos del Dataset
1. `olist_customers_dataset.csv` - Información de clientes y ubicación
2. `olist_geolocation_dataset.csv` - Coordenadas geográficas por código postal
3. `olist_order_items_dataset.csv` - Detalle de artículos en cada orden
4. `olist_order_payments_dataset.csv` - Métodos de pago y montos
5. `olist_order_reviews_dataset.csv` - Reseñas, calificaciones y comentarios
6. `olist_orders_dataset.csv` - Ciclo de vida de las órdenes y timestamps
7. `olist_products_dataset.csv` - Atributos físicos y categorías de productos
8. `olist_sellers_dataset.csv` - Información de vendedores y ubicación
9. `product_category_name_translation.csv` - Traducción de nombres de categorías
================================================================================
PASO 1: ENTENDIMIENTO ESTRUCTURAL Y RESUMEN DE VOLUMEN
================================================================================
               Tabla  Registros  Columnas  Memoria (MB)
           customers      99441         5     29.621103
         geolocation    1000163         5    145.202189
         order_items     112650         7     39.427454
      order_payments     103886         5     17.814588
       order_reviews      99224         7     42.746946
              orders      99441         8     58.969229
            products      32951         9      6.794703
             sellers       3095         4      0.658910
category_translation         71         2      0.010082

Total de Registros en Todas las Tablas: 1,550,922
Uso Total de Memoria: 341.25 MB
================================================================================
PASO 2 ANÁLISIS DE CALIDAD Y SANIDAD DE LOS DATOS
================================================================================

📊 RESUMEN DE CALIDAD DE DATOS:
               Tabla  Total Nulos % Nulos  Duplicados Valores Únicos (PK Candidate)
           customers            0   0.00%           0                 99441 / 99441
         geolocation            0   0.00%      261831               19015 / 1000163
         order_items            0   0.00%           0                98666 / 112650
      order_payments            0   0.00%           0                99440 / 103886
       order_reviews       145903  21.01%           0                 98410 / 99224
              orders         4908   0.62%           0                 99441 / 99441
            products         2448   0.83%           0                 32951 / 32951
             sellers            0   0.00%           0                   3095 / 3095
category_translation            0   0.00%           0                       71 / 71


📍 PORCENTAJE DE NULOS POR COLUMNA:
--------------------------------------------------------------------------------

CUSTOMERS: ✓ Sin valores nulos

GEOLOCATION: ✓ Sin valores nulos

ORDER_ITEMS: ✓ Sin valores nulos

ORDER_PAYMENTS: ✓ Sin valores nulos

ORDER_REVIEWS:
  • review_comment_title: 88.34%
  • review_comment_message: 58.7%

ORDERS:
  • order_approved_at: 0.16%
  • order_delivered_carrier_date: 1.79%
  • order_delivered_customer_date: 2.98%

PRODUCTS:
  • product_category_name: 1.85%
  • product_name_lenght: 1.85%
  • product_description_lenght: 1.85%
  • product_photos_qty: 1.85%
  • product_weight_g: 0.01%
  • product_length_cm: 0.01%
  • product_height_cm: 0.01%
  • product_width_cm: 0.01%

SELLERS: ✓ Sin valores nulos

CATEGORY_TRANSLATION: ✓ Sin valores nulos

================================================================================
PASO 3: ANÁLISIS UNIVARIADO - MÉTRICAS CLAVE
================================================================================

📈 VARIABLES NUMÉRICAS - ESTADÍSTICAS DESCRIPTIVAS:
--------------------------------------------------------------------------------

ORDER_ITEMS:

  price:
    Media: 120.65
    Mediana: 74.99
    Desv. Est.: 183.63
    Mín: 0.85, Máx: 6735.00
    Outliers detectados: 8427 (7.48%)

  freight_value:
    Media: 19.99
    Mediana: 16.26
    Desv. Est.: 15.81
    Mín: 0.00, Máx: 409.68
    Outliers detectados: 12134 (10.77%)

ORDER_PAYMENTS:

  payment_value:
    Media: 154.10
    Mediana: 100.00
    Desv. Est.: 217.49
    Mín: 0.00, Máx: 13664.08
    Outliers detectados: 7981 (7.68%)

ORDER_REVIEWS:

  review_score:
    Media: 4.09
    Mediana: 5.00
    Desv. Est.: 1.35
    Mín: 1.00, Máx: 5.00
    Outliers detectados: 14575 (14.69%)

PRODUCTS:

  product_weight_g:
    Media: 2276.47
    Mediana: 700.00
    Desv. Est.: 4282.04
    Mín: 0.00, Máx: 40425.00
    Outliers detectados: 4551 (13.81%)

  product_length_cm:
    Media: 30.82
    Mediana: 25.00
    Desv. Est.: 16.91
    Mín: 7.00, Máx: 105.00
    Outliers detectados: 1380 (4.19%)

  product_height_cm:
    Media: 16.94
    Mediana: 13.00
    Desv. Est.: 13.64
    Mín: 2.00, Máx: 105.00
    Outliers detectados: 1892 (5.74%)

  product_width_cm:
    Media: 23.20
    Mediana: 20.00
    Desv. Est.: 12.08
    Mín: 6.00, Máx: 118.00
    Outliers detectados: 912 (2.77%)


🏷️  VARIABLES CATEGÓRICAS - FRECUENCIAS:
--------------------------------------------------------------------------------

ORDERS:

  order_status (Top 10):
    1. delivered: 96,478 (97.0%)
    2. shipped: 1,107 (1.1%)
    3. canceled: 625 (0.6%)
    4. unavailable: 609 (0.6%)
    5. invoiced: 314 (0.3%)
    6. processing: 301 (0.3%)
    7. created: 5 (0.0%)
    8. approved: 2 (0.0%)

ORDER_PAYMENTS:

  payment_type (Top 10):
    1. credit_card: 76,795 (73.9%)
    2. boleto: 19,784 (19.0%)
    3. voucher: 5,775 (5.6%)
    4. debit_card: 1,529 (1.5%)
    5. not_defined: 3 (0.0%)

ORDER_REVIEWS:

  review_score (Top 10):
    1. 5: 57,328 (57.8%)
    2. 4: 19,142 (19.3%)
    3. 1: 11,424 (11.5%)
    4. 3: 8,179 (8.2%)
    5. 2: 3,151 (3.2%)

PRODUCTS:

  product_category_name (Top 10):
    1. cama_mesa_banho: 3,029 (9.2%)
    2. esporte_lazer: 2,867 (8.7%)
    3. moveis_decoracao: 2,657 (8.1%)
    4. beleza_saude: 2,444 (7.4%)
    5. utilidades_domesticas: 2,335 (7.1%)
    6. automotivo: 1,900 (5.8%)
    7. informatica_acessorios: 1,639 (5.0%)
    8. brinquedos: 1,411 (4.3%)
    9. relogios_presentes: 1,329 (4.0%)
    10. telefonia: 1,134 (3.4%)

CUSTOMERS:

  customer_state (Top 10):
    1. SP: 41,746 (42.0%)
    2. RJ: 12,852 (12.9%)
    3. MG: 11,635 (11.7%)
    4. RS: 5,466 (5.5%)
    5. PR: 5,045 (5.1%)
    6. SC: 3,637 (3.7%)
    7. BA: 3,380 (3.4%)
    8. DF: 2,140 (2.2%)
    9. ES: 2,033 (2.0%)
    10. GO: 2,020 (2.0%)

================================================================================
PASO 4: ANÁLISIS BIVARIADO Y MAPEO PARA ARQUITECTURA HÍBRIDA
================================================================================

🔗 RELACIONES IDENTIFICADAS (Llaves Primarias y Foráneas):
--------------------------------------------------------------------------------

CUSTOMERS:
  PK: customer_id
  Descripción: Centro de datos de clientes
  FK: geolocation (customer_zip_code_prefix)

ORDERS:
  PK: order_id
  Descripción: Transacciones principales
  FK: customers (customer_id), order_items (order_id), order_payments (order_id), order_reviews (order_id)

ORDER_ITEMS:
  PK: order_item_id
  Descripción: Detalles de artículos en órdenes
  FK: orders (order_id), products (product_id), sellers (seller_id)

ORDER_PAYMENTS:
  PK: N/A (payment_sequential + order_id)
  Descripción: Métodos y montos de pago
  FK: orders (order_id)

ORDER_REVIEWS:
  PK: review_id
  Descripción: Reseñas y calificaciones
  FK: orders (order_id)

PRODUCTS:
  PK: product_id
  Descripción: Catálogo de productos
  FK: category_translation (product_category_name)

SELLERS:
  PK: seller_id
  Descripción: Información de vendedores
  FK: geolocation (seller_zip_code_prefix)

GEOLOCATION:
  PK: geolocation_zip_code_prefix (non-unique)
  Descripción: Datos geográficos
  FK: Ninguna


📊 PATRONES DE ACCESO Y VOLUMEN:
--------------------------------------------------------------------------------

Verificación de Integridad Referencial:

  • Clientes en órdenes: 99,441 de 99,441 (100.0%)
  • Órdenes con artículos: 98,666 de 99,441
  • Vendedores activos: 3,095 de 3,095 (100.0%)
  • Productos vendidos: 32,951 de 32,951 (100.0%)
  • Órdenes con reseñas: 98,673 de 99,441 (99.2%)

================================================================================
PASO 5: ANÁLISIS TEMPORAL, GEOGRÁFICO Y CICLO DE VIDA
================================================================================

⏱️  ANÁLISIS TEMPORAL:
--------------------------------------------------------------------------------

Rango de fechas de compra:
  Inicio: 2016-09-04 21:15:19
  Fin: 2018-10-17 17:30:18
  Duración: 772 días

Tiempo de Entrega (días):
  Media: 12.1 días
  Mediana: 10.0 días
  Mín-Máx: 0 - 209 días

Retraso de Entrega (vs estimado):
  Media: -11.3 días
  Órdenes retrasadas: 7,308 (7.3%)

Estados de Órdenes:
  • delivered: 96,478 (97.0%)
  • shipped: 1,107 (1.1%)
  • canceled: 625 (0.6%)
  • unavailable: 609 (0.6%)
  • invoiced: 314 (0.3%)
  • processing: 301 (0.3%)
  • created: 5 (0.0%)
  • approved: 2 (0.0%)


🌍 ANÁLISIS GEOGRÁFICO:
--------------------------------------------------------------------------------

Distribución de Clientes por Estado (Top 15):
   1. SP: 41,746 (42.0%)
   2. RJ: 12,852 (12.9%)
   3. MG: 11,635 (11.7%)
   4. RS: 5,466 (5.5%)
   5. PR: 5,045 (5.1%)
   6. SC: 3,637 (3.7%)
   7. BA: 3,380 (3.4%)
   8. DF: 2,140 (2.2%)
   9. ES: 2,033 (2.0%)
  10. GO: 2,020 (2.0%)
  11. PE: 1,652 (1.7%)
  12. CE: 1,336 (1.3%)
  13. PA: 975 (1.0%)
  14. MT: 907 (0.9%)
  15. MA: 747 (0.8%)

Distribución de Órdenes por Estado (Top 15):
   1. SP: 41,746 (42.0%)
   2. RJ: 12,852 (12.9%)
   3. MG: 11,635 (11.7%)
   4. RS: 5,466 (5.5%)
   5. PR: 5,045 (5.1%)
   6. SC: 3,637 (3.7%)
   7. BA: 3,380 (3.4%)
   8. DF: 2,140 (2.2%)
   9. ES: 2,033 (2.0%)
  10. GO: 2,020 (2.0%)
  11. PE: 1,652 (1.7%)
  12. CE: 1,336 (1.3%)
  13. PA: 975 (1.0%)
  14. MT: 907 (0.9%)
  15. MA: 747 (0.8%)

Concentración Geográfica:
  Top 3 estados: 66,233 órdenes (66.6% del total)

Cobertura Geográfica:
  Códigos postales únicos en geolocation: 19,015
  Clientes únicos: 99,441


🔄 CICLO DE VIDA Y ACTIVIDAD:
--------------------------------------------------------------------------------

Ordenes por categoría de producto (Top 15):
   1. cama_mesa_banho: 11,115 items (Precio promedio: R$93.30)
   2. beleza_saude: 9,670 items (Precio promedio: R$130.16)
   3. esporte_lazer: 8,641 items (Precio promedio: R$114.34)
   4. moveis_decoracao: 8,334 items (Precio promedio: R$87.56)
   5. informatica_acessorios: 7,827 items (Precio promedio: R$116.51)
   6. utilidades_domesticas: 6,964 items (Precio promedio: R$90.79)
   7. relogios_presentes: 5,991 items (Precio promedio: R$201.14)
   8. telefonia: 4,545 items (Precio promedio: R$71.21)
   9. ferramentas_jardim: 4,347 items (Precio promedio: R$111.63)
  10. automotivo: 4,235 items (Precio promedio: R$139.96)
  11. brinquedos: 4,117 items (Precio promedio: R$117.55)
  12. cool_stuff: 3,796 items (Precio promedio: R$167.36)
  13. perfumaria: 3,419 items (Precio promedio: R$116.74)
  14. bebes: 3,065 items (Precio promedio: R$134.34)
  15. eletronicos: 2,767 items (Precio promedio: R$57.91)

Métodos de pago más utilizados:
  • credit_card: 76,795 (73.9%)
  • boleto: 19,784 (19.0%)
  • voucher: 5,775 (5.6%)
  • debit_card: 1,529 (1.5%)
  • not_defined: 3 (0.0%)

====================================================================================================
MATRIZ DE DECISIONES ARQUITECTÓNICAS: PostgreSQL vs MongoDB
====================================================================================================

🔵 POSTGRESQL (SQL Relacional)
----------------------------------------------------------------------------------------------------

  📊 Entidades Recomendadas:
     • customers - Clientes (PK: customer_id)
     • orders - Transacciones (PK: order_id) **CRÍTICO**
     • order_payments - Pagos (PK: order_id + payment_sequential) **CRÍTICO**
     • sellers - Vendedores (PK: seller_id)
     • geolocation - Ubicaciones geográficas

  📈 Justificación:
     ✓ ACID transaccional requerido para órdenes y pagos
     ✓ Integridad referencial crítica (clientes → órdenes → pagos)
     ✓ Normalización de datos para evitar redundancia
     ✓ Consultas complejas con JOINs (reportes financieros)
     ✓ Auditoría y trazabilidad de transacciones
     ✓ Alta consistencia requerida

  🔍 Patrones de Acceso Esperados:
     → Lectura-Escritura frecuente (transacciones en tiempo real)
     → Consultas complejas con agregaciones
     → Acceso por FK (customer_id, seller_id, order_id)
     → Reportes analíticos con JOINs múltiples

  ⚠️  Restricciones y Consideraciones:
     Límite de 16MB no aplica. Indexación por customer_id, order_id, order_status

🟢 MONGODB (NoSQL Documento)
----------------------------------------------------------------------------------------------------

  📊 Entidades Recomendadas:
     • products - Catálogo (denormalizado con categorías)
     • order_items - Detalles de compra (embebidos en Order Document)
     • order_reviews - Reseñas (embebidas en Order Document)
     • product_category_translation - Categorías (denormalizadas)

  📈 Justificación:
     ✓ Lecturas rápidas de catálogo (producto + categoría + metadata)
     ✓ Estructura de documento flexible (atributos de producto variables)
     ✓ Desnormalización beneficiosa para queries de lectura intensiva
     ✓ Embebimiento de orden con items y reseñas (queries atómicas)
     ✓ Alto rendimiento para reportes de reseñas y rating por producto
     ✓ Escalabilidad horizontal con sharding por product_id o order_id

  🔍 Patrones de Acceso Esperados:
     → Lectura intensiva (página de producto, catálogo)
     → Agregaciones de datos relacionados (orden + items + reseña)
     → Queries por categoría o atributos de producto
     → Búsqueda por palabras clave en descripción o categoría

  ⚠️  Restricciones y Consideraciones:
     Documento < 16MB. Si una orden con todos sus items + reseña > 16MB, mantener en PostgreSQL


====================================================================================================
RECOMENDACIONES DE ÍNDICES
====================================================================================================

PostgreSQL:
  customers:
    • customer_id (PK)
    • customer_state
    • customer_city
  orders:
    • order_id (PK)
    • customer_id (FK)
    • order_status
    • order_purchase_timestamp
  order_payments:
    • order_id (FK)
    • payment_type
  sellers:
    • seller_id (PK)
    • seller_state
  order_items:
    • order_id (FK)
    • seller_id (FK)
    • product_id (FK)

MongoDB:
  products:
    • product_id (PK)
    • product_category_name
    • product_weight_g
  orders_denormalized:
    • order_id (PK)
    • customer_id
    • order_purchase_timestamp
    • items.product_id

====================================================================================================
✅ ANÁLISIS EDA COMPLETADO
====================================================================================================

========================================================================================================================
DICCIONARIO DE DATOS UNIFICADO
========================================================================================================================

📋 CUSTOMERS
------------------------------------------------------------------------------------------------------------
                 Columna  Tipo    Nulos  Cardinalidad                  Rol
             customer_id   str 0 (0.0%)         99441  PK (Llave Primaria)
      customer_unique_id   str 0 (0.0%)         96096   FK (Llave Foránea)
customer_zip_code_prefix int64 0 (0.0%)         14994 Atributo Descriptivo
           customer_city   str 0 (0.0%)          4119 Atributo Descriptivo
          customer_state   str 0 (0.0%)            27 Atributo Descriptivo

📋 GEOLOCATION
------------------------------------------------------------------------------------------------------------
                    Columna    Tipo    Nulos  Cardinalidad                  Rol
geolocation_zip_code_prefix   int64 0 (0.0%)         19015 Atributo Descriptivo
            geolocation_lat float64 0 (0.0%)        717360 Atributo Descriptivo
            geolocation_lng float64 0 (0.0%)        717613 Atributo Descriptivo
           geolocation_city     str 0 (0.0%)          8011 Atributo Descriptivo
          geolocation_state     str 0 (0.0%)            27 Atributo Descriptivo

📋 ORDER_ITEMS
------------------------------------------------------------------------------------------------------------
            Columna    Tipo    Nulos  Cardinalidad                 Rol
           order_id     str 0 (0.0%)         98666 PK (Llave Primaria)
      order_item_id   int64 0 (0.0%)            21  FK (Llave Foránea)
         product_id     str 0 (0.0%)         32951  FK (Llave Foránea)
          seller_id     str 0 (0.0%)          3095  FK (Llave Foránea)
shipping_limit_date     str 0 (0.0%)         93318   Atributo Temporal
              price float64 0 (0.0%)          5968    Atributo Medible
      freight_value float64 0 (0.0%)          6999    Atributo Medible

📋 ORDER_PAYMENTS
------------------------------------------------------------------------------------------------------------
             Columna    Tipo    Nulos  Cardinalidad                  Rol
            order_id     str 0 (0.0%)         99440  PK (Llave Primaria)
  payment_sequential   int64 0 (0.0%)            29 Atributo Descriptivo
        payment_type     str 0 (0.0%)             5 Atributo Descriptivo
payment_installments   int64 0 (0.0%)            24 Atributo Descriptivo
       payment_value float64 0 (0.0%)         29077     Atributo Medible

📋 ORDER_REVIEWS
------------------------------------------------------------------------------------------------------------
                Columna  Tipo         Nulos  Cardinalidad                  Rol
              review_id   str      0 (0.0%)         98410  PK (Llave Primaria)
               order_id   str      0 (0.0%)         98673   FK (Llave Foránea)
           review_score int64      0 (0.0%)             5     Atributo Medible
   review_comment_title   str 87656 (88.3%)          4527 Atributo Descriptivo
 review_comment_message   str 58247 (58.7%)         36159 Atributo Descriptivo
   review_creation_date   str      0 (0.0%)           636    Atributo Temporal
review_answer_timestamp   str      0 (0.0%)         98248    Atributo Temporal

📋 ORDERS
------------------------------------------------------------------------------------------------------------
                      Columna Tipo       Nulos  Cardinalidad                  Rol
                     order_id  str    0 (0.0%)         99441  PK (Llave Primaria)
                  customer_id  str    0 (0.0%)         99441   FK (Llave Foránea)
                 order_status  str    0 (0.0%)             8 Atributo Descriptivo
     order_purchase_timestamp  str    0 (0.0%)         98875    Atributo Temporal
            order_approved_at  str  160 (0.2%)         90733 Atributo Descriptivo
 order_delivered_carrier_date  str 1783 (1.8%)         81018    Atributo Temporal
order_delivered_customer_date  str 2965 (3.0%)         95664    Atributo Temporal
order_estimated_delivery_date  str    0 (0.0%)           459    Atributo Temporal

📋 PRODUCTS
------------------------------------------------------------------------------------------------------------
                   Columna    Tipo      Nulos  Cardinalidad                  Rol
                product_id     str   0 (0.0%)         32951  PK (Llave Primaria)
     product_category_name     str 610 (1.9%)            73 Atributo Descriptivo
       product_name_lenght float64 610 (1.9%)            66 Atributo Descriptivo
product_description_lenght float64 610 (1.9%)          2960 Atributo Descriptivo
        product_photos_qty float64 610 (1.9%)            19 Atributo Descriptivo
          product_weight_g float64   2 (0.0%)          2204 Atributo Descriptivo
         product_length_cm float64   2 (0.0%)            99 Atributo Descriptivo
         product_height_cm float64   2 (0.0%)           102 Atributo Descriptivo
          product_width_cm float64   2 (0.0%)            95 Atributo Descriptivo

📋 SELLERS
------------------------------------------------------------------------------------------------------------
               Columna  Tipo    Nulos  Cardinalidad                  Rol
             seller_id   str 0 (0.0%)          3095  PK (Llave Primaria)
seller_zip_code_prefix int64 0 (0.0%)          2246 Atributo Descriptivo
           seller_city   str 0 (0.0%)           611 Atributo Descriptivo
          seller_state   str 0 (0.0%)            23 Atributo Descriptivo

📋 CATEGORY_TRANSLATION
------------------------------------------------------------------------------------------------------------
                      Columna Tipo    Nulos  Cardinalidad                  Rol
        product_category_name  str 0 (0.0%)            71 Atributo Descriptivo
product_category_name_english  str 0 (0.0%)            71 Atributo Descriptivo


============================================================================================================
LEYENDA DE ROLES
============================================================================================================

  🔵 PK (Llave Primaria)      → Identificador único de registro
  🟢 FK (Llave Foránea)       → Referencia a otra tabla
  ⚫ Atributo Temporal         → Timestamp, fecha, duración
  🟡 Atributo Medible         → Valores numéricos (precios, peso, puntuación)
  ⚪ Atributo Descriptivo     → Texto, categoría, estado
