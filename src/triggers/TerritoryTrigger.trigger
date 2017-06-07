trigger TerritoryTrigger on Territory__c (before insert) {

    TriggerTerritoryHandler.checkUnicness(Trigger.new);

}