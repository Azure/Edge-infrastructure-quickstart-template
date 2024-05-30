output "winServerImageId" {
  value = var.downloadWinServerImage ? azapi_resource.winServerImage[0].id : null
}