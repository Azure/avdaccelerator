$kql = @"

"@
($kql.Replace("`r","").Replace("`n","")) | ConvertTo-Json
