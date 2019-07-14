/system script add name=datetime policy=read source=[/file get [find name="datetime.rsc"] contents]
/system scheduler add name=add-datetime-function on-event="/system script run datetime" policy=read start-time=startup
