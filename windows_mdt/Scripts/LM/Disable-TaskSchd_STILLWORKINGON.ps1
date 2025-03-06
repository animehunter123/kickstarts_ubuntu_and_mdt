#Disable unneeded startup processes/telemetry tasks in the image:

# To delete: Get-ScheduledTask "AliUpdater*" | Unregister-ScheduledTask -Confirm:$false
# "*telemetry*",

$scheduledTasksToDisable = @(
    "Adobe Acrobat Update Task",
    "Adobe Flash Player Updater"
)
#Disable List of Tasks:
foreach ($i in $scheduledTasksToDisable) {
    get-scheduledtask "*$i*" | Disable-ScheduledTask -Verbose    
}

#Disable Telemetry 
get-scheduledtask "*telemetry*" | Disable-ScheduledTask -Verbose