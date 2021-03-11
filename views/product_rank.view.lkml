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

parameter: top_rank_limit {
  view_label: "TOTT | Top N Ranking"
  type: unquoted
  default_value: "5"
  allowed_value: {
    label: "Top 5"
    value: "5"
  }
  allowed_value: {
    label: "Top 10"
    value: "10"
  }
  allowed_value: {
    label: "Top 20"
    value: "20"
  }
  allowed_value: {
    label: "Top 50"
    value: "50"
  }
}

dimension: brand_rank_top_brands {
  view_label: " TOTT | Top N Ranking"
  label_from_parameter: parameters.top_rank_limit
  type: string
  sql:
      CASE
        WHEN ${brand_rank}<={% parameter parameters.top_rank_limit %}
          THEN
            CASE
              WHEN ${brand_rank}<10 THEN  0 || cast(${brand_rank} as varchar)
              ELSE to_char(${brand_rank})
            END
        ELSE 'Other'
      END
    ;;
}

measure: dynamic_measure {
  view_label: " TOTT | Top N Ranking"
  label_from_parameter: parameters.brand_rank_measure_selction
  type: number
  sql:
      {% if parameters.brand_rank_measure_selection._parameter_value == 'order_items_count' %} ${order_items.count}
      {% elsif parameters.brand_rank_measure_selection._parameter_value == 'order_items_sales_price' %} ${order_items.total_sale_price}
      {% elsif parameters.brand_rank_measure_selection._parameter_value == 'order_items_gross_margin' %} ${order_items.total_gross_margin}
      {% elsif parameters.brand_rank_measure_selection._parameter_value == 'order_items_returned_count' %} ${order_items.returned_count}
      {% else %}  ${order_items.count}
      {% endif %}
    ;;
  html:
      {% if parameters.brand_rank_measure_selection._parameter_value == 'order_items_count' %}  {{ order_items.count._rendered_value }}
      {% elsif parameters.brand_rank_measure_selection._parameter_value == 'order_items_sales_price' %}  {{ order_items.total_sale_price._rendered_value }}
      {% elsif parameters.brand_rank_measure_selection._parameter_value == 'order_items_gross_margin' %}  {{ order_items.total_gross_margin._rendered_value }}
      {% elsif parameters.brand_rank_measure_selection._parameter_value == 'order_items_returned_count' %}  {{ order_items.returned_count._rendered_value }}
      {% else %} {{ count._rendered_value }}
      {% endif %}
    ;;
}
}
