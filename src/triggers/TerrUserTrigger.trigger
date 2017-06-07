trigger TerrUserTrigger on Terr_Urer__c (before delete, after insert) {

    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            TriggerTerrUserHandler.deleteSharing(Trigger.old);
        }
    } else {
        if (Trigger.isInsert) {
            TriggerTerrUserHandler.shareAccountsAndContacts(Trigger.new);
        }
    }

}