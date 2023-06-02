resource "datadog_dashboard" "app_metrics" {
  title       = var.app_name
  layout_type = "ordered"

  # the dashboard should enable toggling between dev and prod
  template_variable {
    name             = "env"
    available_values = ["dev", "prod"]
    defaults         = ["prod"]
  }

  # TODO: Dashboard widgets
}

# TODO: Monitors

resource "vault_generic_secret" "dev_datadog_key" {
  provider  = vault.dev
  type      = "kv-v2"
  data_json = "{\"api_key\": \"${var.datadog_api_key}\"}"
  path      = "${var.vault_dev_kv_secrets_engine_path}/datadog"
}

resource "vault_generic_secret" "prod_datadog_key" {
  provider  = vault.prod
  type      = "kv-v2"
  data_json = "{\"api_key\": \"${var.datadog_api_key}\"}"
  path      = "${var.vault_prod_kv_secrets_engine_path}/datadog"
}
