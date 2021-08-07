if (Test-Path pkgmeta.yaml) {
	$pkgMetaFile = "pkgmeta.yaml"
} elseif (Test-Path .pkgmeta) {
	$pkgMetaFile = ".pkgmeta"
}

$pkgMeta = Get-Content $pkgMetaFile | ConvertFrom-Yaml

$pkgMeta.externals.GetEnumerator() | ForEach-Object {
	$localPath = $_.Name
	
	if ($_.Value.GetType().Name -eq "String") {
		$url = $_.Value
		$tag = $null
	} else {
		$url = $_.Value.url
		$tag = $_.Value.tag
	}
	
	
	$uri = [Uri]$url
	
	# convert old curse repo urls
	switch ($uri) {
		{ $_.Host -in "git.curseforge.com", "git.wowace.com"} {
			$external_type = "Git"
			# git://git.curseforge.com/wow/$slug/mainline.git -> https://repos.curseforge.com/wow/$slug
			$path = $uri.AbsolutePath -replace '^/wow/(.+?)/mainline\.git$', '/wow/\1'
			$url = "https://$($uri.Host -replace 'git', 'repos')$path"
			Break
		}
		{ $_.Host -in "svn.curseforge.com", "svn.wowace.com"} {
			$external_type = "Svn"
			# svn://svn.curseforge.com/wow/$slug/mainline/trunk -> https://repos.curseforge.com/wow/$slug/trunk
			$path = $uri.AbsolutePath -replace '^/wow/(.+?)/mainline/trunk', '/wow/\1/trunk'
			$url = "https://$($uri.Host -replace 'svn', 'repos')$path"
			Break
		}
		{ $_.Host -in "hg.curseforge.com", "hg.wowace.com"} {
			$external_type = "Hg"
			# http://hg.curseforge.com/wow/$slug/mainline -> https://repos.curseforge.com/wow/$slug
			$path = $uri.AbsolutePath -replace '^/wow/(.+?)/mainline$', '/wow/\1'
			$url = "https://$($uri.Host -replace 'hg', 'repos')$path"
			Break
		}
		{ $_.Scheme -eq "svn" } {
			# just in case
			$external_type = "Svn"
			Break
		}
		Default {
			$external_type = "Git"
			Break
		}
	}
	
	$uri = [Uri]$url
	
	if ($uri.Host -in "repos.curseforge.com", "repos.wowace.com" -and $uri.AbsolutePath -Like "/wow/*") {
		# $uri.AbsolutePath -match '/wow/(.+?)/'
		# if [ -z "$external_slug" ]; then
			# external_slug=${external_uri#*/wow/}
			# external_slug=${external_slug%%/*}
		# fi

		# check if the repo is svn
		$_svn_path = "${external_uri#*/wow/$external_slug/}"
		if ($uri.AbsolutePath -match "^/wow/(.+?)/trunk") {
			$external_type = "Svn"
		} elseif ($uri.AbsolutePath -match "^/wow/(.+?)/tags") {
			$external_type = "Svn"
			# change the tag path into the trunk path and use the tag var so it gets logged as a tag
			$tag = "${_svn_path#tags/}"
			$tag = "${tag%%/*}"
			$external_uri = "${external_uri%/tags*}/trunk${_svn_path#tags/$tag}"
		}
	}
	
	if (Test-Path $localPath) {
		Remove-Item -Recurse -Force $localPath
	}
	
	switch ($external_type) {
		"Git" {
			Write-Host "Cloning $url..."
			git clone -q $url $localPath
		}
		"Svn" {
			Write-Host "Checking out $url..."
			svn checkout -q $url $localPath
		}
	}
}
