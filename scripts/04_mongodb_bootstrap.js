// Bootstrap preliminar para las colecciones documentales y analiticas en MongoDB.
// Ejecutar en mongosh sobre la base de datos destino.

db = db.getSiblingDB("ecommify");

db.createCollection("products_catalog", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["product_id"],
      properties: {
        product_id: { bsonType: "string" },
        product_category_name: { bsonType: ["string", "null"] },
        product_category_name_english: { bsonType: ["string", "null"] },
        dimensions: {
          bsonType: ["object", "null"],
          properties: {
            weight_g: { bsonType: ["double", "int", "long", "decimal", "null"] },
            length_cm: { bsonType: ["double", "int", "long", "decimal", "null"] },
            height_cm: { bsonType: ["double", "int", "long", "decimal", "null"] },
            width_cm: { bsonType: ["double", "int", "long", "decimal", "null"] }
          }
        },
        metrics: {
          bsonType: ["object", "null"]
        }
      }
    }
  }
});

db.createCollection("orders_denormalized", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["order_id", "customer_id", "order_status", "order_purchase_timestamp"],
      properties: {
        order_id: { bsonType: "string" },
        customer_id: { bsonType: "string" },
        order_status: { bsonType: "string" },
        order_purchase_timestamp: { bsonType: "date" },
        customer_snapshot: {
          bsonType: ["object", "null"]
        },
        items: {
          bsonType: ["array", "null"],
          items: {
            bsonType: "object",
            required: ["order_item_id", "product_id", "seller_id"],
            properties: {
              order_item_id: { bsonType: ["int", "long"] },
              product_id: { bsonType: "string" },
              seller_id: { bsonType: "string" },
              price: { bsonType: ["double", "int", "long", "decimal"] },
              freight_value: { bsonType: ["double", "int", "long", "decimal"] }
            }
          }
        },
        payments: {
          bsonType: ["array", "null"]
        },
        reviews: {
          bsonType: ["array", "null"]
        },
        totals: {
          bsonType: ["object", "null"]
        }
      }
    }
  }
});

db.createCollection("reviews_analytics", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["review_id", "order_id", "review_score"],
      properties: {
        review_id: { bsonType: "string" },
        order_id: { bsonType: "string" },
        review_score: { bsonType: ["int", "long"] },
        review_comment_title: { bsonType: ["string", "null"] },
        review_comment_message: { bsonType: ["string", "null"] },
        review_creation_date: { bsonType: ["date", "null"] }
      }
    }
  }
});

db.createCollection("category_metrics", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["product_category_name"],
      properties: {
        product_category_name: { bsonType: "string" },
        product_category_name_english: { bsonType: ["string", "null"] },
        total_orders: { bsonType: ["int", "long", "double", "decimal", "null"] },
        total_revenue: { bsonType: ["double", "int", "long", "decimal", "null"] },
        avg_review_score: { bsonType: ["double", "int", "long", "decimal", "null"] }
      }
    }
  }
});

db.products_catalog.createIndex({ product_id: 1 }, { unique: true, name: "uidx_products_catalog_product_id" });
db.products_catalog.createIndex({ product_category_name: 1 }, { name: "idx_products_catalog_category" });

db.orders_denormalized.createIndex({ order_id: 1 }, { unique: true, name: "uidx_orders_denormalized_order_id" });
db.orders_denormalized.createIndex({ customer_id: 1, order_purchase_timestamp: -1 }, { name: "idx_orders_denormalized_customer_purchase" });
db.orders_denormalized.createIndex({ "items.product_id": 1 }, { name: "idx_orders_denormalized_items_product_id" });
db.orders_denormalized.createIndex({ order_status: 1 }, { name: "idx_orders_denormalized_order_status" });

db.reviews_analytics.createIndex({ review_id: 1 }, { unique: true, name: "uidx_reviews_analytics_review_id" });
db.reviews_analytics.createIndex({ order_id: 1 }, { name: "idx_reviews_analytics_order_id" });
db.reviews_analytics.createIndex({ review_score: 1 }, { name: "idx_reviews_analytics_review_score" });

db.category_metrics.createIndex({ product_category_name: 1 }, { unique: true, name: "uidx_category_metrics_category_name" });