# Microsoft MCP Server for Enterprise - Setup Guide

## Overview
This guide walks through setting up the Microsoft MCP Server for Enterprise in your Entra ID tenant and connecting it to Visual Studio Code. The MCP Server enables Copilot to query your Microsoft 365 tenant data using Microsoft Graph API.

## Prerequisites
- **Administrator access**: Run PowerShell as Administrator
- **Role requirement**: Application Administrator or Cloud Application Administrator role in your Entra tenant
- **Visual Studio Code**: Installed on your machine

## Installation Steps

### Step 1: Install Microsoft.Entra.Beta PowerShell Module

Open PowerShell as Administrator and run:

```powershell
Install-Module Microsoft.Entra.Beta -Force -AllowClobber
```

### Step 2: Authenticate to Your Tenant

Connect to your tenant with the required permissions:

```powershell
Connect-Entra -Scopes 'Application.ReadWrite.All', 'Directory.Read.All', 'DelegatedPermissionGrant.ReadWrite.All'
```

**Tip**: Verify your connection:
```powershell
Get-EntraContext
```

### Step 3: Register MCP Server and Grant Permissions

Register the Microsoft MCP Server for Enterprise and grant permissions to VS Code:

```powershell
Grant-EntraBetaMCPServerPermission -ApplicationName VisualStudioCode
```

This command:
- Registers the Microsoft MCP Server for Enterprise in your tenant
- Grants delegated permissions to Visual Studio Code
- Configures OAuth2 permission grants for seamless authentication

### Step 4: Verify Registration

Confirm both applications are registered in your tenant:

#### Using PowerShell:
```powershell
$mcpClientSp = Get-EntraBetaServicePrincipal -Select id,appId,displayName -Filter "appId eq 'aebc6443-996d-45c2-90f0-388ff96faa56'"
$mcpServerSp = Get-EntraBetaServicePrincipal -Select id,appId,displayName -Filter "appId eq 'e8c77dc2-69b3-43f4-bc51-3213c9d915b4'"
$mcpClientSp, $mcpServerSp | Format-Table id, appId, displayName -AutoSize
```

#### Expected Applications:
| Name | App ID (Client ID) |
|------|-------------------|
| Microsoft MCP Server for Enterprise | `e8c77dc2-69b3-43f4-bc51-3213c9d915b4` |
| Visual Studio Code | `aebc6443-996d-45c2-90f0-388ff96faa56` |

#### Verify Permissions Granted:
```powershell
$grant = Get-EntraBetaServicePrincipalOAuth2PermissionGrant -ServicePrincipalId $mcpClientSp.Id
$grant.Scope -split ' '
```

### Step 5: Install MCP Server in VS Code

