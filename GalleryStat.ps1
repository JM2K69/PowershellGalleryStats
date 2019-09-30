#================================================================================================================
#
# Author 		 : Jérôme Bezet-Torres
# Twitter		 : @JM2K69
#
#================================================================================================================

$Global:Current_Folder = split-path $MyInvocation.MyCommand.Path
$ProgressPreference = 'SilentlyContinue'


[System.Void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  			
[System.Void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[System.Void][System.Reflection.Assembly]::LoadWithPartialName('PresentationCore')
[System.Void][System.Reflection.Assembly]::LoadFrom("$Current_Folder\assembly\MahApps.Metro.dll")       				
[System.Void][System.Reflection.Assembly]::LoadFrom("$Current_Folder\assembly\MahApps.Metro.IconPacks.dll") 
[System.Void][System.Reflection.Assembly]::LoadFrom("$Current_Folder\assembly\MahApps.Metro.IconPacks.Core.dll") 
[System.Void][System.Reflection.Assembly]::LoadFrom("$Current_Folder\assembly\LiveCharts.Wpf.dll")       			
[System.Void][System.Reflection.Assembly]::LoadFrom("$Current_Folder\assembly\LiveCharts.dll")      
[System.Void][System.Reflection.Assembly]::LoadFrom("$Current_Folder\assembly\ControlzEx.dll")     
[System.Void][System.Reflection.Assembly]::LoadFrom("$Current_Folder\assembly\Microsoft.Xaml.Behaviors.dll")



function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml("$Global:Current_Folder\Main.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

[System.Windows.Forms.Application]::EnableVisualStyles()

$XamlMainWindow.SelectNodes("//*[@Name]") | %{
    try {Set-Variable -Name "$("WPF_"+$_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop}
    catch{throw}
    }
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable *WPF*
}
  #Get-FormVariables

<#

#>
$WPF_Check.Add_Click({
	
	if ($WPF_Switch.IsChecked -eq $True)
	{
		$WPF_ModulesList.Items.Clear()
		$Authors = $WPF_Authors.SelectedValue

		$Modules=Find-GalleryModule -Author  $Authors
		$ModulesU = $Modules |  select -Property Title -Unique
		$Global:Average = 0 
		$Global:Cpt = 0

		foreach ($item in $ModulesU) 
		{
		$WPF_ModulesList.Items.Add($item.Title)| Out-Null

		$Modules = Find-GalleryModule -Module $item.Title
		$Global:Cpt = $Global:Cpt + $($Modules[0].ModuleDownloadCount)

		}

		$Global:Check = $true

		$WPF_ModulesList.SelectedIndex="0"


		$WPF_Numbermodules.Content = "$($ModulesU.count)"
	
		$Global:Div = "$($ModulesU.count)"
		Try{[Int]$Content = $Global:Cpt / $Global:Div}
		catch{}
		$WPF_TAverage.Content = $Content
		$WPF_Graph.Visibility = "Visible"
		$WPF_Download.Visibility ="Visible"
		$WPF_Download.Visibility ="Visible"
		$WPF_Core.Visibility = "Collapsed"
		$WPF_NA.Visibility = "Collapsed"
		$WPF_Desktop.Visibility = "Collapsed"



	}
	
	if ($WPF_Switch.IsChecked -eq $False)
	{	
		$WPF_GraphOption.Visibility="Collapsed"
		$WPF_Smodule.Content = $WPF_Authors.SelectedValue
		Try {
			$ModuleSelected =   $WPF_Smodule.Content
			$ModulesS = Find-GalleryModule -Module $ModuleSelected 
			$WPF_Numbermodules.Content =  $ModulesS.count
			$WPF_TAverage.Content = $ModulesS[0].Authors
			$Full = $ModulesS[0].ModuleDownloadCount
			$Project = $ModulesS[0].ProjectUrl
			$First = $ModulesS[0].Created
			$LastV = $ModulesS.count - 1
			$Last = $ModulesS[$LastV].Created
			$WPF_Project_URL.Content = $Project
			$WPF_FullDownload.Content =$Full
			$WPF_Created.Content = $First
			$WPF_LastUpdate.Content = $Last
		}
		catch {}
		
		$Pedition = Find-GalleryModule -Module $ModuleSelected  -version LatestVersion
		$cptCore=0
		$cptDesktop=0
		foreach ($item in $Pedition.Tags) {
			switch ($item) {
				'PSEdition_Desktop' { $cptDesktop = $cptDesktop + 1  }
				'PSEdition_Core'{ $cptCore = $cptCore + 1}
				Default {}
			}

		}
		if ($cptCore -eq 1)
		{

			$WPF_Core.Visibility = "Visible"

		}
		elseif ($cptDesktop -eq 1) {
			
			$WPF_Core.Visibility = "Visible"

		}
		else
		{
			$WPF_Na.Visibility = "Visible"
		}

		$WPF_Graph.Visibility = "Visible"
		$WPF_Download.Visibility ="Visible"



	}


})

$WPF_TextBox.Add_TextChanged({
	If ( ($WPF_TextBox.text.Length -ge 3) -and ($WPF_TextBox.Text -notmatch "^\s{1,}") ){
			$WPF_Authors.SelectedIndex="0"
			$WPF_TextBox.Background = [System.Windows.Media.Brushes]::PaleGreen
			$Modules=Find-GalleryModule -Author $WPF_TextBox.text | select @{l='Authors';e={$_.Authors}} -Unique
			foreach ($item in $Modules) {

			$WPF_Authors.Items.Add($item.Authors)| Out-Null
		}
		$WPF_Check.IsEnabled = $true
		$WPF_Graph.Visibility = "Hidden"
		$WPF_Download.Visibility ="Hidden"


	}
	Else
	{
		$WPF_TextBox.Background = [System.Windows.Media.Brushes]::Transparent
		Clean-Control
		$WPF_GraphOption.Visibility="Collapsed"
		$WPF_Check.IsEnabled = $false
		$WPF_Graph.Visibility = "Hidden"
		$WPF_Download.Visibility ="Hidden"
		$WPF_Core.Visibility = "Collapsed"
		$WPF_NA.Visibility = "Collapsed"
		$WPF_Desktop.Visibility = "Collapsed"
	}
})
function Clean-Control {

	# Clear All Content
 Try {
	$WPF_Authors.Items.Clear()
	$WPF_ModulesList.Items.Clear()
	$Null = $Global:DoughnutCollection
	New-WPFChart -Array $Null
	$WPF_Doughnut.Series = $Global:DoughnutCollection
	$WPF_Numbermodules.Content=""
	$WPF_Project_URL.Content = ""
	$WPF_FullDownload.Content =""
	$WPF_Created.Content = ""
	$WPF_LastUpdate.Content = ""
	$WPF_TAverage.Content = ""
	$WPF_Smodule.Content = ""
	$WPF_Core.Visibility = "Collapsed"
	$WPF_NA.Visibility = "Collapsed"
	$WPF_Desktop.Visibility = "Collapsed"
	$WPF_Graph.Visibility = "Hidden"
	$WPF_Download.Visibility ="Hidden"

 }
 catch{}
}

$WPF_Graph.Add_Click({


	switch ($WPF_Switch.IsChecked) {
		$true 
		{  
			$ModuleSelected =   $WPF_ModulesList.SelectedValue
			
		}
		$False 
		{
			$ModuleSelected =   $WPF_Authors.SelectedValue

		}
		Default {}
	}
		$ModulesS = Find-GalleryModule -Module $ModuleSelected 
		$Valeurs = $ModulesS | select @{l='Title';e={$_.Version}},@{l='value';e={$_.VersionDownloadCount}}
		if ($Valeurs.count -ge 15)
		{
			$First = $Valeurs.count - 10
			$Last = $Valeurs.count + 1

			New-WPFChart -Array $Valeurs[$First..$Last]
			$Global:Graph = $true
			$WPF_GraphOption.Visibility="Visible"
			$WPF_Doughnut.Series = $Global:DoughnutCollection
	
		}
		else 
		{
			New-WPFChart -Array $Valeurs
			$Global:Graph = $true
			$WPF_GraphOption.Visibility="Visible"
			$WPF_Doughnut.Series = $Global:DoughnutCollection
	

		}
	


})


function New-WPFChart {
    param(
        [Object[]]$Array
    )
$Global:DoughnutCollection = [LiveCharts.SeriesCollection]::new()
    Foreach ( $truc in $array ) {
        $chartvalue1 = [LiveCharts.ChartValues[LiveCharts.Defaults.ObservableValue]]::new()
        $pieSeries = [LiveCharts.Wpf.PieSeries]::new()
        $chartvalue1.Add([LiveCharts.Defaults.ObservableValue]::new($Truc.Value))
        $pieSeries.Values = $chartvalue1
        $pieSeries.Title = $Truc.Title
        $pieSeries.DataLabels = $true
        $Global:DoughnutCollection.Add($pieSeries)    
    }
}



$WPF_MonBouton.Add_Click({
	$Theme = [MahApps.Metro.ThemeManager]::DetectTheme($form)	
	$my_theme = ($Theme.BaseColorScheme)
	If($my_theme -eq "Light")
		{
			[MahApps.Metro.ThemeManager]::ChangeThemeBaseColor($form, "Dark");		
				
		}
	ElseIf($my_theme -eq "Dark")
		{					
			[MahApps.Metro.ThemeManager]::ChangeThemeBaseColor($form, "Light");			
		}		
})


$WPF_ModulesList.Add_SelectionChanged({

	Try {
		$ModuleSelected =   $WPF_ModulesList.SelectedValue
		$ModulesS = Find-GalleryModule -Module $ModuleSelected 
		$Full = $ModulesS[0].ModuleDownloadCount
		$Project = $ModulesS[0].ProjectUrl
		$First = $ModulesS[0].Created
		$LastV = $ModulesS.count - 1
		$Last = $ModulesS[$LastV].Created
		$WPF_Project_URL.Content = $Project
		$WPF_FullDownload.Content =$Full
		$WPF_Created.Content = $First
		$WPF_LastUpdate.Content = $Last
		$WPF_Core.Visibility = "Collapsed"
		$WPF_NA.Visibility = "Collapsed"
		$WPF_Desktop.Visibility = "Collapsed"

		$Pedition = Find-GalleryModule -Module $ModuleSelected -version Latestversion
			$cptCore=0
			$cptDesktop=0
			foreach ($item in $Pedition.Tags) {
				switch ($item) {
					'PSEdition_Desktop' { $cptDesktop = $cptDesktop + 1  }
					'PSEdition_Core'{ $cptCore = $cptCore + 1}
					Default {}
				}

			}
			
			if ($cptCore -eq 1)
			{

				$WPF_Core.Visibility = "Visible"

			}
			elseif ($cptDesktop -eq 1) {
				
				$WPF_Core.Visibility = "Visible"

			}
			else
			{
				$WPF_Na.Visibility = "Visible"
			}


	}
	catch {}


})


$WPF_Option.Add_Click({

	$WPF_Flyout.IsOpen= $true

})

$WPF_Switch.Add_Click({

	if ($WPF_Switch.IsChecked -eq $true)
	{
		$WPF_MAuhtors.Visibility = "Visible"
		$WPF_M_Modules.Visibility = "Collapsed"
		$WPF_NumMod.Content = "Number modules: "
		$WPF_TAD.Content = "Total Average download : "
		$WPF_ModulesList.Visibility = "Visible"
		$WPF_Smodule.Visibility = "Collapsed"
		New-WPFChart -Array $null
		$WPF_Core.Visibility = "Collapsed"
		$WPF_NA.Visibility = "Collapsed"
		$WPF_Desktop.Visibility = "Collapsed"
		Clean-Control
		$WPF_GraphOption.Visibility="Collapsed"
		$WPF_Graph.Visibility = "Hidden"
		$WPF_Download.Visibility ="Hidden"
		$WPF_Check.IsEnabled = $false
}

	if ($WPF_Switch.IsChecked -eq $false)
	{
			$WPF_MAuhtors.Visibility = "Collapsed"
			$WPF_M_Modules.Visibility = "Visible"
			$WPF_NumMod.Content = "Number Version :"
			$WPF_TAD.Content = "Auhtors Module :"
			$WPF_ModulesList.Visibility = "Collapsed"
			$WPF_Smodule.Visibility = "Visible"
			New-WPFChart -Array $null
			$WPF_Core.Visibility = "Collapsed"
			$WPF_NA.Visibility = "Collapsed"
			$WPF_Desktop.Visibility = "Collapsed"
			Clean-Control
			$WPF_GraphOption.Visibility="Collapsed"
			$WPF_Graph.Visibility = "Hidden"
			$WPF_Download.Visibility ="Hidden"
			$WPF_Check.IsEnabled = $false


		}

})


$WPF_ModuleList.Add_TextChanged({

	If ( ($WPF_ModuleList.Text.Length -ge 3) -and ($WPF_ModuleList.Text -notmatch "^\s{1,}") ){
			$WPF_ModuleList.Background = [System.Windows.Media.Brushes]::PaleGreen
			$Value = $WPF_ModuleList.text + "*"
			$SModules=Find-GalleryModule -Module $Value | select @{l='Title';e={$_.Title}} -Unique

			foreach ($item in $SModules) {
			$WPF_Authors.Items.Add($item.Title)| Out-Null
		}
		$WPF_Check.IsEnabled = $true
		$WPF_Graph.Visibility = "Hidden"
		$WPF_Download.Visibility ="Hidden"


	}
	Else
	{
		$WPF_Authors.SelectedIndex="0"

		$WPF_ModuleList.Background = [System.Windows.Media.Brushes]::Transparent
		Clean-Control
		$WPF_GraphOption.Visibility="Collapsed"
		$WPF_Check.IsEnabled = $false
		$WPF_Graph.Visibility = "Hidden"
		$WPF_Download.Visibility ="Hidden"
		$WPF_Core.Visibility = "Collapsed"
		$WPF_NA.Visibility = "Collapsed"
		$WPF_Desktop.Visibility = "Collapsed"


	}
})
##########################
$WPF_Authors.Add_SelectionChanged({

	if ($WPF_Switch.IsChecked -eq $true)
	{
		
		$WPF_Core.Visibility = "Collapsed"
		$WPF_NA.Visibility = "Collapsed"
		$WPF_Desktop.Visibility = "Collapsed"
	}

	if ($WPF_Switch.IsChecked -eq $false)
	{
			$WPF_Core.Visibility = "Collapsed"
			$WPF_NA.Visibility = "Collapsed"
			$WPF_Desktop.Visibility = "Collapsed"
		}
})

$WPF_Download.Add_Click({

	switch ($WPF_Switch.IsChecked) {
		$true 
		{  
			Save-Module  -Name $WPF_ModulesList.SelectedValue   -Path "$Global:Current_Folder\Download" 
			
		}

		$False 
		{
			Save-Module  -Name $WPF_Smodule.Content -Path "$Global:Current_Folder\Download" 

		}
		Default {}
	}
})

$WPF_FullStats.Add_Click({


	switch ($WPF_FullStats.IsChecked) {
		$True 
		{ 	
			$WPF_GGraph.Visibility = "Collapsed"
			$WPF_GAuthors.Visibility = "Collapsed"
			$WPF_GStatistic.Visibility = "Collapsed"
			$WPF_GNew_Module.Visibility = "Visible"
			Clean-Control
			$WPF_TextBox.Text=""
			$WPF_ModuleList.Text=""
			if ($Global:Graph -eq $true)
			{
				try 
				{				
					$WPF_GGraphOption.Visibility = "Collapsed"
				}
				catch{}
			}

		}
		$False 
		{
			#Restore Default view
			$WPF_GGraph.Visibility = "Visible"
			$WPF_GAuthors.Visibility = "Visible"
			$WPF_GStatistic.Visibility = "Visible"
			$WPF_GNew_Module.Visibility = "Collapsed"
			Clean-Control
			$WPF_TextBox.Text=""
			$WPF_ModuleList.Text=""

			if ($Global:Graph -eq $true)
			{
				try 
				{
					$WPF_GGraphOption.Visibility = "Collapsed"
				}
				catch{}
			}

		}

		Default {}
	}


})

$WPF_Calendar.Add_SelectedDateChanged({

	$WPF_New_Module.Items.Clear()
	$WPF_New_Module.Items.Refresh()
	$WPf_GNInfo.Visibility = 'Collapsed'


})

$WPF_GNInfo.Add_Click({


		$Project_Url = $WPF_New_Module.SelectedItems.ProjectUrl

	if ($Null -ne $Project_Url) {Start $Project_Url }
	
	else {}

})

$WPF_GNCheck.Add_Click({
	$Null = $Global:Modules
	$WPf_GNInfo.Visibility = 'Visible'
	if (($WPF_DDesktop.IsChecked -eq $False) -and ($WPF_DCore.IsChecked -eq $False))
	{
		$Global:Modules = Find-GalleryModule -Date $WPF_Calendar.SelectedDate.ToShortDateString() -version Latestversion  | Select -Property Authors,Title,Version,ProjectUrl
	}

	if ($PreRelease.IsChecked -eq $true )
	{
		$Global:Modules = Find-GalleryModule -Date $WPF_Calendar.SelectedDate.ToShortDateString() -version PreRelease  | Select -Property Authors,Title,Version,ProjectUrl
	}


	$cpt=$null
		foreach ($item in $Global:Modules.Title)
	{
    $tt=Find-GalleryModule -Module $item

    if( $($tt.count) -gt 1)
    {
        $cpt = $Cpt + 1
    }

	}

	$WPF_Result.Visibility = 'Visible'

	$WPF_MUpdates.Content = $($Global:Modules).count

	$WPF_NewM.Content = $($Global:Modules).count - $cpt

	<#
	if ($WPF_DDesktop.IsChecked -eq $true )
	{
		$Global:Modules = Find-GalleryModule -Date $WPF_Calendar.SelectedDate.ToShortDateString() -version Latestversion -PSEditionType Desktop | Select -Property Authors,Title,Version,ProjectUrl
	}

	if ($WPF_DDesktop.IsChecked -eq $true )
	{
		$Global:Modules = Find-GalleryModule -Date $WPF_Calendar.SelectedDate.ToShortDateString() -version Latestversion -PSEditionType Core | Select -Property Authors,Title,Version,ProjectUrl
	}
	#>

	foreach ($Value in $Global:Modules)
	{
		
		$PowerCLI_values = New-Object PSObject
		$PowerCLI_values = $PowerCLI_values | Add-Member NoteProperty Authors $Value.Authors -passthru
		$PowerCLI_values = $PowerCLI_values | Add-Member NoteProperty Title $Value.Title -passthru	
		$PowerCLI_values = $PowerCLI_values | Add-Member NoteProperty Version $Value.Version -passthru	
		$PowerCLI_values = $PowerCLI_values | Add-Member NoteProperty ProjectUrl $Value.ProjectUrl -passthru	
		[System.Void]$WPF_New_Module.Items.Add($PowerCLI_values) 
	}


})
<#
$WPF_DDesktop.Add_Click({

	$WPF_DCore.IsChecked = $False

})

$WPF_DCore.Add_Click({

	$WPF_DDesktop.IsChecked = $False

})
#>
[System.Void]$Form.ShowDialog() 

