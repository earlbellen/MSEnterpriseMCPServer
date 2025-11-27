<#
.SYNOPSIS
    Provisions the Microsoft MCP Server for Enterprise and grants permissions to Visual Studio Code.

.DESCRIPTION
    This script automates the setup of the Microsoft MCP Server for Enterprise in your Entra ID tenant.
    It connects to your tenant, registers the MCP Server service principal, grants delegated permissions
    to Visual Studio Code, and verifies the configuration.
    
    The MCP Server enables GitHub Copilot in VS Code to query your Microsoft 365 tenant data using
    Microsoft Graph API through natural language questions.

.PARAMETER None
    This script does not accept parameters.

.EXAMPLE
    .\setup-script.ps1
    Runs the complete setup process interactively.

.NOTES
    File Name      : setup-script.ps1
    Author         : Dave Bellen
    Prerequisite   : PowerShell 5.1 or higher
                     Microsoft.Entra.Beta module
                     Application Administrator or Cloud Application Administrator role
    
    Version        : 1.0
    Creation Date  : November 27, 2025

.LINK
    https://learn.microsoft.com/graph
    https://learn.microsoft.com/powershell/entra
#>

# Step 1: Install the Microsoft.Entra.Beta PowerShell module
Write-Host "Step 1: Installing Microsoft.Entra.Beta module..." -ForegroundColor Cyan
# Install-Module Microsoft.Entra.Beta -Force -AllowClobber

# Step 2: Connect to Entra with required scopes
Write-Host "`nStep 2: Connecting to Entra tenant..." -ForegroundColor Cyan
Connect-Entra -Scopes 'Application.ReadWrite.All', 'Directory.Read.All', 'DelegatedPermissionGrant.ReadWrite.All'

# Verify connection
Write-Host "`nVerifying connection..." -ForegroundColor Yellow
Get-EntraContext | Format-List

# Step 3: Register MCP Server and grant permissions to VS Code
Write-Host "`nStep 3: Registering MCP Server and granting permissions to Visual Studio Code..." -ForegroundColor Cyan
Grant-EntraBetaMCPServerPermission -ApplicationName VisualStudioCode

# Step 4: Verify registration
Write-Host "`nStep 4: Verifying registration..." -ForegroundColor Cyan
$mcpClientSp = Get-EntraBetaServicePrincipal -Select id,appId,displayName -Filter "appId eq 'aebc6443-996d-45c2-90f0-388ff96faa56'"
$mcpServerSp = Get-EntraBetaServicePrincipal -Select id,appId,displayName -Filter "appId eq 'e8c77dc2-69b3-43f4-bc51-3213c9d915b4'"

Write-Host "`nRegistered Applications:" -ForegroundColor Green
$mcpClientSp, $mcpServerSp | Format-Table id, appId, displayName -AutoSize

# Verify permissions
Write-Host "`nGranted Permissions:" -ForegroundColor Green
$grant = Get-EntraBetaServicePrincipalOAuth2PermissionGrant -ServicePrincipalId $mcpClientSp.Id
$grant.Scope -split ' ' | Sort-Object

Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Click this link to install in VS Code: https://vscode.dev/redirect/mcp/install?name=Microsoft%20MCP%20Server%20for%20Enterprise&config=%7b%22name%22:%22Microsoft%20MCP%20Server%20for%20Enterprise%22%2c%22type%22:%22http%22%2c%22url%22:%22https://mcp.svc.cloud.microsoft/enterprise%22%7d"
Write-Host "2. Select 'Install' in VS Code and authenticate"
Write-Host "3. Open Copilot Chat in Agent mode and test with a question like 'How many users are in my tenant?'"
