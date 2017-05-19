How to generate the JSON extract of the API types definition:

1- Connect to the array

2- Run the following command:

```Powershell
Get-UnityItem -URI /api/types -JSON | Out-File C:\UnityModel-APIversion.json
```