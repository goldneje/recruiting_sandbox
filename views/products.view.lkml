view: products {
  sql_table_name: "PUBLIC"."PRODUCTS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}."BRAND" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}."COST" ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }

  dimension: distribution_center_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."DISTRIBUTION_CENTER_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: retail_price {
    type: number
    sql: ${TABLE}."RETAIL_PRICE" ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}."SKU" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name, distribution_centers.name, distribution_centers.id, inventory_items.count]
  }
}

view: ndt_top_ranking {
  derived_table: {
    explore_source: order_items {
      bind_all_filters: yes
      column: brand_name { field: products.brand }
      column: order_items_count { field: order_items.count}
      column: order_items_sales_price { field: order_items.total_sale_price }
      derived_column: ranking {
        sql: rank() over (order by order_items.total_sale_price desc) ;;
      }
    }
  }

  dimension: brand_name {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.brand_name ;;
  }

  dimension: brand_rank {
    hidden: yes
    type: string
    sql: ${TABLE}.ranking ;;
  }
}
