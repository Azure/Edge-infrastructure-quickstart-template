param(
    $range1_start,
    $range1_end,
    $range2_start,
    $range2_end
)

$script:ErrorActionPreference = 'Stop'
$result = "overlap"

if (([IPAddress]$range1_start).Address -gt ([IPAddress]$range1_end).Address -or ([IPAddress]$range2_start).Address -gt ([IPAddress]$range2_end).Address) {
    $result = "invalid"
}

if (([IPAddress]$range1_end).Address -lt ([IPAddress]$range2_start).Address) {
    $result = "ok"
}

if (([IPAddress]$range2_end).Address -lt ([IPAddress]$range1_start).Address) {
    $result = "ok"
}

echo @{
    "result"= $result
} | ConvertTo-Json
