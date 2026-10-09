$manifest = Join-Path $PSScriptRoot '..\android\app\src\main\AndroidManifest.xml'
if (-not (Test-Path $manifest)) {
    Write-Host 'No Android manifest found, skipping.'
    exit 0
}

$xml = [IO.File]::ReadAllText($manifest)
$changed = $false

if ($xml -notmatch 'android\.permission\.INTERNET') {
    $perm = '<uses-permission android:name="android.permission.INTERNET"/>'
    $xml = ([regex]'<application').Replace($xml, "$perm`r`n    <application", 1)
    $changed = $true
}

if ($xml -notmatch 'android:scheme="https"') {
    $intent = '<intent><action android:name="android.intent.action.VIEW" /><data android:scheme="https" /></intent>'
    if ($xml -match '<queries>') {
        $xml = ([regex]'<queries>').Replace($xml, "<queries>`r`n        $intent", 1)
    } else {
        $xml = $xml.Replace('</manifest>', "    <queries>`r`n        $intent`r`n    </queries>`r`n</manifest>")
    }
    $changed = $true
}

if ($changed) {
    [IO.File]::WriteAllText($manifest, $xml, (New-Object Text.UTF8Encoding $false))
    Write-Host 'Android manifest updated (internet + open links).'
} else {
    Write-Host 'Android manifest already OK.'
}
