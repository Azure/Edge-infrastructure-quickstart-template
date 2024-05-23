resource "azapi_resource" "address" {
  count     = var.country == "" ? 0 : 1
  type      = "Microsoft.EdgeOrder/addresses@2024-02-01"
  parent_id = var.resourceGroup.id
  name      = var.addressResourceName
  location  = var.resourceGroup.location
  body = {
    properties = {
      addressClassification = "Site"
      shippingAddress = {
        addressType     = "None"
        city            = var.city
        companyName     = var.companyName
        country         = var.country
        postalCode      = var.postalCode
        stateOrProvince = var.stateOrProvince
        streetAddress1  = var.streetAddress1
        streetAddress2  = var.streetAddress2
        streetAddress3  = var.streetAddress3
        zipExtendedCode = var.zipExtendedCode
      }
      contactDetails = {
        contactName    = var.contactName
        emailList      = var.emailList
        mobile         = var.mobile
        phone          = var.phone
        phoneExtension = var.phoneExtension
      }
    }
  }
}

resource "azapi_resource" "site" {
  count     = var.country == "" ? 0 : 1
  type      = "Microsoft.Edge/Sites@2023-07-01-preview"
  parent_id = var.resourceGroup.id
  name      = var.siteResourceName
  body = {
    properties = {
      displayName       = var.siteDisplayName
      addressResourceId = azapi_resource.address[0].id
    }
  }
  schema_validation_enabled = false
}
