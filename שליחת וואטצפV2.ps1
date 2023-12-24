Add-Type -AssemblyName System.Windows.Forms

# Function to display a dropdown of countries and return the selected prefix
function Show-CountryDropdown {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "WhatsApp Sender"

    $labelCountry = New-Object System.Windows.Forms.Label
    $labelCountry.Text = "ארץ:"
    $labelCountry.Location = New-Object System.Drawing.Point(10, 20)
    $form.Controls.Add($labelCountry)

    $dropdown = New-Object System.Windows.Forms.ComboBox
    $dropdown.Location = New-Object System.Drawing.Point(10, 50)
    
    # Get countries from the API
    $countries = Get-CountryPrefixes

    foreach ($country in $countries.Keys) {
        [void]$dropdown.Items.Add($country)
    }

    $form.Controls.Add($dropdown)
    
    $labelNumber = New-Object System.Windows.Forms.Label
    $labelNumber.Text = "מספר:"
    $labelNumber.Location = New-Object System.Drawing.Point(10, 80)
    $form.Controls.Add($labelNumber)

    $textBoxNumber = New-Object System.Windows.Forms.TextBox
    $textBoxNumber.Location = New-Object System.Drawing.Point(10, 110)
    $form.Controls.Add($textBoxNumber)

    $labelMsg = New-Object System.Windows.Forms.Label
    $labelMsg.Text = "הודעה:"
    $labelMsg.Location = New-Object System.Drawing.Point(10, 150)
    $form.Controls.Add($labelMsg)

    $textBoxMsg = New-Object System.Windows.Forms.TextBox
    $textBoxMsg.Location = New-Object System.Drawing.Point(10, 180)
    $form.Controls.Add($textBoxMsg)

    $button = New-Object System.Windows.Forms.Button
    $button.Text = "Send"
    $button.Location = New-Object System.Drawing.Point(10, 210)
    $button.Add_Click({
        $form.Tag = @{
            'Country' = $dropdown.SelectedItem
            'PhoneNumber' = $textBoxNumber.Text
            'Message' = $textBoxMsg.Text
        }
        $form.Close()
    })
    $form.Controls.Add($button)

    $form.Add_Shown({$form.Activate()})
    [System.Windows.Forms.Application]::Run($form)

    return $form.Tag
}

# Function to get a list of all countries and their prefixes
function Get-CountryPrefixes() {
    $apiUrl = "https://restcountries.com/v2/all"
    $countriesJson = Invoke-RestMethod -Uri $apiUrl
    $countries = @{}

    foreach ($country in $countriesJson) {
        $countryName = $country.name
        $callingCodes = $country.callingCodes

        if ($callingCodes.Count -gt 0) {
            $countries[$countryName] = $callingCodes[0]
        }
    }

    return $countries
}

# Prompt the user to choose a country from the dropdown
$userSelection = Show-CountryDropdown
if (-not $userSelection) {
    [System.Windows.Forms.MessageBox]::Show("No selection made. Exiting script.", "Selection", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Exclamation)
    return
}

# Get countries and their prefixes
$countries = Get-CountryPrefixes

# Retrieve user input from the returned object
$selectedCountry = $userSelection['Country']
$phoneNumber = $userSelection['PhoneNumber']
$message = "&text="+$userSelection['message']

# Replace spaces with %20
$newMessage = $message -replace ' ', '+'

# Get the selected country's prefix
if ($countries.ContainsKey($selectedCountry)) {
    $selectedCountryPrefix = $countries[$selectedCountry]

    if ($phoneNumber -ne "") {
        # Construct the new URL with the provided phone number and selected country prefix
        $newURL = "https://web.whatsapp.com/send/?phone=$selectedCountryPrefix$phoneNumber$newMessage"

        # Open the new URL in the default browser (optional)
        Start-Process $newURL
    }
    else {
        # Display a message if the user cancels or provides an empty input
        [System.Windows.Forms.MessageBox]::Show("No phone number provided. Exiting script.", "Phone Number", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Exclamation)
    }
}
else {
    [System.Windows.Forms.MessageBox]::Show("Invalid country selection. Exiting script.", "Country Prefix Selection", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Exclamation)
}
