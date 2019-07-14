### Download the latest version of datetime.rsc from GitHub and install it.

/tool fetch url="https://raw.githubusercontent.com/phistrom/datetime-routeros/master/create-datetime-function.rsc" dst-path=create-datetime-function.rsc
/system script remove create-datetime-function
/system script add name=create-datetime-function policy=read source=[/file get [find name="datetime.rsc"] contents]
/system scheduler remove create-datetime-function
/system scheduler add name=create-datetime-function on-event="/system script run datetime" policy=read start-time=startup
/file remove create-datetime-function.rsc
