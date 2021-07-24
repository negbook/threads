this = {}
this.scriptName = "threads"
if GetCurrentResourceName() == this.scriptName then 
RegisterNetEvent('Threads:AddPositions')
AddEventHandler('Threads:AddPositions', function(actionname,datas,rangeorcb,_cb) 
    exports.threads:AddPositions(actionname,datas,rangeorcb,_cb)
end)
RegisterNetEvent('Threads:AddPosition')
AddEventHandler('Threads:AddPosition', function(actionname,datas,rangeorcb,_cb) 
    exports.threads:AddPosition(actionname,datas,rangeorcb,_cb)
end)
end 