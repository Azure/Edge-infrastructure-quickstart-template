locals {
  is_windows = length(regexall("^[a-z]:", lower(abspath(path.root)))) > 0
  program = local.is_windows ? "powershell.exe" : "pwsh"
}

data "external" "lnet_ip_check" {
  program = [local.program, "-File", "${abspath(path.module)}/scripts/ip-range-overlap.ps1", var.starting_address, var.ending_address, var.lnet_starting_address, var.lnet_ending_address]

  lifecycle {
    postcondition {
      condition     = self.result.result == "ok"
      error_message = "AKS Arc IP range overlaps with HCI IP range."
    }
  }
}

