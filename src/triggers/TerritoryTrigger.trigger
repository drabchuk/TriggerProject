trigger TerritoryTrigger on Territory__c (before insert, before delete) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            TriggerTerritoryHandler.checkUnicness(Trigger.new);
        } else {
            if (Trigger.isDelete) {
                TriggerTerritoryHandler.relinkTerritoriesAndTerrUsersWhenDelete(Trigger.oldMap);
            }
        }
    }

}