1. Click this link: [Install Microsoft MCP Server for Enterprise](https://vscode.dev/redirect/mcp/install?name=Microsoft%20MCP%20Server%20for%20Enterprise&config=%7b%22name%22:%22Microsoft%20MCP%20Server%20for%20Enterprise%22%2c%22type%22:%22http%22%2c%22url%22:%22https://mcp.svc.cloud.microsoft/enterprise%22%7d)
2. Select **Install** in VS Code
3. Authenticate with an administrator account when prompted

### Step 6: Test the Setup

1. Open Copilot Chat in VS Code
2. Switch to **Agent** mode
3. Ask a tenant-specific question, such as:
   - "How many users are in my tenant?"
   - "List all users capable of SSPR"
   - "Are there access reviews running in my tenant?"
4. Review the response which includes:
   - The tools invoked to understand the intent
   - The Microsoft Graph REST API call executed
   - A natural language answer summarizing the tenant data

## Automated Setup Script

For convenience, you can use the provided `setup-script.ps1` to automate steps 2-4:

```powershell
.\setup-script.ps1
```

The script will:
- Connect to your Entra tenant
- Register the MCP Server
- Grant permissions to VS Code
- Verify the setup
- Display next steps

## Available MCP Scopes

The MCP Server exposes **34 delegated permissions** following the pattern `MCP.{microsoft-graph-scope-name}`. All scopes are read-only and require admin consent.

### Complete List of Available Scopes

| Scope | Description |
|-------|-------------|
| **MCP.AccessReview.Read.All** | Read access reviews |
| **MCP.AdministrativeUnit.Read.All** | Read administrative units |
| **MCP.Application.Read.All** | Read all applications |
| **MCP.AuditLog.Read.All** | Read all audit logs |
| **MCP.AuthenticationContext.Read.All** | Read authentication context |
| **MCP.Device.Read.All** | Read all devices |
| **MCP.DirectoryRecommendations.Read.All** | Read directory recommendations |
| **MCP.Domain.Read.All** | Read all domains |
| **MCP.EntitlementManagement.Read.All** | Read entitlement management |
| **MCP.GroupMember.Read.All** | Read group members |
| **MCP.HealthMonitoringAlert.Read.All** | Read all scenario health monitoring alerts |
| **MCP.IdentityRiskEvent.Read.All** | Read identity risk events |
| **MCP.IdentityRiskyServicePrincipal.Read.All** | Read identity risky service principals |
| **MCP.IdentityRiskyUser.Read.All** | Read identity risky users |
| **MCP.LicenseAssignment.Read.All** | Read license assignments |
| **MCP.LifecycleWorkflows.Read.All** | Read lifecycle workflows |
| **MCP.LifecycleWorkflows-CustomExt.Read.All** | Read lifecycle workflows custom extensions |
| **MCP.LifecycleWorkflows-Reports.Read.All** | Read lifecycle workflows reports |
| **MCP.LifecycleWorkflows-Workflow.Read.All** | Read lifecycle workflows workflow information |
| **MCP.LifecycleWorkflows-Workflow.ReadBasic.All** | List all workflows in lifecycle workflows |
| **MCP.NetworkAccess.Read.All** | Read network access |
| **MCP.NetworkAccess-Reports.Read.All** | Read network access reports |
| **MCP.Organization.Read.All** | Read organization information |
| **MCP.Policy.Read.All** | Read all policies |
| **MCP.Policy.Read.ConditionalAccess** | Read conditional access policies |
| **MCP.ProvisioningLog.Read.All** | Read provisioning logs |
| **MCP.Reports.Read.All** | Read all reports |
| **MCP.RoleAssignmentSchedule.Read.Directory** | Read role assignment schedules for the directory |
| **MCP.RoleEligibilitySchedule.Read.Directory** | Read role eligibility schedules for the directory |
| **MCP.RoleManagement.Read.Directory** | Read role management for the directory |
| **MCP.Synchronization.Read.All** | Read synchronization information |
| **MCP.User.Read.All** | Read all users |
| **MCP.UserAuthenticationMethod.Read.All** | Read user authentication methods |
| ~~MCP.GroupSettings.Read.All~~ | *(Disabled) Read group settings* |

**Note**: All scopes are delegated permissions, meaning they operate within the context of the signed-in user's existing permissions. These scopes map directly to Microsoft Graph API permissions, allowing Copilot to query your tenant data securely.

## How It Works

1. **Authentication**: When you ask Copilot a question about your tenant, VS Code authenticates to the MCP Server using OAuth2
2. **Intent Recognition**: The MCP Server uses AI to understand your intent and suggests appropriate Microsoft Graph API endpoints
3. **API Execution**: The server executes the Graph API call on your behalf
4. **Response**: Results are returned to Copilot, which provides a natural language answer

## Troubleshooting

### Permission Issues
If you encounter permission errors, ensure you have:
- Application Administrator or Cloud Application Administrator role
- Consented to the required permissions during authentication

### Re-run Permission Grant
```powershell
Grant-EntraBetaMCPServerPermission -ApplicationName VisualStudioCode
```

### Disable the MCP Server
If you need to disable the MCP Server:
```powershell
$mcpServerSp = Get-EntraBetaServicePrincipal -Select id,appId,displayName -Filter "appId eq 'e8c77dc2-69b3-43f4-bc51-3213c9d915b4'"
Set-EntraBetaServicePrincipal -ServicePrincipalId $mcpServerSp.Id -AccountEnabled $false
```

### Re-enable the MCP Server
```powershell
$mcpServerSp = Get-EntraBetaServicePrincipal -Select id,appId,displayName -Filter "appId eq 'e8c77dc2-69b3-43f4-bc51-3213c9d915b4'"
Set-EntraBetaServicePrincipal -ServicePrincipalId $mcpServerSp.Id -AccountEnabled $true
```

## Security Considerations

- **Least Privilege**: The MCP Server uses delegated permissions, meaning it can only access data the authenticated user has permissions to view
- **Audit Logs**: All API calls are logged in your tenant's audit logs
- **Admin Control**: Tenant administrators can disable or remove the service principal at any time
- **No Data Storage**: The MCP Server does not store your tenant data; it only facilitates real-time queries

## Frequently Asked Questions

### Do I need to run the setup script every time I open VS Code?

No. The setup is a **one-time process**:

1. **One-time setup**: Run `setup-script.ps1` to register the MCP Server in your tenant
2. **One-time VS Code installation**: Install the MCP Server in VS Code using the installation link
3. **One-time authentication**: Sign in when prompted during first use

After the initial setup, the MCP Server will be available automatically every time you open VS Code. You won't need to run any PowerShell commands or authenticate again.

**Re-authentication is only needed if:**
- Your authentication token expires (typically after several months)
- An admin revokes the permissions
- You sign out manually from VS Code

### Does this use delegated or application permissions?

The Microsoft MCP Server for Enterprise uses **delegated permissions**, not application permissions.

**What this means:**

- **User context**: The MCP Server can only access data that YOU (the signed-in user) have permissions to see
- **No elevated access**: It doesn't have any special privileges beyond what your account already has
- **Secure by design**: If your account can't view certain data in the Azure Portal or Microsoft 365 admin center, the MCP Server can't access it either
- **Audit trail**: All API calls are made in your user context and appear in audit logs under your account
- **No backdoor access**: Unlike application permissions that work regardless of who's using the app, delegated permissions ensure the MCP Server is acting on your behalf with your existing permissions

This delegated permission model provides enhanced security and ensures the principle of least privilege is maintained.

### Can other users in my tenant use the MCP Server after I set it up?

Yes. Once you run the setup script, the MCP Server is registered in your tenant and available to all users. However:

- Each user must install the MCP Server in their own VS Code instance
- Each user authenticates with their own credentials
- Each user can only access data they have permissions to view (delegated permissions)

### What permissions are granted to the MCP Server?

The MCP Server exposes delegated permissions following the pattern `MCP.{microsoft-graph-scope-name}`. These include:

- MCP.User.Read.All
- MCP.Group.Read.All
- MCP.Application.Read.All
- MCP.AuditLog.Read.All
- MCP.Directory.Read.All
- And many more read-only scopes

All permissions are delegated, meaning they only work within the context of the authenticated user's existing permissions.

### Is my tenant data stored anywhere?

No. The MCP Server does not store your tenant data. It only facilitates real-time queries to Microsoft Graph API. All data remains in your Microsoft 365 tenant, and API calls are made on-demand when you ask Copilot questions.

## Resources

- [Microsoft Graph API Documentation](https://learn.microsoft.com/graph)
- [Entra PowerShell Module Documentation](https://learn.microsoft.com/powershell/entra)
- [Model Context Protocol (MCP) Specification](https://modelcontextprotocol.io)

## License

This setup guide is provided as-is for educational and configuration purposes.

## Contributing

If you find issues or have improvements to suggest, please open an issue or submit a pull request.
