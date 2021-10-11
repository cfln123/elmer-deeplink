on replaceString(str, searchStr, replacementStr)
	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to the searchStr
	set the subStr to every text item of str
	set AppleScript's text item delimiters to the replacementStr
	set str to the subStr as string
	set AppleScript's text item delimiters to oldDelims
	return str
end replaceString

on logout(browserName)
	tell application browserName to activate
	
	tell application "System Events"
		key code 17 using command down
		delay 0.5
		keystroke "https://signin.aws.amazon.com/oauth?Action=logout&redirect_uri=aws.amazon.com"
		delay 0.5
		key code 36
		delay 1
		key code 13 using command down
	end tell
end logout

on getDefaultBrowserName()
	set defaultBrowser to do shell script "x=~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist; \\
	plutil -convert xml1 $x; \\
	grep 'https' -b3 $x | awk 'NR==2 {split($2, arr, \"[><]\"); print arr[3]}'; \\
	plutil -convert binary1 $x"
	
	if defaultBrowser is "org.mozilla.firefox" then
		set browserName to "Firefox"
	else if defaultBrowser is "com.apple.safari" then
		set browserName to "Safari"
	else if defaultBrowser is "com.microsoft.edgemac" then
		set browserName to "Microsoft Edge"
	else
		set browserName to "Google Chrome"
	end if
	
	return browserName
end getDefaultBrowserName

on getAccountName(elmer, _id)
	try
		set account to do shell script elmer & " al | grep " & _id
		return do shell script "echo " & quoted form of account & "| awk " & quoted form of "{ print $2\" \"$4 }"
	on error the errorMessage
		display dialog errorMessage
	end try
end getAccountName

on open location params
	set ELMER_PATH to "/usr/local/bin/elmer"
	
	try
		logout(getDefaultBrowserName())
		
		set params to replaceString(params, "elmer:", "")
		set params to replaceString(params, "//", "")
		set params to replaceString(params, "%20", " ")
		
		set oldDelims to AppleScript's text item delimiters
		set AppleScript's text item delimiters to " "
		set _id to item 1 of the text items of params
		set role to item 2 of the text items of params
		set AppleScript's text item delimiters to oldDelims
		
		try
			_id as number
			set account to getAccountName(ELMER_PATH, _id)
			if account is "" then
				display dialog "Account " & _id & " not found"
				return
			end if
			set params to account & " " & role
		end try
		
		do shell script ELMER_PATH & " get-web-creds " & params
	on error the errorMessage
		display dialog errorMessage
	end try
	
end open location