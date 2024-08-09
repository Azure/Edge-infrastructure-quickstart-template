locals {
  is_windows = length(regexall("^[a-z]:", lower(abspath(path.root)))) > 0
  program = local.is_windows ? "powershell.exe" : "pwsh"
}

data "external" "lnetIpCheck" {
  program = [local.program, "-File", "${abspath(path.module)}/scripts/ip-range-overlap.ps1", var.startingAddress, var.endingAddress, var.lnet-startingAddress, var.lnet-endingAddress]

  lifecycle {
    postcondition {
      condition     = self.result.result == "ok"
      error_message = "AKS Arc IP range overlaps with HCI IP range."
    }
  }
}
