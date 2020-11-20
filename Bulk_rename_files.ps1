$Host.UI.RawUI.WindowTitle = "Bulk_rename_files"
cd D:\Downloads\ ;
$input_folder = Read-Host -Prompt "Podaj nazwę katalogu, do którego przenieść przetworzone pliki `n";
$input_folder = (Get-Location).path + '\' + $input_folder;
echo $input_folder;
$input_ext = Read-Host -Prompt "Podaj nazwę rozszerzenia dla plików do przetworzenia, np. 'mp4'`n";
$ext = '.' + $input_ext;
$file_filter = '*' + $ext;
$dir_filter = Read-Host -Prompt "Podaj maskę dla katalogów do przetworzenia `n";
$dir_filter = '*' + $dir_filter + '*';
$regex_str1 = '[^0-9A-Za-z\.]';
$regex_str2 = '\.+';
$regex_str3 = '(\d{3,4}p).*'

if(!(Test-Path $input_folder)) {
    
    mkdir $input_folder

}

dir -Directory -filter $dir_filter | where { $_.Child.extension -notin '.!qb'} | move-item -Destination $input_folder;
cd $input_folder    

$filesandfolders = Get-ChildItem -recurse | Where-Object { $_.name -match $regex_str1} 
$filesandfolders | Where-Object {$_.PsIscontainer}  |  foreach {
    $New=(($_.name -Replace $regex_str1,".") -Replace $regex_str2,".") -Replace $regex_str3,'$1';
    Rename-Item  -Literalpath $_.Fullname -newname $New -passthru
}
$filesandfolders | Where-Object {!$_.PsIscontainer}  |  foreach {
    $New=($_.name -Replace $regex_str1,".") -Replace $regex_str2,".";
    Rename-Item  -Literalpath $_.Fullname -newname $New -passthru
}

$Folder = dir -Recurse -Directory -filter $dir_filter ;
          
Foreach ($dir In $Folder) 
    {
	$current_dir = (Get-Location).path + '\' + $dir;
    $Count = Get-ChildItem -File -LiteralPath $current_dir -Filter $file_filter | Measure-Object | %{$_.Count}
   
    # Set default value for addition to file name 
    $i = 1 
    $newdir = $dir.name + "." 
    # Search for the files set in the filter
    $files = Get-ChildItem -LiteralPath $dir.fullname -Filter $file_filter -Recurse
    Foreach ($file In $files) 
        { 
        # Check if a file exists 
        If ($file) 
            { 
            # Split the name and rename it to the parent folder 
            $split    = $file.name.split($ext)
                if ( $Count -gt 1 )
                    { $replace  = $split[0] -Replace $split[0],($newdir + $i + $ext) }
                else
					{ $replace  = $split[0] -Replace $split[0],($dir.name + $ext) }
			# Trim spaces and rename the file 
            $image_string = $file.fullname.ToString().Trim() 
            #"$split[0] renamed to $replace" 
            Rename-Item  -LiteralPath "$image_string" "$replace";
            $i++ 
            } 
        }
	if ( $Count -eq 1 )
		{ dir -LiteralPath $current_dir -Recurse -File -filter $file_filter | Move-Item -Destination $input_folder }
	
    }

dir -Recurse -Directory -filter $dir_filter | dir -Recurse -File | where-object {$_.extension -notin $ext} | Remove-Item;
ls -Directory -filter $dir_filter -recurse | where { -NOT $_.GetFiles() -and -not $_.GetDirectories()} | Remove-Item;

start . ;
cd \ ;
exit