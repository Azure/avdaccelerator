function DownloadFile {
    param ([string] $url, [string] $localFile, [bool] $suppressOutput=$false)

    $maxRetries = 3
    $retryCount = 0

    if (-not $supressOutput) { Write-Output "Downloading $url to $localFile" }

    while (-not(Test-Path $localFile) -and $retryCount -le $maxRetries -and $Error.Count -eq 0) {
        Try {
            $client = new-object System.Net.WebClient
            $client.DownloadFile($url, $localFile)
            if (-not $supressOutput) { Write-Output "Download to $localFile completed..." }
        }
        Catch {
            $retrycount++
            if ($retryCount -le $maxRetries) {
                $Error.Clear()
                if (-not $supressOutput) { Write-Output "Retrying download of $url, retry number $retryCount" }
            }
        }
    }
}