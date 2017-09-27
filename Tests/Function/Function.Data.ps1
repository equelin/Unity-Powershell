$Data = @{}

$Data.function1 = @{
    Name = 'Connect-Unity'
    Parameters = @(
        @{'Name' = 'Server'; 'type' = 'String[]'},
        @{'Name' = 'Session'; 'type' = 'object'},
        @{'Name' = 'Username'; 'type' = 'String'},
        @{'Name' = 'Password'; 'type' = 'SecureString'},
        @{'Name' = 'Credentials'; 'type' = 'PSCredential'},
        @{'Name' = 'TrustAllCerts'; 'type' = 'Boolean'}
    )
}

$Data.function2 = @{
    Name = 'Disable-UnityFastCache'
    Parameters = @(
        @{'Name' = 'Session'; 'type' = 'object'}
    )
}

$Data.function3 = @{
    Name = 'disconnect-Unity'
    Parameters = @(
        @{'Name' = 'Session'; 'type' = 'object'}
    )
}

$Data.function4 = @{
    Name = 'Get-UnityVMwareLUN'
    Parameters = @(
        @{'Name' = 'Session'; 'type' = 'object'},
        @{'Name' = 'Name'; 'type' = 'String[]'},
        @{'Name' = 'ID'; 'type' = 'String[]'}
    )
}

$Data.function1000 = @{
    Name = 'Update-UnityvCenter'
    Parameters = @(
        @{'Name' = 'Session'; 'type' = 'object'}
        @{'Name' = 'ID'; 'type' = 'Object[]'}
        @{'Name' = 'Refresh'; 'type' = 'SwitchParameter'}
        @{'Name' = 'RefreshAll'; 'type' = 'SwitchParameter'}
    )
}





