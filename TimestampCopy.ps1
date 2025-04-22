
##### Constants
$homepage = "https://github.com/jurakovic/timestamp-copy"
$version = "2.1.0-preview.1"
$appdataPath = "$env:LOCALAPPDATA\TimestampCopy"
$scriptPath = "$appdataPath\tscp.ps1"
$iconPath = "$appdataPath\icon.ico"
$clipFile = "$appdataPath\clip"
$fRootKey = "HKEY_CLASSES_ROOT\*\shell\TimestampCopy"
$dRootKey = "HKEY_CLASSES_ROOT\Directory\shell\TimestampCopy"
$datetimeFormat = "yyyy-MM-dd HH:mm:ss"

##### Install/Uninstall Functions

function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "  Timestamp Copy ($version)"
    Write-Host "                            "
    Write-Host "  [i] Install               "
    Write-Host "  [u] Uninstall             "
    Write-Host "                            "
    Write-Host "  [q] Quit                  "
    Write-Host ""
    $option = Read-Host "Choose option"
    Clear-Host
    Perform-Action -Option $option
    if ($option -ine "q") {
        Pause-Script "continue"
        Show-Menu
    }
}

function Perform-Action {
    param (
        [string]$Option
    )

    switch ($Option) {
        "i" { Install }
        "u" { Uninstall }
        "q" { return }
        default { Write-Host "Unknown option: $Option" }
    }
}

