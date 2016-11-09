$Data = @{}

$Data.function1 = @{
    Name = 'Connect-Unity'
    Parameters = @(
        @{'Name' = 'Server'; 'type' = 'String[]'},
        @{'Name' = 'Session'; 'type' = 'UnitySession'},
        @{'Name' = 'Username'; 'type' = 'String'},
        @{'Name' = 'Password'; 'type' = 'SecureString'},
        @{'Name' = 'Credentials'; 'type' = 'PSCredential'},
        @{'Name' = 'TrustAllCerts'; 'type' = 'Boolean'}
    )
}

$Data.function2 = @{
    Name = 'Disable-UnityFastCache'
    Parameters = @(
        @{'Name' = 'Session'; 'type' = 'UnitySession[]'}
    )
}

$Data.function3 = @{
    Name = 'disconnect-Unity'
    Parameters = @(
        @{'Name' = 'Session'; 'type' = 'UnitySession[]'}
    )
}

$Data.function1000 = @{
    Name = 'Update-UnityvCenter'
    Parameters = @(
        @{'Name' = 'Session'; 'type' = 'UnitySession[]'}
        @{'Name' = 'ID'; 'type' = 'String[]'}
        @{'Name' = 'Refresh'; 'type' = 'SwitchParameter'}
        @{'Name' = 'RefreshAll'; 'type' = 'SwitchParameter'}
    )
}





