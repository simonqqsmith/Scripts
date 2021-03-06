param ([string]$ConfigurationsPath,
       [string]$SolutionPath, 
       [string]$ParametersXml, 
       [string]$Environment,
       [string]$pathOnServer)
# Import sqlps module
Import-Module Sqlps -DisableNameChecking;       
# Set the devenv location
$devenv = "C:/Program Files (x86)/Microsoft Visual Studio 14.0/Common7/IDE/devenv.com"

# Store the IntegrationServices Assembly namespace to avoid typing it every time
$ISNamespace = "Microsoft.SqlServer.Management.IntegrationServices"

# Load the IntegrationServices Assembly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null;

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$ParametersXml = "$scriptPath/$ParametersXml"
   
function Main()
{

    # Input validation
    if (-Not(Test-Path($ParametersXml)))
    {
        throw New-Object System.ArgumentException "Parameters.xml not found"
        return
    }
    
    #Get configurations from *.dtproj.user
	$ConfigurationsPath = "$scriptPath/$ConfigurationsPath"
    [xml]$configFile =  Get-Content $ConfigurationsPath
    $configurationsNode = $configFile.SelectNodes("/DataTransformationsUserConfiguration/Configurations/Configuration")
    
    # Get configuration for $Environment parameter
    $configurationsNode | % {
        if ($_.Name -eq $Environment)
        {
            $serverName = $_.Options.ServerName
           # $pathOnServer = $_.Options.PathOnServer # Comment out to pass as parameter instead
        }
    }   
    
    if ([string]::IsNullOrEmpty($serverName) -or [string]::IsNullOrEmpty($pathOnServer) -or 
        $serverName -eq $null -or $pathOnServer -eq $null )
    {
        throw New-Object System.ArgumentException "Could not connect to Server: $serverName. Does it really exist?"
        return
    }   
    
    # Get catalog, folder and project name from $pathOnServer
    $catalogConnectionString = "Data Source=" + $serverName + ";Initial Catalog=master;Integrated Security=SSPI;"
    $path = $pathOnServer.Split("/", 4)
    $catalogName = $path[1]
    $folderName = $path[2]
    $projectName = $path[3]
    
    if ([string]::IsNullOrEmpty($catalogName) -or 
        [string]::IsNullOrEmpty($folderName) -or 
        [string]::IsNullOrEmpty($projectName))
    {
        throw New-Object System.ArgumentException "Check that $Environment build configuration is set correctly in the SSIS project."
        return
    }
    
    # Connect to the SSIS Server
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $catalogConnectionString
    $integrationServices = New-Object $ISNamespace".IntegrationServices" $sqlConnection
    
    if ($integrationServices -eq $null)
    {
        Write-Host "Unable to connect to Integration Services Catalog."
        return
    }
    
    # Get the existing catalog if it exists
    if ($integrationServices.Catalogs.Contains($catalogName)) 
    {
        Write-Host "$catalogName catalog found"
        $catalog = $integrationServices.Catalogs[$catalogName]        
    }
    else
    {
        Write-Host "Could not find "$catalogName" Catalog. Are you sure you have the correct name?"
        (New-Object Microsoft.SqlServer.Management.IntegrationServices.Catalog($integrationServices,"SSISDB","P@ssword1")).Create()
		$catalog = $integrationServices.Catalogs[$catalogName] 
		Write-Host "Created New Catalog Name"
    }
    
	$catalog = $integrationServices.Catalogs["SSISDB"]
	
    # Get catalog folder
    if ($catalog.Folders.Contains($folderName))
    {
        Write-Host "$folderName catalog folder found"
        $folder = $catalog.Folders[$folderName]
    }
    else
    {
        Write-Host "Could not find $folderName catalog folder. You are almost there."
        (New-Object Microsoft.SqlServer.Management.IntegrationServices.CatalogFolder($catalog,$folderName,"Powershell")).Create()
		$folder = $catalog.Folders[$folderName]
		Write-Host "New Folder Name Under the Catalog"
    }
    
	#$folderName = $catalog.Folders.Item($folderName)
	
    # Create .ispac
    Write-Host "$SolutionPath$projectName.dtproj /Build $Environment"
    & $devenv "$SolutionPath$projectName.dtproj" /Build $Environment
    
    $IspacPath = "$scriptPath/$SolutionPath/bin/$Environment/$projectName.ispac"

    # Read the project file, and deploy it to the folder
    [byte[]] $projectFile = [System.IO.File]::ReadAllBytes($IspacPath)
	$folder.DeployProject($projectName, $projectFile)
    
    # Get project
    if ($folder.Projects.Contains($projectName)) 
    {
        Write-Host "$projectName project found"
        $project = $folder.Projects[$projectName]
        
    } else 
	{
        Write-Host "$projectName project not found. Sorry :("
        return 
    }
    
    # Get function parameters from file
    Write-Host "Reading from Parameters.xml"    
    [xml]$file = Get-Content $ParametersXml
    
    Update-Parameters $project $file 
} 

function Update-Parameters($project, $file)
{
    # Update Project Parameters
    $pcount = 0
    $projectParameters = $file.SelectNodes("/SSIS/" + $Environment + "/ProjectParameters/Parameter")

    $projectParameters | % {
        
        $parameter = $_.Name
        if ($parameter -eq $null)
        {
            continue
        }
        Write-Host "$project.Parameters.Contains($parameter) Suraj"
		
        if ($project.Parameters.Contains($parameter))
        {
            Write-Host "$parameter project parameter found"
            $project.Parameters[$_.Name].Set([Microsoft.SqlServer.Management.IntegrationServices.ParameterInfo+ParameterValueType]::Literal,$_.InnerText)
            Write-Host "$parameter project parameter value updated"
            $pcount++
        }
        else
        {
             Write-Host "$parameter project parameter NOT FOUND"
        }
    }
    
    Write-Host "Updating parameters of" $project.Name "project successful"
	$ProjectName = $project.Name
	Write-Host "$ProjectName Updated Project Name"


    # Update Package Parameters
    $packages = $file.SelectNodes("/SSIS/" + $Environment + "/Packages/Package")

    $packages | % {
        
        $packageName = $_.Name
        $parameters = $_.Parameters.ChildNodes
		
		Write-Host "$ProjectName Initial Project Name"
        
        #if ($project.Packages.Contains($packageName))
		if ($Project.Packages.Contains($packageName))
        {
                Write-Host "$packageName package found"
                #$ssisPackage = $project.Packages[$packageName]
				$ssisPackage = $Project.Packages[$packageName]
                
                foreach ($param in $parameters){
                
                    $paramName = $param.Name
                    $paramValue = $param.InnerText
                    
                    if ($ssisPackage.Parameters.Contains($paramName))
                    {
                        Write-Host "$paramName package parameter found"
                        $ssisPackage.Parameters[$paramName].Set([Microsoft.SqlServer.Management.IntegrationServices.ParameterInfo+ParameterValueType]::Literal,$paramValue)						
                        Write-Host "$paramName $paramValue package parameter value updated"
                        $pcount++
                    }
                    else
                    {
                        Write-Host "$paramName package parameter NOT FOUND"
                    }				
                } 
                Write-Host "Updating parameters of $packageName package successful"			
                $ssisPackage.Alter() 
				
                         
        }
        else
        {
            Write-Host "$packageName package NOT FOUND"
        }
        
    }

    if ($pcount -gt 0)
    {
    $project.Alter()
    }
}

Main