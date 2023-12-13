' Prompt the user for a new phone number using an input box
newPhoneNumber = InputBox("Enter the phone number:", "Whatsapp Sender")

If newPhoneNumber <> "" Then
    ' Construct the new URL with the provided phone number
    newURL = "https://web.whatsapp.com/send/?phone=972" & newPhoneNumber

    ' Open the new URL in the default browser (optional)
    Set objShell = CreateObject("WScript.Shell")
    objShell.run newURL
Else
    ' Display a message if the user cancels or provides an empty input
    MsgBox "No phone number provided. Exiting script.", vbExclamation, "Change Phone Number"
End If
