resource "shell_script" "default" {
  environment = local.environment
  interpreter = ["/bin/bash", "-c"]
  triggers    = var.triggers

  lifecycle_commands {
    create = file(var.create_script_path)
    read   = file(local.read_script_path)
    update = file(local.update_script_path)
    delete = file(local.delete_script_path)
  }
}