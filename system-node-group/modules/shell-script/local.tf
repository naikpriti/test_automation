locals {
  default_read_script_path = "${path.module}/scripts/read.sh"
  delete_script_path       = var.delete_script_path != null ? var.delete_script_path : local.no_op_script_path
  environment = merge({
    "TF_AZURE_LOGIN_SCRIPT_PATH"  = local.login_script_path
    "TF_AZURE_LOGOUT_SCRIPT_PATH" = local.logout_script_path
    "TF_DEFAULT_RESULT"           = "{\"run\":true}"
  }, var.environment)
  login_script_path  = "${path.module}/scripts/login.sh"
  logout_script_path = "${path.module}/scripts/logout.sh"
  no_op_script_path  = "${path.module}/scripts/no-op.sh"
  read_script_path   = var.read_script_path != null ? var.read_script_path : local.default_read_script_path
  update_script_path = var.update_script_path != null ? var.update_script_path : local.no_op_script_path
}