data "tfe_outputs" "org_day_zero_infra" {
  organization = var.tfc_org
  workspace    = var.day_zero_infra_tfc_workspace_name
}

data "tfe_outputs" "vault" {
  organization = var.tfc_org
  workspace    = var.vault_tfc_workspace_name
}