function Pause-Script {
    param (
        [string]$Option = "exit"
    )
    Write-Host -NoNewLine "Press any key to $Option..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

function Install {
    net session *> $null
    if (-Not $?) {
        Write-Host "Not running as Admin"
        Pause-Script "exit"
        exit 1
    }

    Write-Host "Installing..."
    Setup-AppData
    Install-Internal -RootKey "$fRootKey"
    Install-Internal -RootKey "$dRootKey"
    Write-Host "Done"
}

function Setup-AppData {
    New-Item -Path "$appdataPath" -ItemType Directory -Force | Out-Null
    Copy-Item "$PSCommandPath" -Destination "$scriptPath"

    $iconBase64 = @'
AAABAAUAEBAAAAEAIABoBAAAVgAAABgYAAABACAAiAkAAL4EAAAgIAAAAQAgAKgQAABGDgAAMDAAAAEAIACoJQAA7h4AAEBAAAABACAAKEIAAJZEAAAoAAAAEAAAACAAAAABACAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAYVROAJqPigCLf3oAYVNNBYuAe0iUiYWnnZOP5KGXk/yhl5P8npOP5JSJhaiLgHtIYVNNBYuAegCaj4oAYlROAJqQiwCQhYAAg3dxF5WKhZKmnJfvyMC8/+Ha1//e2NX/3tjV/+Ha1//IwLz/ppyX7pWKhZKDd3IXkYaBAJyRjACLgHsAg3dyF5qPirG/tbH/29TR//Tx7//8+/n/+fj2//n49v/8+/n/9PHv/9vU0f+/tbH/mo+LsYR4cxeNgXwAYFNMBZiMiJLAtrP/8+/s//r59//5+Pb/+vn3//r59//6+ff/+vn3//n49v/6+ff/8+/s/8C3s/+YjYiSZVdQBZCEf0iroJvu29XS//r59//6+ff/+/r4//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//b1dL/q6Cc75KGgUickIuozcTA//Px7//6+ff/9/Xy/+/p5P/5+ff//Pv5//v69//6+ff/+vn3//r59//5+Pb/8/Hv/83EwP+dko2nqJyX5OPc2f/7+vj/+/r4//Ho4v/CjXL/y6SQ/97U1//p6fP/+/r4//r59//6+ff/+vn3//v6+P/j3Nn/qZ2Z5K6infzf2db/+fj2//r59//6+fb/7NvR/8aOcf+VXVL/pIia//by7v/6+vj/+vn3//r59//5+Pb/39nW/66jnvywpJ/839jV//n49v/6+ff/+vn3//v7+f/59O//qIys/6N3fv/27uj/+vr4//r59//6+ff/+fj2/9/Y1f+wpaD8sKSf5OLb2P/7+vj/+vn3//r59//6+ff//fz3/5mZ+v+al/P//fz3//r59//6+ff/+vn3//v6+P/i29j/sKSf5K6inKfPxcH/8u/t//r59//6+ff/+vn3//389/+gn/r/oJ/6//389//6+ff/+vn3//r59//y7+3/z8XB/6uemaivopxIvrGs79fPzP/6+ff/+vn3//r59//9/Pf/p6b5/6em+f/9/Pf/+vn3//r59//6+ff/19DM/7yvqu6lmJNIjH54BcGzrZLOwr3/6+bj//n49v/6+ff//fz3/6+u+f+vrvn//fz3//r59//5+Pb/6+bj/83BvP+7raeSaVxWBb6wqgC8rqgXzb64sdHEv//Sysf/7ero//v69//a2fb/2tn2//v69//t6uj/0srH/9DEvv/JurSxrqCaF7KkngDNvrkAy7y2AMm6sxfVxr+S0MK87tPHwv/a0c3/1c7J/9XOyf/a0c7/08fC/8/Bu+/RwruSva6nF8O1rwDHubMAoZOMANnKwwDOv7gAwLCoBdzMxUjezseo3MzG5NjJwvzYyML828vF5NzMxafXx8BIrJyVBcW2sADVxsAAhnhxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAoAAAAGAAAADAAAAABACAAAAAAAAAJAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa15YAFJEPQCJfnkATj83BYN3cjqNgn2KkoeCypWKhe6WjIf9loyH/ZWKhe6Sh4PKjoJ9i4R4cjtPQDgFin55AFJEPABsX1gAAAAAAAAAAAAAAAAAAAAAAFhKQwB3amQAc2ZgAOrk4wCCd3ExkYaBn5mOiumjmZX/saik/7+1sv+7sa3/u7Gt/7+1sv+xqKT/o5mV/5mOiuqRhoGfg3dxMebf3gBzZmAAeGtlAFhKQwAAAAAADQwLAHdqZAB4a2UAT0A5BIuAemWYjoniopiU/8O5tv/i29j/8evp//j08f/j3tz/497c//j08f/x6+n/4tvY/8O5tv+imJT/mI6J4oyAe2VQQToEeWxmAHhrZQAEBAQAbF9ZAHJmYABNPjcEjoJ9eZ2Sjva5sKv/0cjF/9vV0v/7+ff/+vn3//r6+P/39vT/9/b0//r6+P/6+ff/+/n3/9vV0v/RyMX/ubCr/52TjvaPg355UEE6BHRnYQBtYFoAUEI7AOjg3wCMgXxknpOP9sC2sv/u5+X/+PXz//Du7P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//Du7P/49fP/7ufl/8C2sv+elI/2jYJ9Ze7n5QBSRD0Ai4B6AIR4cjGckYziu7Gt/+7n5f/6+fb/+vn3//v6+P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//v6+P/6+ff/+vn2/+7n5f+7sa3/nZGN4oZ6dDKOgnwASjs0BZWKhZ+nnZj/0snF//j18//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//j18//SycX/p52Y/5eMh59PQToFhnl0O6CVkerHvbn/29XS//Du7P/7+vj/+vn3//v6+P/7+vj/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+/r4//Du7P/b1dL/x725/6GWkumJfXc6k4eCi6yhnf/k3Nj/+/n3//r59//6+ff/+vn3//Dq5v/v6ub/+vr4//v6+P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//7+ff/5NzY/62inf+VioWKm4+LyruwrP/x6+j/+vn3//r59//6+ff/+vn3/86lj/+zdlf/0rep/+/q5v/49/X/+vj1//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/8evo/7uwrP+dkYzJoZWQ78e8uP/38/H/+vr4//r59//6+ff/+vr4/+3b0f/FiWr/qVoz/7N3Wv+hiaD/pqLc//X19//6+ff/+vn3//r59//6+ff/+vn3//r59//6+vj/9/Px/8e8uP+ilpLupZmU/cK3s//i3dv/9/b0//r59//6+ff/+vn3//v7+f/48u7/3Lek/7JoQ/+HSTj/gFdo/9rGv//7+vj/+vn3//r59//6+ff/+vn3//r59//39vT/4t3b/8K3s/+mmpb9p5uW/cK3s//i3dr/9/b0//r59//6+ff/+vn3//r59//6+vj/+/v5/+rZ0/+Yb4D/k1Q//9i0oP/7+/n/+vn3//r59//6+ff/+vn3//r59//39vT/4t3a/8K3s/+onJf9qJyX7si9uf/28u//+vr4//r59//6+ff/+vn3//r59//6+ff/+vn3//b2+f9xbfL/emXE//Ps6f/6+vj/+vn3//r59//6+ff/+vn3//r59//6+vj/9vLv/8i9uf+onJfup5uWycC0sP/t5+T/+vr4//r59//6+ff/+vn3//r59//6+ff/+vn3//f29v9wcPz/cHD+//j39//6+ff/+vn3//r59//6+ff/+vn3//r59//6+vj/7efk/8C0sP+mmpTKpZiTirqu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+P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+vj/+vn3//j18//s5OH/vLKu/6KXk/+UiYTDdGdhGntuaQBsX1kAX1JLAAAAAAGNgXuJoZaR/7Wrp//o4N3/+PXz//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//j18//o4N3/taum/6GXkv+Ogn2KAAAAAmFUTQCEeHMAfnJsN5yRjOqmm5b/0cjE//fz8f/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//fz8f/RyMT/ppuW/52SjeqBdG83h3t2AAAAAAKQhH+XpZqW/7yyrv/Dubb/3dnW//r6+P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//7+vj/3dnW/8O5tv+8sq7/pZqW/5KHgZcAAAACd2tlKpyQjN+top//4NfU//Tw7v/v7ev/+vn3//r59//6+ff/+vn3//v6+P/6+vj/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//v7ev/9PDu/+DX1P+top7/nZKN3nxvaSmJfXdspJmU/L2yrv/w6eb/+vn3//v6+P/6+ff/+vn3//r59//39fP/5t7Y//Dt6//6+vj/+/r4//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//v6+P/6+ff/8Onm/72yrv+kmpX7jIB7a5OHgq2pnpr/z8TA//bx7//6+ff/+vn3//r59//6+ff/+/v5/+na0f+wb07/uYdu/9jGvP/x7+z/+vr4//z7+P/7+vf/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//28e//z8TA/6qemv+WioWsmo6J2q+jn//b0c7/+PXz//r59//6+ff/+vn3//r59//6+vj/8ube/8aIav+oVCv/p1s2/7uKcf/VxLv/0M3c/9XT5//19PX/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//j18//b0c7/r6Of/5yRjNmeko70s6ik/+Ta1//7+ff/+vn3//r59//6+ff/+vn3//r59//7+vj/9/Ds/9u0n/+0aEL/pE8l/6FYN/9wSW7/XVC7/9XT7P/7+/f/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+/n3/+Ta1/+zqKP/oJSQ86KWkf6zqKT/zMK//93Z1v/29fP/+vn3//r59//6+ff/+vn3//r59//6+vj/+/r4/+7b0P/IjW//pFMt/4lQOf+AUE3/s4d5//Hq5P/7+vj/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//b18//d2db/zMK//7OopP+jl5P9pJiT/rWppP/Lwr7/3dnW//b18//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+/v5//jz7v/Sr6T/k2Jg/5JXPP+waUf/8ebe//v6+f/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/9vXz/93Z1v/Lwr7/tamk/6WZlP6jl5Lzt6yn/+HY1f/7+Pb/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff//Pv4/+Lh+P9fUdj/eEp7/9a0pv/7+vj/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+/j2/+HY1f+3rKf/pJiT86KWkdm3q6b/2M7K//j08v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//7+vf/5OP2/0xN//9QTfr/5uP0//v79//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//49PL/2M7K/7erpv+ilpDan5OOrLaqpf/Mwb3/8+7s//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//v69//o5/b/UVH9/1FR/f/o5/b/+/r3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//Pu7P/Mwb3/tqql/5yQi62YjIZrtamk+8C1sP/p4d7/+vn3//v6+P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+/r3/+vq9v9WVfz/VlX8/+vq9v/7+vf/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//v6+P/6+ff/6eHe/8G1sP+0qKP7koaAbIt+eSmypqDevbGr/9bMyP/y7uv/7+3r//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//7+vf/7u32/1ta/P9bWvz/7u32//v69//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/7+3r//Lu6//WzMj/vbGr/66hnN9+cWspAAAAAqyfmZfAs67/vrKt/7qxrf/d2db/+/r4//r59//6+ff/+vn3//r59//6+ff/+vn3//v69//x8Pb/YF/8/2Bf/P/x8Pb/+/r3//r59//6+ff/+vn3//r59//6+ff/+vn3//v6+P/d2db/urGt/76yrf+/sq3/opWPlwAAAAKmmZQAoJONN76xrOq/sq3/xbq1//Hs6v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//Py9v9lZfv/ZWX7//Py9v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//Hs6v/FurX/v7Kt/7msp+qNgHo3lYmDAIJ1bwAAAAACtaiiism7tf/Et7L/1czI//Tw7v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/9fT2/2tq+/9ravv/9fT2//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//08O7/1czI/8S3sv/HubT/qJuViQAAAAFkV1EAjYB6AKeZkgChk40aw7Wvw8/Au//DtrH/1s3J//Pv7f/6+ff/+/r4//r59//6+ff/+vn3//r59//39vb/cG/7/3Bv+//39vb/+vn3//r59//6+ff/+vn3//v6+P/6+ff/8+/t/9bNyf/DtrH/zsC6/7utp8KJe3UZkoR+AHNmYAAhAAAAy723AMGzrQCzpZ42zL642tPEv//Et7H/z8XB/+zn5P/c19X/7+3r//v6+P/6+ff/+vn3//r59/+Tkvr/k5L6//r59//6+ff/+vn3//v6+P/v7ev/3NfV/+zn5P/PxcH/xLey/9PEvv/Gt7HaoZONNrOlnwC9r6oAAAAAAAAAAACMfncAYFJKAN/QygC9rqhC0sO92tjJw//Ju7X/vLGs/7Cmov/r5+T/+Pb0//r5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k/+imJT/tKqm/+PZ1v/07Or/+ff0//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+ff0//Ts6v/j2db/tKqm/6KYlP+imJP/jYF8wGRWUBZsX1kAYFNMAAAAAABYS0QAUUM8AP///wCAc258npOO/6Walf+roZz/29LO//Tt6v/49vT/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//j29P/07er/29LO/6uhnP+lmpX/n5SP/4J2cH3///8AUkQ9AFpOSABhU00Ac2ZgAG5hWy2TiIPipZqW/6Wblv/PxcH/8enm//f08v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//39PL/8enm/8/Fwf+lm5b/pZuW/5aKheJxZF4udmljAGNWTwBZS0QAAAAAAYR4cpChl5L/ppyX/6abl/+3rKj/5d/c//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/5d/c/7esqP+mm5f/ppyX/6KYk/+He3WQAAAAAVpMRgBvYlwAa15YKJWJhOGnnJj/qp+b/9TKxv/JwLz/raWh/97a2P/7+vj/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//v6+P/e2tj/raWh/8nAvP/Uysb/qp+b/6ecmP+Xi4bhb2JcJ3NmYAConZgAf3NtcqGWkv+nnJj/uK2q/+rg3f/48/H/7evp/+7s6v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//u7Or/7evp//jz8f/q4N3/uK2q/6ecmP+il5P/g3dxcaqfmgBPQToNjoJ9vKidmf+pnpr/0sjF//Pr6P/59/X/+/r4//v6+P/6+ff/+vn3//r59//6+ff/+vn3//r59//5+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//7+vj/+/r4//n39f/z6+j/0sjF/6memv+onZn/kYWAu1NFPg1vYlw3mo+J6aqgm/+wpqH/4dfT//bw7f/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//b18//g1tD/4dvW//Py8f/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//28O3/4dfT/7Cmof+qoJv/nJGM6XRnYTZ8cGpvopeS/Kqfm/+/tLD/7uXi//f08v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+/r4/+fb0/+xclP/r3NV/8aqm//h29b/9PPx//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//39PL/7uXi/7+0sP+qn5v/pJiU/IJ1b22GenWkqJ2Z/6ygnP/Jvrv/8enm//n39f/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+/v6/+HDs/+qVy7/pE8l/6ZWLv+wdFb/x6uc/+Lc1//08/H/+fj2//r49f/5+PT/+vn2//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//59/X/8enm/8m+u/+soJz/qZ6Z/4t/eaKOgnzNrKGc/66jnv/Xzcn/9O3q//r49v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vr4//fv6v/arZb/tGY//6VRJ/+kUCb/plYv/7B1WP/IrJ7/z8jL/8K/1P/Gwtj/5OHo//r59v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+Pb/9O3q/9fNyf+uo57/rKGc/5GFgMuTh4LprqOe/7Glof/b0c3/9e/s//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r6+P/6+ff/7NXI/8eHZ/+qVy3/pFAn/6RQJ/+nVy//ilZW/1VBnP9BPtf/jYzu//j39f/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/9e/s/9vRzf+xpaH/r6Of/5aKheeXi4b4sKSg/7Wppf/i2NX/+PLw//z7+f/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+/v5//fv6v/csZv/tmlD/6ZRKP+kUSj/kEcn/3o9L/9fNFz/e2Wj/+Ld2//49vT/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//8+/n/+PLw/+LY1f+0qaX/sKSg/5qOifeZjYj+saah/7Gmov++s6//x7+7/9DMyf/18/H/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r6+P/7+ff/7tjN/8mLbP+rWC//kUcn/4lgUP+KYE7/kUww/7Z+Y//r4Nn/+/r4//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//Xz8f/QzMn/x7+7/76zr/+xpqL/saah/5yQi/6bj4n+s6ei/7Onov+9s67/x7+7/9DMyf/18/H/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+/v5//jx7P/etqH/o2BG/5puW/+Ybl3/kkcn/7FjPP/t2tD/+/v5//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//Xz8f/QzMn/x7+7/72zrv+zp6L/s6ei/52Ri/6ajon3tKij/7erp//g1tL/9/Lv//z7+f/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r6+P/7+vf/o5PR/3dHdf+KRzH/lkon/9Gfhv/69/X/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//8+/n/9/Lv/+DW0v+3q6f/tKij/5yQi/iYjIbotKmk/7Wqpf/Xzcn/9O7r//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//8+/b/lZX6/zg19f9iRKv/q3d4//Pl2//7+vn/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/9O7r/9fNyf+1qqX/tKmk/5mNiOmViIPLtamk/7aqpf/TyMT/8ern//r49v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//8+/b/nZv4/zEx//8yMv//n5z0//389//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+Pb/8ern/9PIxP+2qqX/tKmk/5WIg8yPg36itKij/7erpv/Gu7b/7OPg//n39f/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//9/Pb/o6L3/zIy//8yMv//o6L4//389v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//59/X/7OPg/8a7tv+3q6b/s6ei/46BfKSIe3VtsKWf/Litp//AtbD/5dzY//fz8f/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//9/Pb/qqj3/zMz//8zM///qqj3//389v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//38/H/5dzY/8C1sP+4raf/rqOd/IN3cW97bmg2qp6Z6Luvqv+5rqn/1cvH//Pt6v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//9/Pf/sK/3/zQ0//80NP//sK/3//389v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//z7er/1cvH/7muqf+7r6r/ppqU6XNnYDdXSkMNoZWPu7uvqv+6rqn/yb65/+vj3//49vT/+/r4//v6+P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//9/Pf/trX3/zY2//82Nv//trX3//389//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//7+vj/+/r4//j29P/r49//yb65/7quqf+6rqn/mY2HvE1AOQ3EuLMAlYmDcbispv++sav/vLCr/9rQzP/18O7/7evp/+7s6v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//9/Pf/vLv2/zc3/v83N/7/vLv2//389//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//u7Or/7evp//Xw7v/a0Mz/vLCr/76xrP+1qKP/iHx2crquqgCHenQAg3ZwJ7CjnuHBta//vrKs/8W6tv/BuLP/raSg/97a2P/7+vj/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//9/Pf/wsH2/zk5/v85Of7/wsH2//389//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//v6+P/e2tj/raSg/8G4s//Furb/vrKs/8G1r/+nm5XhcGNcJ3VoYgBuYVoAAAAAAaOXkZDAtK7/xLey/6+jnv+nm5b/4drW//r49v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//9/Pf/yMf2/zw7/v88O/7/yMb2//389//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+Pb/4drW/6eblv+vo53/xLiy/72xq/+Th4GQAAAAAVlMRQB2aGIAlYiCAJCDfS64q6Xix7q1/8O2sf/CtrH/39bS//Tw7v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//9+/f/zcz2/z4+/v8+Pv7/zcz2//379//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//08O7/39bS/8K2sf/DtrH/x7q1/66hm+J2amQtfXFrAGNWTwB2aWMAcGNdAP///wCom5V9xbiy/8u9t//BtK//w7i0/+Xd2f/28/H/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//8+/f/0tH2/0FA/v9BQP7/0tH2//z79//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//bz8f/l3dn/w7iz/8G0rv/Lvbf/wbOt/5WIgnz///8AUEM8AF1RSgAAAAAAgHNsAJWHgQCNf3gWuaulv82/uf/Nv7n/wLOu/8a7tv/m3tr/9vPx//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//8+/f/19b2/0RD/f9EQ/3/19b2//z79//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/9vPx/+be2v/Gu7b/wLOu/82/uf/Lvbj/q56Yv21gWhV5bGYAY1ZQAAAAAAAAAAAAd2liALCkngCxo50Ao5WPPMS2sOTRw73/z8G7/72wq//Ivbn/5NzZ//Xy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g/aimJT/opiU/6GXk/+0qqb/5tzZ//Lp5f/07uv/+ff1//r59//6+ff/+vn3//v6+P/6+vj/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r6+P/7+vj/+vn3//r59//6+ff/+ff1//Tu6//y6eX/5tzZ/7Sqpv+hl5P/opiU/6KZlP+VioX3dGdhaf///wBQQjsAWkxGAAAAAAAAAAAAAAAAAAAAAAAAAAAAWEtEAG9iXABzZmAAaVxVOIyAe+KimJT/o5mV/6KYlP+wpqL/29HO//Lp5f/17+z/+fj1//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//5+PX/9e/s//Lp5f/b0c7/sKai/6KYlP+jmZX/opiU/46CfeNqXVc6dWhiAHRnYQBZS0UAAAAAAAAAAAAAAAAAWUtEAF1PSQBiVU4AVkhBEYJ2cLaglZD/pJqV/6OZlP+sop3/3dTR//Ho5f/07uv/+fj1//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//n49f/07uv/8ejl/93U0f+sop3/o5mU/6Salf+hlpH/hHhyt1dKQxFjVk8AXVBJAFlLRAAAAAAAAAAAAF1QSgBOQDkAua6qAHRnYW6YjIf8ppuW/6Walf+nnJf/y8G9//Dn5P/07er/+ff1//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+ff1//Tt6v/w5+T/y8G9/6ecl/+lmpX/ppuW/5qOifx3amRwy8C7AE5AOQBeUUoAAAAAAF5RSgBdUEkAaFtUAGJVTiWKfnnYpJmU/6Walf+lmpX/wbez/+zi3//x6eb/+PXz//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//49fP/8enm/+zi3//Bt7P/pZqV/6Walf+lmpX/jYF72WRXUSVqXVcAXlFLAFpNRgBaTUcAVklCAP///wB5bGaEnJKN/6acl/+lm5f/opiU/8vBvv/y6eb/+PPx//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//jz8f/y6eb/y8G+/6KYlP+lm5f/ppuX/56Tjv98b2mE////AFZJQgBcTkgAXE5IAGdaUwBiVE4ljIB73Kabl/+mnJf/p52Z/7Kno/+bj4v/sqik/+fk4f/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//n5OH/sqik/5uPi/+yp6P/qJ2Z/6acl/+mnJf/j4N+3GVYUSVqXVYAXU9IAFNFPwCqnpoAdmljdpyRjP+onZn/p5yX/7Sppf/o3tv/4djU/7Kqpv+gl5L/5eLf//v6+P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//v6+P/l4t//oJeS/7Kqpv/h2NT/6N7b/7Sppf+nnJf/qJ2Z/56Tjv96bWd2saWgAFJEPQBhU00AVUhBE4d7dcemm5f/qJ2Z/6idmf/Hvbn/7+Xi//bw7f/49vT/4+Dd//Hv7f/6+vj/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+vj/8e/t/+Pg3f/49vT/9vDt/+/l4v/Hvbn/qJ2Z/6idmf+nnJf/i355x1hKQxJjVk8AcmVfAGxfWUiWiob1qZ6a/6idmf+wpaH/4tjV//Ho5f/49fL/+vn3//v6+P/6+vj/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r6+P/7+vj/+vn3//j18v/x6OX/4tjV/7Clof+onZn/qZ6a/5mNiPRxZF1Gd2pkAP///wB7b2mMopeS/6qfm/+onZn/wbez//Dm4//07ev/+vj2//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/9/b0//b18//5+Pb/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+Pb/9O3r//Dm4//Bt7P/qJ2Z/6mfmv+jmJP/gHNtiv///wBRQzwTiHx3xqiemf+qoJv/q6Gc/8/Fwf/u5eL/9/Lw//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/9fTy/9zUzv/UycP/5+Th//Tz8f/5+Pb/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//fy8P/u5eL/z8XB/6uhnP+qoJv/qZ+a/4yAe8VVSEESZlhSOJSIg+qroZz/qqCb/7Koo//l29j/8+rn//j29P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3/+fe2f+1e17/q2dF/7qTf//RxL3/5+Xi//Tz8f/5+Pb/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//49vT/8+rn/+Xb2P+yqKP/qqCb/6uhnP+Xi4bpa15YN3FkXmidkY37raGd/6ufm/+8sa3/6+Lf//Tt6v/6+Pb/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r6+P/Ws6H/plMq/6RQJ/+lUir/q2ZE/7qTf//Rxb7/5+Xj//Xz8f/5+Pb/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vj2//Tt6v/r4t//vLGt/6ufm/+toZ3/n5SP+ndqZGZ6bmiYpJmU/62inf+soZz/xbq2/+rh3v/18O3/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//7+vn/5MKx/7VlPf+mUij/pVIp/6VRJ/+lUyr/q2dF/7uVgf/Sxr//6OXj//Tz8P/19PH/9PPv//Tz7//29fH/+fj2//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//18O3/6uHe/8W6tv+soZz/raKd/6Walf+Ac22VgXVvv6memf+top3/raKd/9TKxv/y6OX/9/Lw//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r39P/qzr//xoJf/6tXLf+lUSj/pVIp/6VRJ/+lUyr/q2hH/7uWg//MwLr/v7rH/7q2yv+9uM7/zsrY//Px7//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/9/Lw//Lo5f/Uysb/raKd/62inf+qnpr/hnp0vId7dd2soZz/rqOe/7CkoP/Xzcn/8ejl//j18v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+/v5//br5P/aqpL/tmdA/6dSKP+lUin/pVIp/6VRJ/+mUyr/oWBF/2dKgP9EPb//Pz7i/1dV7//T0fD//Pv3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//j18v/x6OX/183J/7CkoP+uo57/raGd/4t/etqLf3rwr6Of/6+jn/+zp6P/2c/L//Do5f/59vT/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+vj/+vj1/+zSxP/IhmT/rFgu/6VRKP+lUin/pVIp/5xNKP+DQSz/bztK/0wxiv85Msn/trPk//j28v/6+Pb/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//59vT/8Ojl/9nPy/+yp6P/r6Of/6+jn/+Pg37uj4J9+rCkoP+wpKD/taqm/+PZ1v/07On/+vj2//v7+f/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//7+/n/9u3n/92vl/+4akP/p1Ip/6VSKf+dTin/hUIo/31AKf97Pyz/cz5K/6eFh//Yzsf/8/Lv//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//7+/n/+vj2//Ts6f/j2db/taqm/7CkoP+wpKD/koaB+ZCEf/+xpaH/saWh/7CkoP+xpqH/t62p/7qzr//Evrv/8/Hv//r5+P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r6+P/6+fb/7tbJ/8qKav+tWTD/nk4o/4ZGLf+Pcmb/kHJn/4dGLP+fUCv/snJS/+bWzv/7+vj/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r5+P/z8e//xL67/7qzr/+3ran/saah/7CkoP+xpaH/saWh/5SIg/6ShYD+sqah/7Kmof+xpaD/sKWh/7esqP+6s6//xL67//Px7//6+fj/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//v7+f/37+n/37Sd/7RpRf+MSS7/pYd6/6aIfP+IRy7/nk4o/65cNP/nzsD/+/v6//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+fj/8/Hv/8S+u/+6s6//t6yo/7Clof+xpaD/sqah/7Kmof+ViIP/kYV/+bOnov+zp6L/t6yn/+HX0//z6+j/+vj2//v7+f/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vr4//z69//bx8v/jFlw/49POf+KSjD/iEMp/6BPKP/KjnD/+PLu//r5+P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//7+/n/+vj2//Pr6P/h19P/t6yn/7Onov+zp6L/lIeC+o6Cfe6zp6P/tKik/7aqpv/Wy8f/7+bj//j29P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//8+/f/29v3/1RO8f9mRqb/ik1K/45HKP+vYz7/69TH//v7+f/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//j29P/v5uP/1svH/7aqpv+0qKT/s6ej/5GFf/CLf3nbsqei/7SppP+0qaT/0sjE/+7l4v/49PL/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff//Pr3/+De9P9NTf3/MjL//04/1/+GV4X/2bKk//r39P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//49PL/7uXi/9LIxP+0qaT/tKmk/7Knov+NgHvch3p1vbGmof+2qqX/tamk/8/EwP/t5OH/9vLw//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//v69//j4vT/UlH8/zEx//8wMf//VFL6/+Xj9P/7+vf/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/9vLw/+3k4f/PxMD/tamk/7aqpf+xpaD/iHt1voF0bpWvop7/t6un/7aqpf/Ct7L/5NrW//Xv7P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//7+vf/5+b0/1dW/P8xMf//MTH//1ZW/P/n5fX/+/r3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//Xv7P/k2tb/wrey/7aqpf+4q6f/rqGd/4Bzbpd5bGZmqp2Y+rmtqP+3q6b/vbGt/+HX0//y6+j/+vj2//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+/r3/+rp9P9bWvv/MTH//zEx//9bWvv/6un0//v69//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r49v/y6+j/4dfT/72xrf+3q6b/ua2o/6eblvt3amRobWBaN6KWkOm5rqj/uK2n/7muqP/Yzsr/7ubi//j28//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//v69//t7PT/YWD7/zEx//8xMf//YWD7/+3s9P/7+vf/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//49vP/7ubi/9jOyv+5rqj/uK2n/7muqP+dkYzqal1WOFRHQBKYi4bEua2o/7quqf+4rKf/xbm1/+bc2f/18e7/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//7+vf/8O71/2Zl+/8wMP//MDD//2Zl+//w7vX/+/r3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/9fHu/+bc2f/FubX/uKyn/7quqf+4rKf/kYV/xVFEPRP///8Ai395irWpo/+7r6r/uq6p/76zrv/h19P/8ern//n49v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//Lx9f9ravr/MDD//zAw//9ravr/8vH1//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+fj2//Hq5//h19P/vrOu/7quqf+8sKr/saWg/4J1cIv///8AhHhyAH1wakasn5r0vbGr/7ywqv+6rqj/z8XB/+ng3f/38/H/+vn3//v6+P/6+vj/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//08/X/cXD6/zAw//8wMP//cXD6//Tz9f/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r6+P/7+vj/+vn3//fz8f/p4N3/0MXB/7quqP+8sKr/vbGr/6SYk/VwY11HeGtlAHBjXQBkVlASn5KNxr2xq/++sqz/vLCq/72xrP/f1dH/8+zp//f29P/j4N3/8e/t//r6+P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/9vX1/3d2+f8wMP//MDD//3d2+f/29fX/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r6+P/x7+3/4+Dd//f29P/z7On/39XR/72xrP+8sKr/vrKs/7yvqv+ShoDHVEZAEmNVTwBbTUYA0cXBAI+CfXa3q6b/wbSu/8C0rv+7r6r/0cbC/9jPy/+xqaX/oJeS/+Xi3//7+vj/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//f29f99fPn/MDD//zAw//99fPn/9/b1//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//7+vj/5eLf/6CXkv+xqaX/2M/L/9HGwv+7r6r/wLSu/8G1r/+xpZ//fnFrdr+zrwBTRT4AaVxWAIBzbQB6bWclq56Z3cK2sP/CtrD/wLSu/6mdmP+Ogn3/rqSg/+bj4P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//59/X/hIL4/zEw//8xMP//g4L4//n39f/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//m4+D/rqSg/46Cff+pnZj/wLSu/8K2sP/BtbD/nZGL3GRXUCVrXlgAXVBJAG5hWgByZF4A////AJqNh4W+saz/xbiz/8W4s/+zp6H/tKmk/+Ta1v/07+3/+vj3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vj1/4qJ+P8xMf//MTH//4qJ+P/6+PX/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+Pf/9O/t/+Ta1v+0qaT/s6eh/8W4s//GubP/uKum/4V4coT///8AV0lCAFxPSABaTUYAeWtlAIh8dgCDdnAlsKOd2ce6tf/HurX/xrmz/7ywq//PxMD/597b//by8P/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//v59f+Qj/j/MTH//zEx//+Qj/j/+/n1//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/9vLw/+fe2//PxMD/vLCr/8a5s//HurX/xrm0/6GUjthmWVIlbmFbAF9SSwBaTUYAAAAAAH1xawBsXlgA9+nkAJyOiG/As638yry3/8q8tv/DtrD/tqum/9bLyP/r4+D/9/Ty//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//7+vb/l5b3/zIx//8yMf//l5X3//v69v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/9/Ty/+vj4P/Wy8j/tqum/8O2sP/KvLb/yr23/7irpfyEd3Fu697aAEw+NwBhVE4AAAAAAAAAAACPgHcAfG9pAIh6dAB8b2gRrqCat8q8tv/Mvrn/zL65/8Czrv++s6//2c/L/+zl4v/39fP/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff//Pv2/56c9/8yMv//MjL//52c9//8+/b/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/9/Xz/+zl4v/Zz8v/vrOv/8Czrf/Mvrn/zL65/8e5s/+cjoi2WUxGEWpdVwBfUksAWUtEAAAAAAAAAAAAAAAAAHJlXgCWiIIAoJKMAJeIgjm8rqjjz8G7/87Au//OwLr/vK+q/7muqf/a0Mz/7OXi//f08v/6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//z79v+kovf/MzP//zMz//+kovf//Pv2//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/+vn3//r59//6+ff/9/Ty/+zl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
'@
    $iconBytes = [Convert]::FromBase64String($iconBase64)
    [IO.File]::WriteAllBytes($iconPath, $iconBytes)
}

function Install-Internal {
    param (
        [string]$RootKey
    )

    $itemPath = "$RootKey\shell"
    Add-MenuRoot -Key "$RootKey" -Label "Timestamp Copy" -Icon "$iconPath"
    Add-MenuItem -Key "$itemPath\010CopyTimestamps" -Label "Copy" -Arg "Copy-Timestamps"
    Add-MenuItem -Key "$itemPath\020PasteTimestamps" -Label "Paste" -Arg "Paste-Timestamps"
    Add-MenuItem -Key "$itemPath\030PasteDateCreated" -Label "Paste 'Date Created'" -Arg "Paste-DateCreated"
    Add-MenuItem -Key "$itemPath\040PasteDateModified" -Label "Paste 'Date Modified'" -Arg "Paste-DateModified"
}

function Add-MenuRoot {
    param (
        [string]$Key,
        [string]$Label,
        [string]$Icon
    )

    reg.exe add "$Key" /v MUIVerb /d "$Label" /f | Out-Null
    reg.exe add "$Key" /v SubCommands /f | Out-Null
    reg.exe add "$Key" /v Icon /d "$Icon" /f | Out-Null
}

function Add-MenuItem {
    param (
        [string]$Key,
        [string]$Label,
        [string]$Arg
    )

    reg.exe add "$Key" /ve /d "$Label" /f | Out-Null
    reg.exe add "$Key\command" /ve /d "powershell -ExecutionPolicy ByPass -NoProfile -Command """"& '$scriptPath' ""'$Arg'"" ""'%1'""""""" /f | Out-Null
}

function Uninstall {
    Write-Host "Uninstalling..."
    Uninstall-Internal -RootKey "$fRootKey"
    Uninstall-Internal -RootKey "$dRootKey"
    Remove-Item -Recurse -Force -Path "$appdataPath" *> $null
    Write-Host "Done"
}

function Uninstall-Internal {
    param (
        [string]$RootKey
    )

    reg.exe delete "$RootKey" /f *> $null
}

##### Context Menu Commands (Copy/Paste Functions)

function Copy-Timestamps {
    param (
        [string]$FilePath
    )

    $item = Get-Item -Path "$FilePath"
    $dc = $item.CreationTime.ToString("$datetimeFormat")
    $dm = $item.LastWriteTime.ToString("$datetimeFormat")

    Write-Host "File/Folder:   $FilePath"
    Write-Host "---"
    Write-Host "Date Created:  $dc"
    Write-Host "Date Modified: $dm"

    Set-Content -Path "$clipFile" -Value "$dc`n$dm"

    Write-Host "---"
    Write-Host "Timestamps copied"
}

function Paste-Timestamps {
    param (
        [string]$FilePath
    )

    Guard-Clipboard

    $timestamps = Get-Content -Path "$clipFile"
    $dcNew = $timestamps[0]
    $dmNew = $timestamps[1]

    $item = Get-Item -Path "$FilePath"
    $dcOld = $item.CreationTime.ToString("$datetimeFormat")
    $dmOld = $item.LastWriteTime.ToString("$datetimeFormat")

    Write-Host "File/Folder:   $FilePath"
    Write-Host "---"
    Highlight-Diff -Label "Date Created: " -Old "$dcOld" -New "$dcNew"
    Write-Host "---"
    Highlight-Diff -Label "Date Modified:" -Old "$dmOld" -New "$dmNew"
    Write-Host "---"

    $applyChanges = Read-Host "Apply changes? (y/N)"
    if ($applyChanges -ieq "y") {
        $item.CreationTime = [datetime]::ParseExact("$dcNew", "$datetimeFormat", $null)
        $item.LastWriteTime = [datetime]::ParseExact("$dmNew", "$datetimeFormat", $null)
        Write-Host "Done"
    } else {
        Write-Host "Canceled"
    }
}

function Paste-DateCreated {
    param (
        [string]$FilePath
    )

    Guard-Clipboard

    $timestamps = Get-Content -Path "$clipFile"
    $dcNew = $timestamps[0]

    $item = Get-Item -Path "$FilePath"
    $dcOld = $item.CreationTime.ToString("$datetimeFormat")
    $dmOld = $item.LastWriteTime.ToString("$datetimeFormat")

    Write-Host "File/Folder:   $FilePath"
    Write-Host "---"
    Highlight-Diff -Label "Date Created: " -Old "$dcOld" -New "$dcNew"
    Write-Host "---"
    Highlight-Diff -Label "Date Modified:" -Old "$dmOld" -New "$dmOld"
    Write-Host "---"

    $applyChanges = Read-Host "Apply changes? (y/N)"
    if ($applyChanges -ieq "y") {
        $item.CreationTime = [datetime]::ParseExact("$dcNew", "$datetimeFormat", $null)
        Write-Host "Done"
    } else {
        Write-Host "Canceled"
    }
}

function Paste-DateModified {
    param (
        [string]$FilePath
    )

    Guard-Clipboard

    $timestamps = Get-Content -Path "$clipFile"
    $dmNew = $timestamps[1]

    $item = Get-Item -Path "$FilePath"
    $dcOld = $item.CreationTime.ToString("$datetimeFormat")
    $dmOld = $item.LastWriteTime.ToString("$datetimeFormat")

    Write-Host "File/Folder:   $FilePath"
    Write-Host "---"
    Highlight-Diff -Label "Date Created: " -Old "$dcOld" -New "$dcOld"
    Write-Host "---"
    Highlight-Diff -Label "Date Modified:" -Old "$dmOld" -New "$dmNew"
    Write-Host "---"

    $applyChanges = Read-Host "Apply changes? (y/N)"
    if ($applyChanges -ieq "y") {
        $item.LastWriteTime = [datetime]::ParseExact("$dmNew", "$datetimeFormat", $null)
        Write-Host "Done"
    } else {
        Write-Host "Canceled"
    }
}

function Guard-Clipboard {
    if (-Not (Test-Path -Path "$clipFile")) {
        Write-Host "Timestamps clipboard empty."
        Pause-Script "exit"
        exit 0
    }

    $timestamps = Get-Content -Path "$clipFile"
    if ($timestamps.Count -ne 2) {
        Write-Host "Timestamps clipboard corrupted. Copy new timestamps."
        Pause-Script "exit"
        exit 0
    }

    try {
        [datetime]::ParseExact($timestamps[0], "$datetimeFormat", $null) | Out-Null
        [datetime]::ParseExact($timestamps[1], "$datetimeFormat", $null) | Out-Null
    } catch {
        Write-Host "Timestamps clipboard corrupted. Copy new timestamps."
        Pause-Script "exit"
        exit 0
    }
}

function Highlight-Diff {
    param (
        [string]$Label,
        [string]$Old,
        [string]$New
    )

    $changed = $false

    Write-Host "$Label $Old (old)"
    Write-Host -NoNewline "$Label "

    $oldParts = $Old -split "[- :]"
    $newParts = $New -split "[- :]"

    function Color-Part {
        param (
            [string]$OldVal,
            [string]$NewVal
        )
        if ("$OldVal" -eq "$NewVal") {
            Write-Host -NoNewline "$NewVal"
        } else {
            Write-Host -NoNewline "$NewVal" -ForegroundColor Green
            Set-Variable -Name changed -Value $true -Scope 1
        }
    }

    Color-Part $oldParts[0] $newParts[0] # y
    Write-Host -NoNewline "-"
    Color-Part $oldParts[1] $newParts[1] # m
    Write-Host -NoNewline "-"
    Color-Part $oldParts[2] $newParts[2] # d
    Write-Host -NoNewline " "
    Color-Part $oldParts[3] $newParts[3] # H
    Write-Host -NoNewline ":"
    Color-Part $oldParts[4] $newParts[4] # M
    Write-Host -NoNewline ":"
    Color-Part $oldParts[5] $newParts[5] # S

    if ($changed) {
        Write-Host " (new)" -ForegroundColor Green
    } else {
        Write-Host " (new)"
    }
}

##### Main

if ($args.Count -eq 1) { # cli arguments
    if ($args[0] -in @("-v", "--version")) {
        Write-Host $version
    }
    elseif ($args[0] -in @("-i", "--install")) {
        Install
    }
    elseif ($args[0] -in @("-u", "--uninstall")) {
        Uninstall
    }
    elseif ($args[0] -in @("-h", "--help", "-?")) {
        Write-Host "For help visit $homepage"
    }
} elseif ($args.Count -eq 2) { # Context menu commands
    Invoke-Expression "$($args[0]) ""$($args[1])"""
    Pause-Script
} else {
    Show-Menu
}
