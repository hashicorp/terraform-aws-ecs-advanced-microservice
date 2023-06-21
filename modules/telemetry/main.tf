resource "datadog_dashboard" "app_metrics" {
  title       = var.waypoint_project
  layout_type = "ordered"
  reflow_type = "fixed"

  # the dashboard should enable toggling between dev and prod
  template_variable {
    name             = "env"
    available_values = var.ecs_cluster_names
  }

  widget {
    free_text_definition {
      color      = "#4d4d4d"
      font_size  = "auto"
      text       = "Welcome to ${var.waypoint_project} Dashboard!"
      text_align = "left"
    }

    widget_layout {
      height          = 1
      is_column_break = false
      width           = 12
      x               = 0
      y               = 0
    }
  }

  widget {
    timeseries_definition {
      legend_columns = [
        "avg",
        "max",
        "min",
        "sum",
        "value",
      ]
      legend_layout = "auto"
      show_legend   = true
      title_align   = "left"
      title_size    = "16"

      request {
        display_type   = "line"
        on_right_yaxis = false

        formula {
          formula_expression = "query1"
        }

        query {
          metric_query {
            data_source = "metrics"
            name        = "query1"
            query       = "avg:container.cpu.usage{task_name:waypoint-${local.lowercased_waypoint_project},cluster_name:$env}"
          }
        }

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }
    }

    widget_layout {
      height          = 2
      is_column_break = false
      width           = 4
      x               = 0
      y               = 1
    }
  }
  widget {
    timeseries_definition {
      legend_columns = [
        "avg",
        "max",
        "min",
        "sum",
        "value",
      ]
      legend_layout = "auto"
      show_legend   = true
      title_align   = "left"
      title_size    = "16"

      request {
        display_type   = "line"
        on_right_yaxis = false

        formula {
          formula_expression = "query1"
        }

        query {
          metric_query {
            data_source = "metrics"
            name        = "query1"
            query       = "avg:container.memory.usage{cluster_name:$env,task_name:waypoint-${local.lowercased_waypoint_project}}"
          }
        }

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }
    }

    widget_layout {
      height          = 2
      is_column_break = false
      width           = 4
      x               = 4
      y               = 1
    }
  }
  widget {
    timeseries_definition {
      legend_columns = [
        "avg",
        "max",
        "min",
        "sum",
        "value",
      ]
      legend_layout = "auto"
      show_legend   = true
      title_align   = "left"
      title_size    = "16"

      request {
        display_type   = "line"
        on_right_yaxis = false

        formula {
          formula_expression = "query1"
        }

        query {
          metric_query {
            data_source = "metrics"
            name        = "query1"
            query       = "avg:container.net.rcvd{cluster_name:$env,container_name:${local.lowercased_waypoint_project}}"
          }
        }

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }
    }

    widget_layout {
      height          = 2
      is_column_break = false
      width           = 4
      x               = 0
      y               = 3
    }
  }
  widget {
    timeseries_definition {
      legend_columns = [
        "avg",
        "max",
        "min",
        "sum",
        "value",
      ]
      legend_layout = "auto"
      show_legend   = true
      title_align   = "left"
      title_size    = "16"

      request {
        display_type   = "line"
        on_right_yaxis = false

        formula {
          formula_expression = "query1"
        }

        query {
          metric_query {
            data_source = "metrics"
            name        = "query1"
            query       = "avg:container.net.sent{cluster_name:$env,task_name:waypoint-${local.lowercased_waypoint_project}}"
          }
        }

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }
    }

    widget_layout {
      height          = 2
      is_column_break = false
      width           = 4
      x               = 4
      y               = 3
    }
  }
  widget {
    timeseries_definition {
      legend_columns = [
        "avg",
        "max",
        "min",
        "sum",
        "value",
      ]
      legend_layout = "auto"
      show_legend   = true
      title_align   = "left"
      title_size    = "16"

      request {
        display_type   = "line"
        on_right_yaxis = false

        formula {
          formula_expression = "query1"
        }

        query {
          metric_query {
            data_source = "metrics"
            name        = "query1"
            query       = "avg:container.io.read{cluster_name:$env,task_name:waypoint-${local.lowercased_waypoint_project}}"
          }
        }

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }
    }

    widget_layout {
      height          = 2
      is_column_break = false
      width           = 4
      x               = 0
      y               = 5
    }
  }
  widget {
    timeseries_definition {
      legend_columns = [
        "avg",
        "max",
        "min",
        "sum",
        "value",
      ]
      legend_layout = "auto"
      show_legend   = true
      title_align   = "left"
      title_size    = "16"

      request {
        display_type   = "line"
        on_right_yaxis = false

        formula {
          formula_expression = "query1"
        }

        query {
          metric_query {
            data_source = "metrics"
            name        = "query1"
            query       = "avg:container.io.write{cluster_name:$env,task_name:waypoint-${local.lowercased_waypoint_project}}"
          }
        }

        style {
          line_type  = "solid"
          line_width = "normal"
          palette    = "dog_classic"
        }
      }
    }

    widget_layout {
      height          = 2
      is_column_break = false
      width           = 4
      x               = 4
      y               = 5
    }
  }
}

resource "vault_generic_secret" "dev_datadog_key" {
  provider  = vault.dev
  data_json = "{\"api_key\": \"${var.datadog_api_key}\"}"
  path      = "${var.vault_dev_kv_secrets_engine_path}/datadog"
}

resource "vault_generic_secret" "prod_datadog_key" {
  provider  = vault.prod
  data_json = "{\"api_key\": \"${var.datadog_api_key}\"}"
  path      = "${var.vault_prod_kv_secrets_engine_path}/datadog"
}

# TODO: Monitors
